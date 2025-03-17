const { GoogleGenerativeAI } = require('@google/generative-ai');
const path = require('path');

// Load service account credentials
const serviceAccount = {
  type: "service_account",
  project_id: "smiling-matrix-453619-k7",
  private_key_id: "b0f865b135d40a0200d144cc68bb75bcfeca5256",
  private_key: "-----BEGIN PRIVATE KEY-----\n...", // Your private key
  client_email: "memoraid-gemini-api@smiling-matrix-453619-k7.iam.gserviceaccount.com",
  token_uri: "https://oauth2.googleapis.com/token"
};

// Initialize the Gemini API with service account
const genAI = new GoogleGenerativeAI({
  credentials: serviceAccount,
  projectId: serviceAccount.project_id
});

// Get the model with specific configuration
const model = genAI.getGenerativeModel({ 
  model: "gemini-1.5-flash",  
  generationConfig: {
    temperature: 0.7,
    maxOutputTokens: 2048,
  }
});

module.exports = model;