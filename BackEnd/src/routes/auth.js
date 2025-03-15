const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

router.post('/google', authController.googleSignIn);

// Register a new user
router.post('/register', authController.register);

// Login user
router.post('/login', authController.login);

// Generate share link for memory contributors
router.post('/generate-share-link', auth, authController.generateShareLink);

// Verify share token
router.get('/verify-token/:token', authController.verifyShareToken);

// Get current user
router.get('/me', auth, authController.getCurrentUser);

// Add these new endpoints for email verification
router.post('/request-verification', authController.requestEmailVerification);
router.post('/verify-email', authController.verifyEmail);

module.exports = router;