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
  