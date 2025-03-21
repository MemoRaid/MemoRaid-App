const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// Update existing CORS configuration for development
app.use(cors({
  origin: '*',  // Allow all origins during development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  preflightContinue: false,
  optionsSuccessStatus: 204
}));

// Add preflight handler for OPTIONS requests
app.options('*', (req, res) => {
  res.status(204).end();
});

// Middleware
app.use(express.json());

// Routes
const authRoutes = require('./routes/auth');
const memoriesRoutes = require('./routes/memories');
const questionsRoutes = require('./routes/questions');
const quizRoutes = require('./routes/quiz');

app.use('/api/auth', authRoutes);
app.use('/api/memories', memoriesRoutes);
app.use('/api/questions', questionsRoutes);
app.use('/api/quiz-results', quizRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;