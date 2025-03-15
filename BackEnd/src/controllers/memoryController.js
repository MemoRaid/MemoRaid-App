const supabase = require('../config/supabase');
const { v4: uuidv4 } = require('uuid');

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

// Create a memory
exports.createMemory = async (req, res) => {
    try {
      const { contributorId, photoUrl, description, eventDate } = req.body;
      
      // Validate input
      if (!contributorId || !photoUrl || !description) {
        return res.status(400).json({ 
          message: 'Contributor ID, photo URL, and description are required' 
        });
      }
      
      // Check if contributor exists
      const { data: contributor, error: contributorError } = await supabase
        .from('memory_contributors')
        .select('id')
        .eq('id', contributorId)
        .single();
      
      if (contributorError) {
        return res.status(404).json({ message: 'Contributor not found' });
      }
      
      // Create memory
      const { data: memory, error } = await supabase
        .from('memories')
        .insert([
          { 
            contributor_id: contributorId,
            photo_url: photoUrl,
            description,
            event_date: eventDate || null
          }
        ])
        .select();
      
      if (error) {
        return res.status(500).json({ 
          message: 'Error creating memory', 
          error: error.message 
        });
      }
      
      res.status(201).json({
        message: 'Memory created successfully',
        memory: memory[0]
      });
    } catch (error) {
      console.error('Create memory error:', error);
      res.status(500).json({ 
        message: 'Server error creating memory', 
        error: error.message 
      });
    }
};

// Get memories for a user
exports.getUserMemories = async (req, res) => {
    try {
      const { userId } = req.params;
      
      // Get all contributors for this user
      const { data: contributors, error: contributorsError } = await supabase
        .from('memory_contributors')
        .select('id')
        .eq('user_id', userId);
      
      if (contributorsError) {
        return res.status(500).json({ 
          message: 'Error fetching contributors', 
          error: contributorsError.message 
        });
      }
      
      if (!contributors.length) {
        return res.status(200).json({ memories: [] });
      }
      
      // Get all memories from these contributors
      const contributorIds = contributors.map(c => c.id);
      
      const { data: memories, error: memoriesError } = await supabase
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
            relationship_type
          )
        `)
        .in('contributor_id', contributorIds)
        .order('created_at', { ascending: false });
      
      if (memoriesError) {
        return res.status(500).json({ 
          message: 'Error fetching memories', 
          error: memoriesError.message 
        });
      }
      
      res.status(200).json({
        memories
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
  
  
  