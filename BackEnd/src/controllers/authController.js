const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase client - use only this one
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY; // Changed to match your .env
const supabase = createClient(supabaseUrl, supabaseKey);


// Register a new user
exports.register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    
    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({ 
        message: 'Name, email, and password are required' 
      });
    }
    
    // Check if user already exists
    const { data: existingUser, error: searchError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();
    
    if (searchError && searchError.code !== 'PGRST116') {
      return res.status(500).json({ 
        message: 'Error checking existing user', 
        error: searchError.message 
      });
    }
    
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }
    
    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    // Create user in Supabase
    const { data: newUser, error: createError } = await supabase
      .from('users')
      .insert([
        { 
          name, 
          email, 
          phone: phone || null,
          // We'll store hashed password in auth_provider table for simplicity
          // In a production app, you might use Supabase Auth or a more robust auth system
        }
      ])
      .select();
    
    if (createError) {
      return res.status(500).json({ 
        message: 'Error creating user', 
        error: createError.message 
      });
    }
    
    // Store auth info separately
    const { error: authError } = await supabase
      .from('user_auth')
      .insert([
        {
          user_id: newUser[0].id,
          password_hash: hashedPassword,
          provider: 'email'
        }
      ]);
    
    if (authError) {
      // If auth fails, clean up the user
      await supabase.from('users').delete().eq('id', newUser[0].id);
      return res.status(500).json({ 
        message: 'Error creating authentication', 
        error: authError.message 
      });
    }
    
    // Create JWT token
    const token = jwt.sign(
      { id: newUser[0].id, email: newUser[0].email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: newUser[0].id,
        name: newUser[0].name,
        email: newUser[0].email
      },
      token
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      message: 'Server error during registration', 
      error: error.message 
    });
  }
};


