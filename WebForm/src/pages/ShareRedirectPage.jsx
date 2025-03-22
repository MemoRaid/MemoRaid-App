import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Container, CircularProgress, Typography, Alert, Paper } from '@mui/material';

const ShareRedirectPage = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [error, setError] = useState('');
  
  useEffect(() => {
    // Extract token from query parameters
    const queryParams = new URLSearchParams(location.search);
    const token = queryParams.get('token');
    
    console.log("Share page - received token:", token);
    
    if (token) {
      // Redirect to submission page with the token
      console.log("Redirecting to submission with token:", token);
      setTimeout(() => {
        navigate(`/submission/${token}`);
      }, 1000); // Small delay to ensure console logs are visible
    } else {
      console.error("No token found in URL:", location.search);
      setError('No token found in the URL. Please check the link and try again.');
      // Still allow navigation to demo mode after a delay
      setTimeout(() => {
        navigate('/submission');
      }, 5001);
    }
  }, [location, navigate]);
  
  return (
    <Container maxWidth="md" sx={{ mt: 4, textAlign: 'center' }}>
      <Paper elevation={3} sx={{ p: 3, mb: 4 }}>
        <Typography variant="h4" component="h1" align="center" gutterBottom>
          Memoraid
        </Typography>
        
        {error ? (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        ) : (
          <>
            <CircularProgress sx={{ mt: 2, mb: 2 }} />
            <Typography variant="h6" sx={{ mt: 2 }}>
              Processing Your Link
            </Typography>
            <Typography variant="body1" sx={{ mt: 2 }}>
              Redirecting to memory submission form...
            </Typography>
          </>
        )}
      </Paper>
    </Container>
  );
};

export default ShareRedirectPage;
