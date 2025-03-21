const supabase = require('../config/supabase');

const saveQuizAttempt = async (req, res) => {
  try {
    const { patient_id, memory_id, score, correct_answers, total_questions } = req.body;
    
    if (!patient_id || !memory_id) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const { data, error } = await supabase
      .from('quiz_attempts')
      .insert([{
        patient_id,
        memory_id,
        score,
        correct_answers,
        total_questions
      }])
      .select();
    
    if (error) throw error;
    
    res.status(201).json({
      success: true,
      message: 'Quiz results saved successfully',
      data
    });
  } catch (error) {
    console.error('Error saving quiz results:', error);
    res.status(500).json({ 
      error: error.message,
      message: 'Failed to save quiz results'
    });
  }
};

module.exports = {
  saveQuizAttempt
};