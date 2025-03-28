const express = require('express');
const router = express.Router();
const memoryController = require('../controllers/memoryController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

// Create a memory contributor
router.post('/contributor', memoryController.createContributor);

// Upload a photo
router.post('/upload', upload.single('photo'), memoryController.uploadPhoto);

// Create a memory
router.post('/', memoryController.createMemory);



//remove auth and check 

// Add this route to handle current user memories
router.get('/user/me', auth, (req, res) => {
  req.params.userId = req.user.id;
  memoryController.getUserMemories(req, res);
});

// Get memories for a user
router.get('/user/:userId', auth, memoryController.getUserMemories);

// Get a single memory
router.get('/:memoryId', auth, memoryController.getMemory);

// Delete a memory
router.delete('/:memoryId', auth, memoryController.deleteMemory);

module.exports = router;