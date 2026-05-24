const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const User = require('../models/User');
const FriendRequest = require('../models/FriendRequest');
const Notification = require('../models/Notification');
const Message = require('../models/Message');

// ── Search Users ─────────────────────────────────────────────────────────────
router.get('/users/search', authMiddleware, async (req, res) => {
  try {
    const query = req.query.q || '';
    if (!query) return res.json([]);

    const users = await User.find({
      _id: { $ne: req.userId },
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } }
      ]
    }).limit(20);

    const results = [];
    for (let u of users) {
      const request = await FriendRequest.findOne({
        $or: [
          { sender: req.userId, receiver: u._id },
          { sender: u._id, receiver: req.userId }
        ]
      });

      const isFriend = u.friends.includes(req.userId);
      let relation = 'none'; // 'none', 'pending_sent', 'pending_received', 'friends'
      let requestId = null;

      if (isFriend) {
        relation = 'friends';
      } else if (request) {
        if (request.status === 'pending') {
          relation = request.sender.toString() === req.userId.toString() ? 'pending_sent' : 'pending_received';
          requestId = request._id;
        } else if (request.status === 'accepted') {
          relation = 'friends';
        }
      }

      results.push({
        id: u._id,
        name: u.name,
        email: u.email,
        avatar: u.avatar,
        isOnline: u.isOnline,
        relation,
        requestId
      });
    }

    res.json(results);
  } catch (err) {
    console.error('[/social/users/search]', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Send Friend Request ──────────────────────────────────────────────────────
router.post('/friend-request', authMiddleware, async (req, res) => {
  try {
    const { receiverId } = req.body;
    if (!receiverId) return res.status(400).json({ error: 'Receiver ID is required' });
    if (receiverId.toString() === req.userId.toString()) {
      return res.status(400).json({ error: 'You cannot add yourself as a friend' });
    }

    const existingRequest = await FriendRequest.findOne({
      $or: [
        { sender: req.userId, receiver: receiverId },
        { sender: receiverId, receiver: req.userId }
      ]
    });

    if (existingRequest) {
      if (existingRequest.status === 'accepted') {
        return res.status(400).json({ error: 'Already friends' });
      } else if (existingRequest.status === 'pending') {
        return res.status(400).json({ error: 'Friend request is already pending' });
      }
      await FriendRequest.deleteOne({ _id: existingRequest._id });
    }

    const newRequest = await FriendRequest.create({
      sender: req.userId,
      receiver: receiverId,
      status: 'pending'
    });

    const newNotification = await Notification.create({
      recipient: receiverId,
      sender: req.userId,
      type: 'friend_request'
    });

    const populatedNotif = await Notification.findById(newNotification._id).populate('sender', 'name email avatar');

    const receiverUser = await User.findById(receiverId);
    if (receiverUser && receiverUser.socketId) {
      const io = req.app.get('io');
      if (io) {
        io.to(receiverUser.socketId).emit('notification', populatedNotif);
      }
    }

    res.json({ message: 'Friend request sent', request: newRequest });
  } catch (err) {
    console.error('[/social/friend-request]', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Respond to Friend Request ────────────────────────────────────────────────
router.post('/friend-request/respond', authMiddleware, async (req, res) => {
  try {
    const { requestId, action } = req.body; // 'accept' or 'reject'
    if (!requestId || !action) return res.status(400).json({ error: 'Request ID and action are required' });

    const request = await FriendRequest.findById(requestId);
    if (!request) return res.status(404).json({ error: 'Friend request not found' });

    if (request.receiver.toString() !== req.userId.toString()) {
      return res.status(401).json({ error: 'Unauthorized to respond to this request' });
    }

    if (request.status !== 'pending') {
      return res.status(400).json({ error: 'Request has already been processed' });
    }

    if (action === 'accept') {
      request.status = 'accepted';
      await request.save();

      await User.findByIdAndUpdate(request.sender, { $addToSet: { friends: request.receiver } });
      await User.findByIdAndUpdate(request.receiver, { $addToSet: { friends: request.sender } });

      const newNotification = await Notification.create({
        recipient: request.sender,
        sender: req.userId,
        type: 'friend_accepted'
      });

      const populatedNotif = await Notification.findById(newNotification._id).populate('sender', 'name email avatar');

      const senderUser = await User.findById(request.sender);
      if (senderUser && senderUser.socketId) {
        const io = req.app.get('io');
        if (io) {
          io.to(senderUser.socketId).emit('notification', populatedNotif);
        }
      }

      res.json({ message: 'Friend request accepted' });
    } else if (action === 'reject') {
      request.status = 'rejected';
      await request.save();

      await Notification.deleteMany({ recipient: req.userId, sender: request.sender, type: 'friend_request' });

      res.json({ message: 'Friend request rejected' });
    } else {
      res.status(400).json({ error: 'Invalid action' });
    }
  } catch (err) {
    console.error('[/social/friend-request/respond]', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Get Friends ──────────────────────────────────────────────────────────────
router.get('/friends', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId).populate('friends', 'name email avatar isOnline');
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user.friends);
  } catch (err) {
    console.error('[/social/friends]', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Get Notifications ────────────────────────────────────────────────────────
router.get('/notifications', authMiddleware, async (req, res) => {
  try {
    const notifications = await Notification.find({ recipient: req.userId })
      .populate('sender', 'name email avatar')
      .sort({ createdAt: -1 });

    const results = [];
    for (let notif of notifications) {
      let requestId = null;
      if (notif.type === 'friend_request') {
        const reqDoc = await FriendRequest.findOne({
          sender: notif.sender._id,
          receiver: req.userId,
          status: 'pending'
        });
        if (reqDoc) requestId = reqDoc._id;
      }
      results.push({
        _id: notif._id,
        recipient: notif.recipient,
        sender: notif.sender,
        type: notif.type,
        read: notif.read,
        createdAt: notif.createdAt,
        requestId
      });
    }

    res.json(results);
  } catch (err) {
    console.error('[/social/notifications]', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Mark Notifications Read ──────────────────────────────────────────────────
router.post('/notifications/read', authMiddleware, async (req, res) => {
  try {
    await Notification.updateMany({ recipient: req.userId }, { read: true });
    res.json({ message: 'Notifications marked as read' });
  } catch (err) {
    console.error('[/social/notifications/read]', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Get Chat Messages ────────────────────────────────────────────────────────
router.get('/chats/:friendId', authMiddleware, async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [
        { sender: req.userId, receiver: req.params.friendId },
        { sender: req.params.friendId, receiver: req.userId }
      ]
    }).sort({ createdAt: 1 });
    res.json(messages);
  } catch (err) {
    console.error('[/social/chats/:friendId]', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
