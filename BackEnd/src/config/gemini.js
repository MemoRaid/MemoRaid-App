const { GoogleGenerativeAI } = require('@google/generative-ai');
const { GoogleAuth } = require('google-auth-library');
const path = require('path');
const fs = require('fs');

// Export a Promise that resolves to the model
module.exports = (async () => {
    try {
        // Load service account credentials
        const serviceAccountPath = path.join(__dirname, '../../service-account.json');
        if (!fs.existsSync(serviceAccountPath)) {
            throw new Error('Service account file not found');
        }

        // Create auth client
        const auth = new GoogleAuth({
            keyFile: serviceAccountPath,
            scopes: ['https://www.googleapis.com/auth/cloud-platform']
        });

        // Get access token
        const authClient = await auth.getClient();
        const token = await authClient.getAccessToken();
        
        // Initialize Gemini with access token
        const genAI = new GoogleGenerativeAI(token.token);

        // Get model
        const model = genAI.getGenerativeModel({ 
            model: "gemini-1.5-pro", // Use stable version
            generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 8192,
            }
        });

        console.log('Gemini API initialized successfully with service account');
        return model;

    } catch (error) {
        console.error('Error initializing Gemini API:', error);
        throw error;
    }
})();