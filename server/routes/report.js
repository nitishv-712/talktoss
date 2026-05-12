const express = require('express');
const Report = require('../models/Report');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');
const router = express.Router();

router.post('/user', authMiddleware, async (req, res) => {
  try {
    const { reportedUserId, reason } = req.body;
    if (!reportedUserId || !reason) return res.status(400).json({ error: 'Missing fields' });

    const reported = await User.findById(reportedUserId);
    if (!reported) return res.status(404).json({ error: 'User not found' });

    await Report.create({ reportedUserId, reportedBy: req.userId, reason });

    // Auto-ban if reported 5+ times
    const reportCount = await Report.countDocuments({ reportedUserId });
    if (reportCount >= 5) {
      await User.findByIdAndUpdate(reportedUserId, { status: 'banned' });
    }

    res.json({ message: 'User reported successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
