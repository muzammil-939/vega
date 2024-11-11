// Import the Firebase Functions SDK
const functions = require("firebase-functions");

// Import Firebase Admin SDK and initialize the app
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.database(); // Initialize Realtime Database

/**
 * Cloud Function to handle chat messages.
 * This function listens for HTTPS callable requests, stores the message,
 * and retrieves a bot response.
 */
exports.chatBotResponse = functions.https.onCall(async (data, context) => {
  const userMessage = data.message;
  const userId = context.auth?.uid || "anonymous";

  // Log the received message for debugging purposes
  console.log("Received message from user:", userMessage);

  if (!userMessage) {
    console.log("Error: No message received from user.");
    return {text: "Error: No message received."};
  }

  // Create a new message entry in the Realtime Database under 'messages'
  const messageRef = db.ref("chat/messages").push();
  const userMessageData = {
    userId: userId,
    message: userMessage,
    timestamp: admin.database.ServerValue.TIMESTAMP,
    sender: "user",
  };

  // Store the user's message in the database
  await messageRef.set(userMessageData);

  // Basic keyword-based bot response logic
  let botResponse;
  const messageLower = userMessage.toLowerCase();

  if (messageLower.includes("hello")) {
    botResponse = "Hello! How are you today?";
  } else if (messageLower.includes("bye")) {
    botResponse = "Goodbye! Have a great day!";
  } else if (messageLower.includes("help")) {
    botResponse = "I'm here to help!";
  } else {
    botResponse = `You said: ${userMessage}`;
  }

  // Store the bot's response in the database
  const botMessageData = {
    userId: "bot",
    message: botResponse,
    timestamp: admin.database.ServerValue.TIMESTAMP,
    sender: "bot",
  };

  await messageRef.parent.push(botMessageData);

  // Log the response being sent back to the user
  console.log("Sending response to user:", botResponse);

  // Return the bot's response
  return {text: botResponse};
});
