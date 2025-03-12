const supabase = require('../config/supabase');
const gemini = require('../config/gemini');

// Generate questions for a memory
exports.generateQuestions = async (req, res) => {
    try {
      const { memoryId } = req.params;
      
      // Get the memory details
      const { data: memory, error: memoryError } = await supabase
        .from('memories')
        .select(`
          id,
          photo_url,
          description,
          event_date,
          contributor_id,
          memory_contributors (
            name,
            relationship_type,
            user_id
          )
        `)
        .eq('id', memoryId)
        .single();
      
      if (memoryError) {
        return res.status(404).json({ message: 'Memory not found' });
      }
      
      // Using Gemini AI to generate questions
      const prompt = `
        Generate 5 questions about this memory that would help someone with amnesia recall details:
        
        Description: ${memory.description}
        Relationship: This memory is from a ${memory.memory_contributors.relationship_type} named ${memory.memory_contributors.name}
        ${memory.event_date ? `Date: This happened on ${memory.event_date}` : ''}
        
        For each question:
        1. Make it specific to the description provided
        2. Include a correct answer based on the description
        3. Assign a difficulty level (1-5)
        4. Assign points (5-20 based on difficulty)
        
        Format the response as JSON with this structure for each question:
        {
          "question": "Question text here?",
          "correct_answer": "Correct answer here",
          "difficulty": 3,
          "points": 15
        }
      `;
      
      // Call Gemini API
      const result = await gemini.generateContent(prompt);
      let questionsData;
      
      try {
        // Parse the response to get structured data
        const responseText = result.response.text();
        const jsonStr = responseText.substring(
          responseText.indexOf('['),
          responseText.lastIndexOf(']') + 1
        );
        questionsData = JSON.parse(jsonStr);
      } catch (parseError) {
        console.error('Error parsing Gemini response:', parseError);
        return res.status(500).json({ 
          message: 'Failed to parse AI-generated questions', 
          error: parseError.message 
        });
      }
      
      // Save generated questions to database
      const questionsToInsert = questionsData.map(q => ({
        memory_id: memoryId,
        question: q.question,
        correct_answer: q.correct_answer,
        points: q.points
      }));
      
      const { data: questions, error: insertError } = await supabase
        .from('questions')
        .insert(questionsToInsert)
        .select();
      
      if (insertError) {
        return res.status(500).json({ 
          message: 'Error saving generated questions', 
          error: insertError.message 
        });
      }
      
      res.status(201).json({
        message: 'Questions generated successfully',
        questions
      });
    } catch (error) {
      console.error('Generate questions error:', error);
      res.status(500).json({ 
        message: 'Server error generating questions', 
        error: error.message 
      });
    }
};

// Get questions for a memory
exports.getMemoryQuestions = async (req, res) => {
    try {
      const { memoryId } = req.params;
      
      const { data: questions, error } = await supabase
        .from('questions')
        .select('*')
        .eq('memory_id', memoryId);
      
      if (error) {
        return res.status(500).json({ 
          message: 'Error fetching questions', 
          error: error.message 
        });
      }
      
      res.status(200).json({
        questions
      });
    } catch (error) {
      console.error('Get questions error:', error);
      res.status(500).json({ 
        message: 'Server error fetching questions', 
        error: error.message 
      });
    }
  };
  
  