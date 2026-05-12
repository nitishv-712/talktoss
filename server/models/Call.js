const mongoose = require('mongoose');

const callSchema = new mongoose.Schema({
  callerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiverId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startedAt: { type: Date, default: Date.now },
  endedAt: { type: Date, default: null },
  status: { type: String, enum: ['active', 'ended', 'missed'], default: 'active' }
});

module.exports = mongoose.model('Call', callSchema);
