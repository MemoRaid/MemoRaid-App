const supabase = require('../config/supabase');
const { v4: uuidv4 } = require('uuid');
const { generateQuestions } = require('./questionController');
const descriptionGuidelines = require('../utils/descriptionGuidelines');

// Add this function at the top
const validateDescriptions = (description, briefDescription) => {
    const errors = [];
    
    if (!description) {
        errors.push('Detailed description is required');
    } else if (description.split(' ').length > 500) {
        errors.push('Detailed description exceeds 500 words');
    }

    if (!briefDescription) {
        errors.push('Brief description is required');
    } else if (briefDescription.split(' ').length > 30) {
        errors.push('Brief description should be under 30 words');
    }

    return errors;
};

// Create a memory contributor
exports.createContributor = async (req, res) => {
    try {
      console.log("Received contributor data:", req.body);
      const { name, email, relationshipType, relationshipYears, userId } = req.body;
      
      // Validate input
      if (!name || !email || !relationshipType || !relationshipYears) {
        return res.status(400).json({ 
          message: 'Name, email, relationship type, and relationship years are required' 
        });
      }
      
      // For testing, we'll use a default UUID if no userId is provided
      const actualUserId = userId || '00000000-0000-0000-0000-000000000000';
      
      // Create memory contributor without checking user existence first
      const { data: contributor, error } = await supabase
        .from('memory_contributors')
        .insert([
          { 
            user_id: actualUserId,
            name,
            email,
            relationship_type: relationshipType,
            relationship_years: relationshipYears
          }
        ])
        .select();
      
      if (error) {
        console.error("Supabase error:", error);
        return res.status(500).json({ 
          message: 'Error creating memory contributor', 
          error: error.message 
        });
      }
      
      res.status(201).json({
        message: 'Memory contributor created successfully',
        id: contributor[0].id
      });
    } catch (error) {
      console.error('Create contributor error:', error);
      res.status(500).json({ 
        message: 'Server error creating memory contributor', 
        error: error.message 
      });
    }
};
  
// Upload a photo
exports.uploadPhoto = async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
      }
      
      // Generate unique file name
      const fileExtension = req.file.originalname.split('.').pop();
      const fileName = `${uuidv4()}.${fileExtension}`;
      
      // Upload file to Supabase Storage
      const { data, error } = await supabase.storage
        .from('memory-photos')
        .upload(fileName, req.file.buffer, {
          contentType: req.file.mimetype,
          cacheControl: '3600'
        });
      
      if (error) {
        console.error('Storage error:', error);
        return res.status(500).json({ 
          message: 'Error uploading photo', 
          error: error.message 
        });
      }
      
      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from('memory-photos')
        .getPublicUrl(fileName);
  
      console.log('Generated public URL:', publicUrl);
  
      res.status(200).json({
        message: 'Photo uploaded successfully',
        photoUrl: publicUrl
      });
    } catch (error) {
      console.error('Photo upload error:', error);
      res.status(500).json({ 
        message: 'Server error uploading photo', 
        error: error.message 
      });
    }
};

