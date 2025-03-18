const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const questionController = require('../controllers/questionController');

// Get questions for a specific memory
router.get('/memory/:memory_id', auth, questionController.getMemoryQuestions);

// Get daily practice questions
router.get('/daily', auth, questionController.getDailyQuestions);

module.exports = router;