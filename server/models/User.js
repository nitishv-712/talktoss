const mongoose = require('mongoose');
const { randomBytes } = require('crypto');

const userSchema = new mongoose.Schema({
  uid: { type: String, unique: true, default: () => randomBytes(4).toString('hex') },
  name: { type: String, default: 'Anonymous' },
  mobile: { type: String, unique: true, sparse: true },
  googleId: { type: String, unique: true, sparse: true },
  email: { type: String },
  avatar: { type: String },
  status: { type: String, default: 'active' },
  socketId: { type: String, default: null },
  fcmToken: { type: String, default: null },
  isOnline: { type: Boolean, default: false },
  friends: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema);
