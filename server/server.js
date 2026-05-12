require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');

const User = require('./models/User');
const Call = require('./models/Call');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/auth', require('./routes/auth'));
app.use('/report', require('./routes/report'));
app.use('/call', require('./routes/call'));

app.get('/health', (_, res) => res.json({ status: 'ok' }));

// ─── MongoDB ──────────────────────────────────────────────────────────────────
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB error:', err));

// ─── Matchmaking Queue ────────────────────────────────────────────────────────
// { userId, socketId }
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
  console.log(`User connected: ${socket.userId} (${socket.id})`);

  // Update user online status
  await User.findByIdAndUpdate(socket.userId, { isOnline: true, socketId: socket.id });

  // ── join_queue ──────────────────────────────────────────────────────────────
  socket.on('join_queue', async () => {
    // Don't add if already in queue
    if (waitingQueue.find(u => u.userId === socket.userId)) return;

    // Check if user is banned
    const user = await User.findById(socket.userId);
    if (!user || user.status === 'banned') {
      return socket.emit('error', { message: 'Your account has been banned.' });
    }

    // Try to match with someone already waiting
    if (waitingQueue.length > 0) {
      const peer = waitingQueue.shift();

      // Create call record
      const call = await Call.create({ callerId: peer.userId, receiverId: socket.userId });

      // Notify both users
      io.to(peer.socketId).emit('match_found', {
        peerId: socket.userId,
        peerSocketId: socket.id,
        callId: call._id,
        isOffer: true   // peer initiates the offer
      });

      socket.emit('match_found', {
        peerId: peer.userId,
        peerSocketId: peer.socketId,
        callId: call._id,
        isOffer: false  // this user waits for offer
      });
    } else {
      // Add to queue
      waitingQueue.push({ userId: socket.userId, socketId: socket.id });
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
    io.to(targetSocketId).emit('ice_candidate', { candidate, fromSocketId: socket.id });
  });

  // ── call_end ────────────────────────────────────────────────────────────────
  socket.on('call_end', async ({ targetSocketId, callId }) => {
    io.to(targetSocketId).emit('call_end');
    if (callId) {
      await Call.findByIdAndUpdate(callId, { endedAt: new Date(), status: 'ended' });
    }
  });

  // ── disconnect ──────────────────────────────────────────────────────────────
  socket.on('disconnect', async () => {
    console.log(`User disconnected: ${socket.userId}`);
    removeFromQueue(socket.id);
    await User.findByIdAndUpdate(socket.userId, { isOnline: false, socketId: null });
  });
});

// ─── Start Server ─────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
