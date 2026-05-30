const admin = require('firebase-admin');

async function sendPushNotification(fcmToken, title, body, data = {}) {
  if (!fcmToken) return;

  try {
    const message = {
      token: fcmToken,
      notification: {
        title,
        body
      },
      data
    };

    // Only send if firebase admin is initialized
    if (admin.apps.length > 0) {
      await admin.messaging().send(message);
      console.log(`Push notification sent successfully to ${fcmToken}`);
    } else {
      console.warn('Firebase Admin not initialized. Skipping push notification.');
    }
  } catch (error) {
    console.error('Error sending push notification:', error);
  }
}

module.exports = {
  sendPushNotification
};
