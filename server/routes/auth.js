const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Otp = require('../models/Otp');
const router = express.Router();

// Send OTP (mock implementation - replace with Twilio in production)
router.post('/login', async (req, res) => {
  try {
    const { mobile } = req.body;
    if (!mobile) return res.status(400).json({ error: 'Mobile required' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 min

    await Otp.findOneAndDelete({ mobile });
    await Otp.create({ mobile, otp, expiresAt });

    // TODO: Send OTP via Twilio
    // const twilio = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    // await twilio.messages.create({
    //   body: `Your TalkToss OTP is: ${otp}`,
    //   from: process.env.TWILIO_PHONE_NUMBER,
    //   to: mobile
    // });

    console.log(`OTP for ${mobile}: ${otp}`); // For dev only
    res.json({ message: 'OTP sent' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Verify OTP
router.post('/verify-otp', async (req, res) => {
  try {
    const { mobile, otp } = req.body;
    if (!mobile || !otp) return res.status(400).json({ error: 'Mobile and OTP required' });

    const otpDoc = await Otp.findOne({ mobile, otp });
    if (!otpDoc || otpDoc.expiresAt < new Date()) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    let user = await User.findOne({ mobile });
    if (!user) {
      user = await User.create({ mobile, name: `User${Math.floor(Math.random() * 10000)}` });
    }

    await Otp.findByIdAndDelete(otpDoc._id);

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, user: { id: user._id, name: user.name, mobile: user.mobile } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
