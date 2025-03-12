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

// Get daily questions for a user
exports.getDailyQuestions = async (req, res) => {
    try {
      const userId = req.user.id;
      
      // Get a random memory for this user that has questions
      const { data: memories, error: memoriesError } = await supabase
        .from('memories')
        .select(`
          id,
          photo_url,
          description,
          memory_contributors!inner (
            id,
            user_id
          )
        `)
        .eq('memory_contributors.user_id', userId)
        .order('created_at', { ascending: false });
      
      if (memoriesError) {
        return res.status(500).json({ 
          message: 'Error fetching memories', 
          error: memoriesError.message 
        });
      }
      
      if (!memories.length) {
        return res.status(404).json({ message: 'No memories found for this user' });
      }
      
      // Get a random memory from the list
      const randomMemory = memories[Math.floor(Math.random() * memories.length)];
      
      // Get questions for this memory
      const { data: questions, error: questionsError } = await supabase
        .from('questions')
        .select('*')
        .eq('memory_id', randomMemory.id)
        .limit(5);
      
      if (questionsError) {
        return res.status(500).json({ 
          message: 'Error fetching questions', 
          error: questionsError.message 
        });
      }
      
      // If no questions, generate them
      if (!questions.length) {
        // Call the generate questions function
        // This would typically be a direct function call, but for API purposes we'll return a message
        return res.status(200).json({
          message: 'No questions available yet. Need to generate questions for this memory.',
          memory: randomMemory,
          needsQuestions: true
        });
      }
      
      res.status(200).json({
        memory: randomMemory,
        questions
      });
    } catch (error) {
      console.error('Get daily questions error:', error);
      res.status(500).json({ 
        message: 'Server error fetching daily questions', 
        error: error.message 
      });
    }
};

// Submit user's answer to a question
exports.submitAnswer = async (req, res) => {
    try {
      const { questionId } = req.params;
      const { answer } = req.body;
      const userId = req.user.id;
      
      if (!answer) {
        return res.status(400).json({ message: 'Answer is required' });
      }
      
      // Get the question to check against correct answer
      const { data: question, error: questionError } = await supabase
        .from('questions')
        .select('*')
        .eq('id', questionId)
        .single();
      
      if (questionError) {
        return res.status(404).json({ message: 'Question not found' });
      }
      
      // Simple check if answer is correct
      // In a real app, you'd use AI for more sophisticated answer checking
      const correctKeywords = question.correct_answer.toLowerCase().split(' ');
      const userKeywords = answer.toLowerCase().split(' ');
      
      // Check if answer contains key words from correct answer
      // This is a very simple algorithm - in production you'd use better comparison
      const matchCount = correctKeywords.filter(word => 
        userKeywords.some(userWord => userWord.includes(word) || word.includes(userWord))
      ).length;
      
      const accuracy = matchCount / correctKeywords.length;
      const isCorrect = accuracy >= 0.5; // Consider it correct if 50% of keywords match
      
      // Save the user's answer
      const { data: savedAnswer, error: saveError } = await supabase
        .from('user_answers')
        .insert([
          {
            user_id: userId,
            question_id: questionId,
            answer,
            is_correct: isCorrect
          }
        ])
        .select();
      
      if (saveError) {
        return res.status(500).json({ 
          message: 'Error saving answer', 
          error: saveError.message 
        });
      }
      
      // If correct, award points
      if (isCorrect) {
        await supabase
          .from('user_rewards')
          .insert([
            {
              user_id: userId,
              points: question.points,
              reward_type: 'question_correct'
            }
          ]);
      }
      
      res.status(200).json({
        message: isCorrect ? 'Correct answer!' : 'Incorrect answer',
        result: {
          isCorrect,
          points: isCorrect ? question.points : 0,
          correctAnswer: question.correct_answer
        }
      });
    } catch (error) {
      console.error('Submit answer error:', error);
      res.status(500).json({ 
        message: 'Server error submitting answer', 
        error: error.message 
      });
    }
};

// Get user's progress and statistics
exports.getUserProgress = async (req, res) => {
    try {
      const userId = req.user.id;
      
      // Get total correct answers
      const { count: correctCount, error: correctError } = await supabase
        .from('user_answers')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId)
        .eq('is_correct', true);
      
      if (correctError) {
        return res.status(500).json({ 
          message: 'Error fetching correct answers', 
          error: correctError.message 
        });
      }
      
      // Get total answers
      const { count: totalCount, error: totalError } = await supabase
        .from('user_answers')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId);
      
      if (totalError) {
        return res.status(500).json({ 
          message: 'Error fetching total answers', 
          error: totalError.message 
        });
      }
      
      // Get total points
      const { data: rewards, error: rewardsError } = await supabase
        .from('user_rewards')
        .select('points')
        .eq('user_id', userId);
      
      if (rewardsError) {
        return res.status(500).json({ 
          message: 'Error fetching rewards', 
          error: rewardsError.message 
        });
      }
      
      const totalPoints = rewards.reduce((sum, reward) => sum + reward.points, 0);
      
      const accuracyRate = totalCount > 0 ? (correctCount / totalCount * 100).toFixed(1) : 0;
      
      res.status(200).json({
        progress: {
          correctAnswers: correctCount,
          totalAnswers: totalCount,
          accuracyRate: `${accuracyRate}%`,
          totalPoints: totalPoints
        }
      });
    } catch (error) {
      console.error('Get user progress error:', error);
      res.status(500).json({ 
        message: 'Server error fetching user progress', 
        error: error.message 
      });
    }
};
  
  
  
  
  