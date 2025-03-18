const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// CORS configuration - With specific Flutter web port
app.use(cors({
  origin: ['*',
    'http://localhost:3000', 
    'http://localhost:3001', 
    'http://192.168.251.135:3000',
    'http://localhost:49680',  // Add your Flutter web app port
    'http://127.0.0.1:49680'   // Also add with 127.0.0.1
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
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