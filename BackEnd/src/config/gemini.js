const { GoogleGenerativeAI } = require('@google/generative-ai');
const path = require('path');
const fs = require('fs');

// Load service account
const serviceAccountPath = path.join(__dirname, '..', '..', 'credentials', 'gemini-service-account.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

// Initialize the Gemini API with service account
const genAI = new GoogleGenerativeAI({
  projectId: serviceAccount.project_id,
  credentials: serviceAccount
});

// Get the model
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

module.exports = model;