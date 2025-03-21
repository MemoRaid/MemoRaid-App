const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

let model = null;

const initializeGemini = async () => {
    try {
        // Use API key from environment variables
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY not found in environment variables');
        }

        // Initialize Gemini with API key
        const genAI = new GoogleGenerativeAI(apiKey);

        // Get model
        const model = genAI.getGenerativeModel({ 
            model: "gemini-1.5-pro",
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

module.exports = {
    getModel: async () => {
        if (!model) {
            model = await initializeGemini();
        }
        return model;
    }
};