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

  