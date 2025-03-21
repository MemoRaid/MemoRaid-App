const supabase = require('../config/supabase');
const gemini = require('../config/gemini');

// Internal generator function
const generateQuestions = async (memory, contributorDetails) => {
    try {
        console.log('Starting question generation for memory:', memory.id);
        
        // Validate memory ID
        if (!memory.id) {
            throw new Error('Invalid memory ID');
        }

        const model = await gemini.getModel();

        const promptText = `Generate 5 multiple-choice questions to help an amnesia patient recall this memory. Return ONLY a JSON array.

Context:
- Description: ${memory.description}
- Person: ${contributorDetails.name} (${contributorDetails.relationship_type})
${memory.event_date ? `- Date: ${memory.event_date}` : ''}

Requirements:
- Questions should help patient gradually recall details
- Start with simpler questions about visible elements
- Progress to more specific memory details
- Each question must have exactly 4 options
- Last option must always be "I don't remember"
- Wrong options should be plausible but clearly incorrect
- Difficulty increases progressively (1-5)

Format response exactly like this:
[{
    "question": "Who can you see in this photo?",
    "options": [
        "Mom and Dad",
        "Only Dad",
        "The whole family",
        "I don't remember"
    ],
    "correct_option_index": 0,
    "difficulty": 1,
    "points": 5
}]`;

        const result = await model.generateContent([promptText]);
        const response = await result.response;
        let text = response.text();
        
        // Clean up and parse JSON
        text = text.replace(/```json\n|\n```/g, '').trim();
        
        try {
            const questions = JSON.parse(text);
            
            // Enhanced validation
            if (!Array.isArray(questions) || questions.length === 0) {
                throw new Error('Invalid question format received');
            }

            // More detailed validation with specific error messages
            questions.forEach((q, index) => {
                const errors = [];
                if (!q.question) errors.push('Question text missing');
                if (!Array.isArray(q.options)) errors.push('Options must be an array');
                if (q.options.length !== 4) errors.push('Must have exactly 4 options');
                if (q.options[3] !== "I don't remember") errors.push('Last option must be "I don\'t remember"');
                if (q.correct_option_index === undefined) errors.push('Correct option index missing');
                
                if (errors.length > 0) {
                    throw new Error(`Question ${index + 1} validation failed: ${errors.join(', ')}`);
                }
            });

            // Format questions for database insertion
            const formattedQuestions = questions.map(q => ({
                memory_id: memory.id,
                patient_id: memory.patient_id,
                question_text: q.question,
                options: JSON.stringify(q.options), // Convert to JSON string
                correct_option_index: parseInt(q.correct_option_index),
                correct_answer: q.options[q.correct_option_index], // Add this line
                difficulty_level: Math.min(Math.max(parseInt(q.difficulty), 1), 5),
                points: Math.min(Math.max(parseInt(q.points), 5), 20)
            }));

            // Save to database with better error handling
            const { data: savedQuestions, error } = await supabase
                .from('questions')
                .insert(formattedQuestions)
                .select();

            if (error) {
                console.error('Database insertion error:', error);
                throw new Error(`Failed to save questions: ${error.message}`);
            }

            return savedQuestions;

        } catch (parseError) {
            console.error('Question generation error:', parseError);
            throw new Error('Failed to generate valid questions: ' + parseError.message);
        }

    } catch (error) {
        console.error('Question generation error:', error);
        throw error;
    }
};

// Get questions for a specific memory
const getMemoryQuestions = async (req, res) => {
    try {
        const { memory_id } = req.params;
        // TESTING ONLY: Use query parameter instead of auth
        const patient_id = req.query.patient_id || (req.user && req.user.id);
         
        if (!patient_id) {
            return res.status(400).json({ error: 'Patient ID is required' });
        }
        // First verify memory belongs to patient
        const { data: memory, error: memoryError } = await supabase
            .from('memories')
            .select('id')
            .eq('id', memory_id)
            .eq('patient_id', patient_id)
            .single();

        if (memoryError || !memory) {
            return res.status(403).json({ 
                error: 'Memory not found or access denied' 
            });
        }

        // Update the questions query section
        const { data: questions, error } = await supabase
            .from('questions')
            .select(`
                id,
                question_text,
                options,
                difficulty_level,
                points,
                memory_id,
                correct_option_index,  
                memories (
                    photo_url,
                    brief_description,
                    description    
                )
            `)
            .eq('memory_id', memory_id)
            .eq('patient_id', patient_id)  // Add this line
            .order('difficulty_level', { ascending: true });
        
        if (error) throw error;

        // Update the formatting section
        const formattedQuestions = questions.map(q => ({
            id: q.id,
            question: q.question_text,
            options: JSON.parse(q.options),
            difficulty: q.difficulty_level,
            points: q.points,
            memory: {
                id: q.memory_id,
                photo_url: q.memories.photo_url,
                brief_description: q.memories.brief_description
            },
            correct_option_index: q.correct_option_index
        }));

        res.json({ 
            success: true,
            questions: formattedQuestions,
            total: formattedQuestions.length
        });
    } catch (error) {
        console.error('Error fetching memory questions:', error);
        res.status(500).json({ error: error.message });
    }
};

// Get daily practice questions
const getDailyQuestions = async (req, res) => {
    try {
        const patient_id = req.user.id;

        // Get random selection of questions from patient's memories
        const { data: questions, error } = await supabase
            .from('questions')
            .select(`
                id,
                question_text,
                options,
                difficulty_level,
                points,
                memory_id,
                memories (
                    photo_url,
                    brief_description
                )
            `)
            .eq('patient_id', patient_id)
            .order('created_at', { ascending: false })
            .limit(5);

        if (error) throw error;

        const formattedQuestions = questions.map(q => ({
            ...q,
            options: JSON.parse(q.options),
            correct_answer: q.correct_answer || q.options[q.correct_option_index]
        }));

        res.json({ questions: formattedQuestions });
    } catch (error) {
        console.error('Error fetching daily questions:', error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    getMemoryQuestions,
    getDailyQuestions,
    generateQuestions  // Your existing function
};

