const express = require('express');
const Call = require('../models/Call');
const authMiddleware = require('../middleware/auth');
const router = express.Router();

router.post('/end', authMiddleware, async (req, res) => {
  try {
    const { callId } = req.body;
    if (!callId) return res.status(400).json({ error: 'callId required' });

    await Call.findByIdAndUpdate(callId, { endedAt: new Date(), status: 'ended' });
    res.json({ message: 'Call ended' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
