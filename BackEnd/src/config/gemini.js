const { GoogleGenerativeAI } = require('@google/generative-ai');
const { GoogleAuth } = require('google-auth-library');
const path = require('path');
const fs = require('fs');

let model = null;

const initializeGemini = async () => {
    try {
        // Load service account credentials
        const serviceAccountPath = path.join(__dirname, '../../service-account.json');
        if (!fs.existsSync(serviceAccountPath)) {
            throw new Error('Service account file not found');
        }

        const auth = new GoogleAuth({
            keyFile: serviceAccountPath,
            scopes: ['https://www.googleapis.com/auth/cloud-platform']
        });

        const authClient = await auth.getClient();
        const token = await authClient.getAccessToken();
        
        // Initialize Gemini
        const genAI = new GoogleGenerativeAI(token.token);

        // Get model
const                 model = genAI.getGenerativeModel({ 
            model: "gemini-1.5-pro", // Use stable version
            generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 8192,
            }
        });

        return model;
    } catch (error) {
        console.error('Gemini initialization error:', error);
        throw error;
    }
};

// Export a function to get the initialized model
module.exports = {
    getModel: async () => {
        if (!model) {
            model = await initializeGemini();
        }
        return model;
    }
};