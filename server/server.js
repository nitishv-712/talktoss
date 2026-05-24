require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const User = require('./models/User');
const Message = require('./models/Message');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });
app.set('io', io);

// ─── Middleware ───────────────────────────────────────────────────────────────
app.set('trust proxy', 1);
app.use(cors());
app.use(express.json());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/auth', require('./routes/auth'));
app.use('/report', require('./routes/report'));
app.use('/social', require('./routes/social'));

app.get('/health', (_, res) => res.json({ status: 'ok' }));

// ─── TURN Credentials ─────────────────────────────────────────────────────────
app.get('/turn-credentials', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  try {
    jwt.verify(token, process.env.JWT_SECRET);
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }

  const ttl = 24 * 3600; // 24 hours
  const timestamp = Math.floor(Date.now() / 1000) + ttl;
  const username = `${timestamp}:talktoss`;
  const credential = crypto
    .createHmac('sha1', process.env.TURN_SECRET)
    .update(username)
    .digest('base64');

  res.json({
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      {
        urls: [
          `turn:${process.env.TURN_HOST}:80`,
          `turn:${process.env.TURN_HOST}:443`,
          `turns:${process.env.TURN_HOST}:443`,
        ],
        username,
        credential,
      },
    ],
  });
});

// ─── MongoDB ──────────────────────────────────────────────────────────────────
mongoose.connect(process.env.MONGO_URI, { dbName: 'talktoss' })
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB error:', err));

// ─── Matchmaking Queue ────────────────────────────────────────────────────────
const waitingQueue = [];

function removeFromQueue(socketId) {
  const idx = waitingQueue.findIndex(u => u.socketId === socketId);
  if (idx !== -1) waitingQueue.splice(idx, 1);
}

// ─── Socket.IO Auth Middleware ────────────────────────────────────────────────
io.use((socket, next) => {
  const token = socket.handshake.headers.authorization?.split(' ')[1];
  if (!token) return next(new Error('Unauthorized'));
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.userId;
    next();
  } catch {
    next(new Error('Invalid token'));
  }
});

// ─── Socket.IO Events ─────────────────────────────────────────────────────────
io.on('connection', async (socket) => {
  const user = await User.findByIdAndUpdate(
    socket.userId,
    { isOnline: true, socketId: socket.id },
    { new: true }
  );
  if (!user) return socket.disconnect();

  socket.userUid = user.uid;
  console.log(`Connected: uid=${user.uid} socket=${socket.id}`);

  // ── join_queue ──────────────────────────────────────────────────────────────
  socket.on('join_queue', () => {
    if (user.status === 'banned') {
      return socket.emit('error', { message: 'Your account has been banned.' });
    }
    if (waitingQueue.find(u => u.userId === socket.userId)) return;

    if (waitingQueue.length > 0) {
      const peer = waitingQueue.shift();

      io.to(peer.socketId).emit('match_found', {
        peerUid: user.uid,
        peerSocketId: socket.id,
        isOffer: true,
      });

      socket.emit('match_found', {
        peerUid: peer.uid,
        peerSocketId: peer.socketId,
        isOffer: false,
      });
    } else {
      waitingQueue.push({ userId: socket.userId, uid: user.uid, socketId: socket.id });
      socket.emit('waiting', { message: 'Waiting for a match...' });
    }
  });

  // ── leave_queue ─────────────────────────────────────────────────────────────
  socket.on('leave_queue', () => removeFromQueue(socket.id));

  // ── WebRTC Signaling ────────────────────────────────────────────────────────
  socket.on('offer', ({ targetSocketId, sdp }) => {
    io.to(targetSocketId).emit('offer', { sdp, fromSocketId: socket.id });
  });

  socket.on('answer', ({ targetSocketId, sdp }) => {
    io.to(targetSocketId).emit('answer', { sdp, fromSocketId: socket.id });
  });

  socket.on('ice_candidate', ({ targetSocketId, candidate }) => {
    io.to(targetSocketId).emit('ice_candidate', { candidate });
  });

  // ── call_end ────────────────────────────────────────────────────────────────
  socket.on('call_end', ({ targetSocketId }) => {
    io.to(targetSocketId).emit('call_end');
  });

  // ── send_message ────────────────────────────────────────────────────────────
  socket.on('send_message', async ({ receiverId, text }) => {
    try {
      const msg = await Message.create({
        sender: socket.userId,
        receiver: receiverId,
        text
      });

      // Find if receiver is online
      const receiver = await User.findById(receiverId);
      if (receiver && receiver.socketId) {
        io.to(receiver.socketId).emit('receive_message', msg);
      }
      
      socket.emit('message_sent', msg);
    } catch (err) {
      console.error('[socket send_message]', err);
    }
  });

  // ── disconnect ──────────────────────────────────────────────────────────────
  socket.on('disconnect', async () => {
    console.log(`Disconnected: uid=${socket.userUid}`);
    removeFromQueue(socket.id);
    await User.findByIdAndUpdate(socket.userId, { isOnline: false, socketId: null });
  });
});

// ─── Start Server ─────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
