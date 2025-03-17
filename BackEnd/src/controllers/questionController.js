const supabase = require('../config/supabase');
const gemini = require('../config/gemini');

// Internal generator function
const generateQuestions = async (memory, contributorDetails) => {
    try {
        console.log('Starting question generation for memory:', memory.id);
        
        const model = await gemini.getModel();

        const promptText = `Generate 5 multiple-choice questions based on this memory. Return ONLY a JSON array, no markdown formatting or other text.

Context:
- Description: ${memory.description}
- Person: ${contributorDetails.name} (${contributorDetails.relationship_type})
${memory.event_date ? `- Date: ${memory.event_date}` : ''}

Format your response exactly like this, with no additional text or formatting:
[{
    "question": "What was the specific event described?",
    "correct_answer": "Birthday party at the beach",
    "difficulty": 1,
    "points": 5
}]

Make questions test specific memory details. Difficulty: 1-5, Points: 5-20.`;

        const result = await model.generateContent([promptText]);
        const response = await result.response;
        let text = response.text();
        
        // Clean up the response to extract just the JSON array
        text = text.replace(/```json\n|\n```/g, '').trim();
        
        // Parse and validate JSON
        try {
            const questions = JSON.parse(text);
            if (!Array.isArray(questions) || questions.length === 0) {
                throw new Error('Invalid question format received');
            }

            // Save to database with validation
            const { data: savedQuestions, error } = await supabase
                .from('questions')
                .insert(
                    questions.map(q => ({
                        memory_id: memory.id,
                        patient_id: memory.patient_id,
                        question_text: q.question,
                        correct_answer: q.correct_answer,
                        difficulty_level: Math.min(Math.max(parseInt(q.difficulty), 1), 5),
                        points: Math.min(Math.max(parseInt(q.points), 5), 20)
                    }))
                )
                .select();

            if (error) throw error;
            return savedQuestions;
        } catch (parseError) {
            console.error('JSON Parse Error:', text); // Log the actual text for debugging
            throw new Error('Failed to parse questions: ' + parseError.message);
        }

    } catch (error) {
        console.error('Question generation error:', error);
        throw error;
    }
};

module.exports = {
    generateQuestions,
    getMemoryQuestions: async (req, res) => {
        try {
            const { memory_id } = req.params;
            const { data: questions, error } = await supabase
                .from('questions')
                .select('*')
                .eq('memory_id', memory_id)
                .order('difficulty_level', { ascending: true });
                
            if (error) throw error;
            res.json({ questions });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    getDailyQuestions: async (req, res) => {
        try {
            const userId = req.user.id;
            const { data: questions, error } = await supabase
                .from('questions')
                .select('*, memories(description, photo_url)')
                .eq('patient_id', userId)
                .order('created_at', { ascending: false })
                .limit(5);
                
            if (error) throw error;
            res.json({ questions });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};

