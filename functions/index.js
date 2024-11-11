const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.database();

/**
 * Cloud Function to store chat message between users.
 */
exports.storeChatMessage = functions.https.onCall(async (data, context) => {
  const userMessage = data.message;
  const senderId = context.auth?.uid;
  const receiverId = data.receiverId;

  if (!userMessage || !senderId || !receiverId) {
    return {text: "Invalid input."};
  }

  // Create sessionId (sort user IDs to ensure uniqueness)
  const sessionId = senderId < receiverId ?
    `${senderId}_${receiverId}` :
    `${receiverId}_${senderId}`;

  const messageRef = db.ref(`chat/sessions/${sessionId}/messages`).push();
  const userMessageData = {
    userId: senderId,
    message: userMessage,
    timestamp: admin.database.ServerValue.TIMESTAMP,
    sender: senderId,
  };

  // Store user's message in the database
  await messageRef.set(userMessageData);

  return {text: "Message sent successfully."};
});
