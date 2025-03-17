const supabase = require('../config/supabase');
const gemini = require('../config/gemini');

// Generate questions for a memory
exports.generateQuestions = async (req, res) => {
    try {
        const { memoryId } = req.params;
        
        // Get memory details
        const { data: memory, error: memoryError } = await supabase
            .from('memories')
            .select(`
                id,
                description,
                event_date,
                memory_contributors (
                    name,
                    relationship_type
                )
            `)
            .eq('id', memoryId)
            .single();
        
        if (memoryError) {
            return res.status(404).json({ message: 'Memory not found' });
        }

        // Get Gemini model
        const model = await gemini.getModel();

        // Create prompt
        const prompt = {
            text: `Generate 5 questions about this memory that would help someone with amnesia recall details:
            
            Description: ${memory.description}
            Relationship: This memory is from a ${memory.memory_contributors.relationship_type} named ${memory.memory_contributors.name}
            ${memory.event_date ? `Date: This happened on ${memory.event_date}` : ''}
            
            For each question:
            1. Make it specific to the description provided
            2. Include a correct answer based on the description
            3. Assign a difficulty level (1-5)
            4. Assign points (5-20 based on difficulty)
            
            Format as JSON array. Example:
            [
                {
                    "question": "What was happening in this memory?",
                    "correct_answer": "A family dinner",
                    "difficulty": 1,
                    "points": 5
                }
            ]`
        };

        // Generate questions
        console.log('Calling Gemini API...');
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        // Parse JSON response
        const jsonMatch = text.match(/\[[\s\S]*\]/);
        if (!jsonMatch) {
            throw new Error('No valid JSON found in response');
        }

        const questions = JSON.parse(jsonMatch[0]);

        // Save questions to database
        const { data: savedQuestions, error: saveError } = await supabase
            .from('questions')
            .insert(
                questions.map(q => ({
                    memory_id: memory.id,
                    question_text: q.question,
                    correct_answer: q.correct_answer,
                    difficulty_level: q.difficulty,
                    points: q.points
                }))
            )
            .select();

        if (saveError) {
            throw saveError;
        }

        res.status(201).json({
            message: 'Questions generated and saved successfully',
            questions: savedQuestions
        });

    } catch (error) {
        console.error('Question generation error:', error);
        res.status(500).json({ 
            message: 'Failed to generate questions', 
            error: error.message 
        });
    }
};

// Internal function to generate questions automatically when memory is created
exports.generateQuestionsForNewMemory = async (memory, contributorDetails) => {
    try {
        console.log('Starting question generation for memory:', memory.id);
        
        // Get initialized Gemini model
        const model = await gemini.getModel();
        
        const prompt = {
            text: `Generate 5 questions about this memory that would help someone with amnesia recall details:
            
            Description: ${memory.description}
            Relationship: This memory is from a ${contributorDetails.relationship_type} named ${contributorDetails.name}
            ${memory.event_date ? `Date: This happened on ${memory.event_date}` : ''}
            
            For each question:
            1. Make it specific to the description provided
            2. Include a correct answer based on the description
            3. Assign a difficulty level (1-5)
            4. Assign points (5-20 based on difficulty)
            
            Format as JSON array of objects.`
        };

        console.log('Calling Gemini API...');
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();
        
        // Rest of your existing code...
    } catch (error) {
        console.error('Question generation error:', error);
        throw error;
    }
};

exports.generateQuestions = async (memory, contributorDetails) => {
    try {
        console.log('Starting question generation for memory:', memory.id);
        
        // Get Gemini model
        const model = await gemini.getModel();

        // Create prompt
        const prompt = {
            text: `Generate 5 questions about this memory that would help someone with amnesia recall details:
            
            Description: ${memory.description}
            Relationship: This memory is from a ${contributorDetails.relationship_type} named ${contributorDetails.name}
            ${memory.event_date ? `Date: This happened on ${memory.event_date}` : ''}
            
            For each question:
            1. Make it specific to the description provided
            2. Include a correct answer based on the description
            3. Assign a difficulty level (1-5)
            4. Assign points (5-20 based on difficulty)
            
            Format as JSON array of objects with this exact structure:
            [
                {
                    "question": "What was happening in this memory?",
                    "correct_answer": "A family dinner",
                    "difficulty": 1,
                    "points": 5
                }
            ]`
        };

        // Generate questions
        console.log('Calling Gemini API...');
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();
        console.log('Raw AI response:', text);

        // Parse JSON response
        const jsonMatch = text.match(/\[[\s\S]*\]/);
        if (!jsonMatch) {
            throw new Error('No valid JSON found in response');
        }

        const questions = JSON.parse(jsonMatch[0]);
        console.log('Parsed questions:', questions);

        // Validate questions format
        if (!Array.isArray(questions) || questions.length === 0) {
            throw new Error('Invalid questions format received from AI');
        }

        // Save questions to database
        const { data: savedQuestions, error: saveError } = await supabase
            .from('questions')
            .insert(
                questions.map(q => ({
                    memory_id: memory.id,
                    patient_id: memory.patient_id,
                    question_text: q.question,
                    correct_answer: q.correct_answer,
                    difficulty_level: q.difficulty,
                    points: q.points
                }))
            )
            .select();

        if (saveError) {
            console.error('Database error:', saveError);
            throw saveError;
        }

        console.log('Questions saved successfully:', savedQuestions);
        return savedQuestions;

    } catch (error) {
        console.error('Question generation error:', error);
        throw error;
    }
};

