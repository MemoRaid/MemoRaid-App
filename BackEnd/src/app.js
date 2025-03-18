const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// CORS configuration - Important to allow requests from your frontend
app.use(cors({
  origin: '*',  // Allow all origins in development
  credentials: true
}));

// Middleware
app.use(express.json());

// Routes
const authRoutes = require('./routes/auth');
const memoriesRoutes = require('./routes/memories');
const questionsRoutes = require('./routes/questions');

app.use('/api/auth', authRoutes);
app.use('/api/memories', memoriesRoutes);
app.use('/api/questions', questionsRoutes);

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