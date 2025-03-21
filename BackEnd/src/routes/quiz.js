const express = require('express');
const router = express.Router();
const quizController = require('../controllers/quizController');

// Save quiz attempt results
router.post('/', quizController.saveQuizAttempt);

module.exports = router;

