import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { 
  Container, 
  Typography, 
  Box, 
  Stepper, 
  Step, 
  StepLabel, 
  Paper,
  Alert,
  CircularProgress
} from '@mui/material';
import ContributorForm from '../components/ContributorForm';
import MemoryForm from '../components/MemoryForm';
import { submitContributor, getUserFromToken } from '../services/api';

// Steps for the memory submission process
const steps = ['Your Information', 'Add Memories'];

const SubmissionPage = () => {
  const { token: pathToken } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  


  // Extract token from either path parameter or query parameter
  const queryParams = new URLSearchParams(location.search);
  const queryToken = queryParams.get('token');
  const token = pathToken || queryToken;

    // Add debug logs
  console.log('Token from URL:', token);
  
  const [activeStep, setActiveStep] = useState(0);
  const [userId, setUserId] = useState(null);
  const [contributorId, setContributorId] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [memories, setMemories] = useState([]);
  
  // Fetch user info from token when component mounts
  useEffect(() => {
    const fetchUserFromToken = async () => {
      try {
        if (token) {
          try {
            console.log("Attempting to verify token:", token);
            const userData = await getUserFromToken(token);
            if (userData && userData.id) {
              console.log("Successfully extracted userId:", userData.id);
              setUserId(userData.id);
            } else {
              console.error("Token verification returned invalid user data");
              setError('Invalid user data from token. Please try again with a valid link.');
              setLoading(false);
              return;
            }
          } catch (err) {
            console.error("Error fetching user from token:", err);
            // Only use demo mode in development environment
            if (process.env.NODE_ENV === 'development') {
              console.log("Using demo mode due to development environment");
              setUserId("11111111-1111-1111-1111-111111111111");
            } else {
              setError('Invalid or expired link. Please contact the person who sent you this link.');
              setLoading(false);
              return;
            }
          }
        } else {
          console.log("No token provided, using demo mode");
          // For testing without token, only in development
          if (process.env.NODE_ENV === 'development') {
            setUserId("11111111-1111-1111-1111-111111111111");
          } else {
            setError('No access token provided. Please use the link you received.');
            setLoading(false);
            return;
          }
        }
        setLoading(false);
      } catch (err) {
        console.error("General error:", err);
        setError('Failed to process the link. Please try again.');
        setLoading(false);
      }
    };
  
    fetchUserFromToken();
  }, [token]);
  
  const handleContributorSubmit = async (contributorData) => {
    try {
      const result = await submitContributor({
        ...contributorData,
        userId
      });
      setContributorId(result.id);
      setActiveStep(1);
    } catch (err) {
      setError('Failed to submit your information. Please try again.');
      console.error(err);
    }
  };
  
  const handleMemoriesSubmit = (submittedMemories) => {
    setMemories(submittedMemories);
    // Navigate to success page or show success message
    setActiveStep(2);
  };
  
  if (loading) {
    return (
      <Container maxWidth="md" sx={{ mt: 4, textAlign: 'center' }}>
        <CircularProgress />
        <Typography variant="body1" sx={{ mt: 2 }}>
          Loading...
        </Typography>
      </Container>
    );
  }
  
  if (error) {
    return (
      <Container maxWidth="md" sx={{ mt: 4 }}>
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
        <Typography variant="body1">
          Please try accessing this page using the link you received, or contact the person who sent you the link.
        </Typography>
      </Container>
    );
  }
  
  return (
    <Container maxWidth="md" sx={{ mt: 4, mb: 8 }}>
      <Paper elevation={3} sx={{ p: 3, mb: 4 }}>
        <Typography variant="h4" component="h1" align="center" gutterBottom>
          Memoraid
        </Typography>
        <Typography variant="h5" component="h2" align="center" gutterBottom>
          Share Your Memories
        </Typography>
        <Typography variant="body1" color="text.secondary" align="center" paragraph>
          Help your loved one reconnect with precious memories by sharing photos and stories.
        </Typography>
      </Paper>
      
      <Box sx={{ mb: 4 }}>
        <Stepper activeStep={activeStep} alternativeLabel>
          {steps.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>
      </Box>
      
      {activeStep === 0 && (
        <ContributorForm onSubmit={handleContributorSubmit} userId={userId} />
      )}
      
      {activeStep === 1 && (
        <MemoryForm 
          contributorId={contributorId} 
          onComplete={handleMemoriesSubmit} 
        />
      )}
      
      {activeStep === 2 && (
        <Paper elevation={3} sx={{ p: 3, textAlign: 'center' }}>
          <Alert severity="success" sx={{ mb: 2 }}>
            Thank you for sharing your memories!
          </Alert>
          <Typography variant="h5" gutterBottom>
            Your memories have been successfully submitted
          </Typography>
          <Typography variant="body1" paragraph>
            You've shared {memories.length} memories that will help your loved one reconnect with their past.
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Feel free to close this page now, or share more memories by refreshing the page.
          </Typography>
        </Paper>
      )}
    </Container>
  );
};

export default SubmissionPage;