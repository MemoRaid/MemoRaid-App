const supabase = require('../config/supabase');
const { v4: uuidv4 } = require('uuid');
const { generateQuestions } = require('./questionController');
const descriptionGuidelines = require('../utils/descriptionGuidelines');

// Add validation function
const validateDescriptions = (description, briefDescription) => {
    const errors = [];
    
    // Validate description format and content
    if (!description?.trim()) {
        errors.push('Detailed description is required');
    } else if (description.split(' ').length > 500) {
        errors.push('Detailed description exceeds 500 words');
    }

    // Validate brief description format and content
    if (!briefDescription?.trim()) {
        errors.push('Brief description is required');
    } else if (briefDescription.split(' ').length > 30) {
        errors.push('Brief description should be under 30 words');
    }

    return errors;
};

// Create a memory contributor
const createContributor = async (req, res) => {
    try {
      console.log("Received contributor data:", req.body);
      const { name, email, relationshipType, relationshipYears, userId } = req.body;
      
      // Validate input
      if (!name || !email || !relationshipType || !relationshipYears) {
        return res.status(400).json({ 
          message: 'Name, email, relationship type, and relationship years are required' 
        });
      }
      
      // Use the userId from the request if available, otherwise fall back to test ID
      const actualUserId = userId || '11111111-1111-1111-1111-111111111111';
      
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
const uploadPhoto = async (req, res) => {
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

// Create a memory
const createMemory = async (req, res) => {
    try {
        const { contributorId, photoUrl, description, briefDescription, eventDate } = req.body;
        
        // Validate required fields
        if (!contributorId || !photoUrl) {
            return res.status(400).json({ 
                message: 'Contributor ID and photo URL are required' 
            });
        }

        // Validate descriptions
        const validationErrors = validateDescriptions(description, briefDescription);
        if (validationErrors.length > 0) {
            return res.status(400).json({ 
                message: 'Invalid descriptions',
                errors: validationErrors
            });
        }

        // Get contributor details
        const { data: contributor, error: contributorError } = await supabase
            .from('memory_contributors')
            .select('user_id, name, relationship_type')
            .eq('id', contributorId)
            .single();

        if (contributorError || !contributor) {
            throw new Error('Invalid contributor ID');
        }

        // Create memory
        const { data: memory, error: memoryError } = await supabase
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
        
        if (memoryError) throw memoryError;

        // Generate questions
        try {
            const questions = await generateQuestions(memory, contributor);
            res.status(201).json({
                message: 'Memory and questions created successfully',
                memory,
                questions
            });
        } catch (questionError) {
            // Log error but don't fail the request
            console.error('Question generation failed:', questionError);
            res.status(201).json({
                message: 'Memory created but question generation failed',
                memory,
                error: questionError.message
            });
        }
    } catch (error) {
        console.error('Create memory error:', error);
        res.status(500).json({ 
            error: error.message,
            message: 'Failed to create memory'
        });
    }
};

// Get memories for a user
const getUserMemories = async (req, res) => {
    try {
        const { userId } = req.params;
        
        const { data: memories, error: memoriesError } = await supabase
            .from('memories')
            .select(`
                id,
                photo_url,
                description,
                brief_description,
                event_date,
                created_at,
                patient_id,
                memory_contributors (
                    name,
                    relationship_type
                )
            `)
            .eq('patient_id', userId)
            .order('created_at', { ascending: false });
        
        if (memoriesError) throw memoriesError;
        
        res.status(200).json({
            memories: memories || []
        });
    } catch (error) {
        console.error('Get memories error:', error);
        res.status(500).json({ 
            message: 'Failed to fetch memories',
            error: error.message 
        });
    }
};

// Get a single memory
const getMemory = async (req, res) => {
    try {
        const { memoryId } = req.params;
        const { data: memory, error } = await supabase
            .from('memories')
            .select('*')
            .eq('id', memoryId)
            .single();

        if (error) throw error;
        res.json({ memory });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
  
// Delete a memory
const deleteMemory = async (req, res) => {
    try {
        const { memoryId } = req.params;
        const { error } = await supabase
            .from('memories')
            .delete()
            .eq('id', memoryId);

        if (error) throw error;
        res.json({ message: 'Memory deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Single export statement at the end
module.exports = {
    createContributor,
    uploadPhoto,
    createMemory,
    getUserMemories,
    getMemory,
    deleteMemory,
    validateDescriptions  // Export for testing if needed
};






