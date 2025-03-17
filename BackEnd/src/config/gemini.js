const { GoogleGenerativeAI } = require('@google/generative-ai');
const path = require('path');
const fs = require('fs');

// Load service account credentials from file
const serviceAccountPath = path.join(__dirname, '../../service-account.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

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