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
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ error: 'idToken required' });

    const decoded = await admin.auth().verifyIdToken(idToken);
    const { uid: googleId, email, name, picture } = decoded;

    let user = await User.findOne({ googleId });
    if (!user) {
      user = await User.create({ googleId, email, name, avatar: picture });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, user: { id: user._id, uid: user.uid, name: user.name, email: user.email, avatar: user.avatar } });
  } catch (err) {
    console.error('[/auth/google]', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
