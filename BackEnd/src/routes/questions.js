const express = require('express');
const router = express.Router();
const questionController = require('../controllers/questionController');
const auth = require('../middleware/auth');

// Generate questions for a memory
router.post('/generate/:memoryId', auth, questionController.generateQuestions);

// Get questions for a memory
router.get('/memory/:memoryId', auth, questionController.getMemoryQuestions);

// Get daily questions for a user
router.get('/daily', auth, questionController.getDailyQuestions);

// Submit user's answer to a question
router.post('/answer/:questionId', auth, questionController.submitAnswer);

// Get user's progress and statistics
router.get('/progress', auth, questionController.getUserProgress);

module.exports = router;