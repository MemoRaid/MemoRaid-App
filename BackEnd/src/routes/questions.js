const express = require('express');
const router = express.Router();
const questionController = require('../controllers/questionController');
const auth = require('../middleware/auth');

// Get questions for a specific memory
router.get('/memory/:memory_id', auth, questionController.getMemoryQuestions);

// Get daily practice questions
router.get('/daily', auth, questionController.getDailyQuestions);

module.exports = router;