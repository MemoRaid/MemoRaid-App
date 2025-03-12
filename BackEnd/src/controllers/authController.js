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

// Login user
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validate input
    if (!email || !password) {
      return res.status(400).json({ 
        message: 'Email and password are required' 
      });
    }
    
    // Find user by email
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();
    
    if (userError) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Get auth info
    const { data: authInfo, error: authError } = await supabase
      .from('user_auth')
      .select('*')
      .eq('user_id', user.id)
      .single();
    
    if (authError || !authInfo) {
      return res.status(404).json({ message: 'Authentication information not found' });
    }
    
    // Compare password
    const isValidPassword = await bcrypt.compare(password, authInfo.password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    // Create JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      message: 'Server error during login', 
      error: error.message 
    });
  }
};

// Google Sign In
exports.googleSignIn = async (req, res) => {
  try {
    const { idToken } = req.body;
    
    if (!idToken) {
      return res.status(400).json({ message: 'ID token is required' });
    }
    
    // Verify the Google ID token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID
    });
    
    const payload = ticket.getPayload();
    const { email, name, picture } = payload;
    
    // Check if user exists
    let { data: user, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();
    
    if (userError && userError.code !== 'PGRST116') {
      return res.status(500).json({ 
        message: 'Error checking user', 
        error: userError.message 
      });
    }
    
    // If user doesn't exist, create a new one
    if (!user) {
      const { data: newUser, error: createError } = await supabase
        .from('users')
        .insert([
          { 
            name, 
            email,
            photo_url: picture || null
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
            provider: 'google'
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
      
      user = newUser[0];
    }
    
    // Create JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.status(200).json({
      message: 'Google sign-in successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token
    });
  } catch (error) {
    console.error('Google sign-in error:', error);
    res.status(500).json({ 
      message: 'Server error during Google sign-in', 
      error: error.message 
    });
  }
};

// Verify share token
exports.verifyShareToken = async (req, res) => {
  try {
    const { token } = req.params;
    
    if (!token) {
      return res.status(400).json({ message: 'Token is required' });
    }
    
    // Verify the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if this is a share token
    if (decoded.purpose !== 'memory-share') {
      return res.status(401).json({ message: 'Invalid token purpose' });
    }
    
    // Get user details
    const { data: user, error } = await supabase
      .from('users')
      .select('id, name, email')
      .eq('id', decoded.userId)
      .single();
    
    if (error) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.status(200).json({
      message: 'Token verified successfully',
      user
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }
    
    console.error('Token verification error:', error);
    res.status(500).json({ 
      message: 'Server error verifying token', 
      error: error.message 
    });
  }
};

