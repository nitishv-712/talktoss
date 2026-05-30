const express = require('express');
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const User = require('../models/User');
const router = express.Router();

// Initialize Firebase Admin (uses GOOGLE_APPLICATION_CREDENTIALS env or service account)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)),
  });
}

// Google Sign-In via Firebase ID token
router.post('/google', async (req, res) => {
  try {
    const { idToken, fcmToken } = req.body;
    if (!idToken) return res.status(400).json({ error: 'idToken required' });

    const decoded = await admin.auth().verifyIdToken(idToken);
    const { uid: googleId, email, name, picture } = decoded;

    let user = await User.findOne({ googleId });
    if (!user) {
      user = await User.create({ googleId, email, name, avatar: picture, fcmToken });
    } else if (fcmToken && user.fcmToken !== fcmToken) {
      user.fcmToken = fcmToken;
      await user.save();
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, user: { id: user._id, uid: user.uid, name: user.name, email: user.email, avatar: user.avatar } });
  } catch (err) {
    console.error('[/auth/google]', err);
    res.status(500).json({ error: err.message });
  }
});

// Update FCM token
router.post('/fcm-token', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: 'Unauthorized' });

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { fcmToken } = req.body;
    if (fcmToken) {
      await User.findByIdAndUpdate(decoded.userId, { fcmToken });
    }

    res.json({ success: true });
  } catch (err) {
    console.error('[/auth/fcm-token]', err);
    res.status(401).json({ error: 'Invalid token' });
  }
});

module.exports = router;
