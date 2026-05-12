const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, default: 'Anonymous' },
  mobile: { type: String, required: true, unique: true },
  status: { type: String, default: 'active' },
  socketId: { type: String, default: null },
  isOnline: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema);