// Modify the createMemory function
exports.createMemory = async (req, res) => {
    try {
        const { contributorId, photoUrl, description, briefDescription, eventDate } = req.body;
        
        // Validate descriptions
        const validationErrors = validateDescriptions(description, briefDescription);
        if (validationErrors.length > 0) {
            return res.status(400).json({ 
                message: 'Invalid descriptions',
                errors: validationErrors,
                guidelines: descriptionGuidelines // Return guidelines for reference
            });
        }

        // Get contributor details
        const { data: contributor, error: contributorError } = await supabase
            .from('memory_contributors')
            .select('user_id')
            .eq('id', contributorId)
            .single();

        if (contributorError) throw contributorError;

        // Create memory with both descriptions
        const { data: memory, error } = await supabase
            .from('memories')
            .insert([{ 
                contributor_id: contributorId,
                patient_id: contributor.user_id,
                photo_url: photoUrl,
                description,
                brief_description: briefDescription,
                event_date: eventDate || null
            }])
            .select()
            .single();
        
        if (error) throw error;

        // Generate questions using full description
        const questions = await generateQuestions(memory, contributor);
        
        res.status(201).json({
            message: 'Memory and questions created successfully',
            memory,
            questions
        });
    } catch (error) {
        console.error('Create memory error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Get memories for a user
exports.getUserMemories = async (req, res) => {
    try {
      const { userId } = req.params;
      
      // Get memories directly using patient_id instead of going through contributors
      const { data: memories, error: memoriesError } = await supabase
        .from('memories')
        .select(`
          id,
          photo_url,
          description,
          event_date,
          created_at,
          patient_id,
          memory_contributors (
            name,
            relationship_type
          )
        `)
        .eq('patient_id', userId)  // Direct query using patient_id
        .order('created_at', { ascending: false });
      
      if (memoriesError) {
        return res.status(500).json({ 
          message: 'Error fetching memories', 
          error: memoriesError.message 
        });
      }
      
      res.status(200).json({
        memories: memories || []
      });
    } catch (error) {
      console.error('Get memories error:', error);
      res.status(500).json({ 
        message: 'Server error fetching memories', 
        error: error.message 
      });
    }
};

// Get a single memory
exports.getMemory = async (req, res) => {
    try {
      const { memoryId } = req.params;
      
      const { data: memory, error } = await supabase
        .from('memories')
        .select(`
          id,
          photo_url,
          description,
          event_date,
          created_at,
          contributor_id,
          memory_contributors (
            name,
            relationship_type,
            user_id
          )
        `)
        .eq('id', memoryId)
        .single();
      
      if (error) {
        return res.status(404).json({ message: 'Memory not found' });
      }
      
      res.status(200).json({
        memory
      });
    } catch (error) {
      console.error('Get memory error:', error);
      res.status(500).json({ 
        message: 'Server error fetching memory', 
        error: error.message 
      });
    }
};
  
// Delete a memory
exports.deleteMemory = async (req, res) => {
    try {
      const { memoryId } = req.params;
      
      // Check if memory exists and belongs to a contributor of the current user
      const { data: memory, error: memoryError } = await supabase
        .from('memories')
        .select(`
          id,
          contributor_id,
          memory_contributors (
            user_id
          )
        `)
        .eq('id', memoryId)
        .single();
      
      if (memoryError) {
        return res.status(404).json({ message: 'Memory not found' });
      }
      
      // Check if the current user is authorized to delete this memory
      if (memory.memory_contributors.user_id !== req.user.id) {
        return res.status(403).json({ message: 'Not authorized to delete this memory' });
      }
      
      // Delete the memory
      const { error: deleteError } = await supabase
        .from('memories')
        .delete()
        .eq('id', memoryId);
      
      if (deleteError) {
        return res.status(500).json({ 
          message: 'Error deleting memory', 
          error: deleteError.message 
        });
      }
      
      res.status(200).json({
        message: 'Memory deleted successfully'
      });
    } catch (error) {
      console.error('Delete memory error:', error);
      res.status(500).json({ 
        message: 'Server error deleting memory', 
        error: error.message 
      });
    }
};

// Add endpoint to get description guidelines
exports.getDescriptionGuidelines = async (req, res) => {
    res.status(200).json({ guidelines: descriptionGuidelines });
};

// Add this before the module.exports
const getDescriptionGuidelines = async (req, res) => {
    try {
        res.status(200).json({ 
            success: true,
            guidelines: descriptionGuidelines 
        });
    } catch (error) {
        console.error('Error getting guidelines:', error);
        res.status(500).json({ 
            success: false,
            error: 'Failed to get guidelines' 
        });
    }
};

// Update exports to include the new function
module.exports = {
    createContributor: exports.createContributor,
    uploadPhoto: exports.uploadPhoto,
    createMemory: exports.createMemory,
    getUserMemories: exports.getUserMemories,
    getMemory: exports.getMemory,
    deleteMemory: exports.deleteMemory,
    getDescriptionGuidelines // Add this line
};

// Add this with your other exports
exports.getDescriptionGuidelines = (req, res) => {
    try {
        res.status(200).json({ 
            success: true,
            guidelines: descriptionGuidelines 
        });
    } catch (error) {
        console.error('Error getting guidelines:', error);
        res.status(500).json({ 
            success: false,
            error: 'Failed to get guidelines' 
        });
    }
};




