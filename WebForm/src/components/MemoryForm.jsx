import React, { useState } from 'react';
import { Formik, Form } from 'formik';
import * as Yup from 'yup';
import { 
  Box, 
  Button, 
  TextField, 
  Typography, 
  Paper,
  Divider,
  Grid,
  Card,
  CardMedia,
  CardContent,
  CircularProgress,
  IconButton,
  Alert,
  Stepper,
  Step,
  StepLabel,
  Accordion,
  AccordionSummary,
  AccordionDetails
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import AddIcon from '@mui/icons-material/Add';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import PhotoUpload from './PhotoUpload';
import { submitMemory } from '../services/api';

// Validation schema
const MemorySchema = Yup.object().shape({
  description: Yup.string()
    .required('Please provide a detailed description')
    .min(100, 'Description should be at least 100 characters'),
  briefDescription: Yup.string()
    .required('Please provide a brief description')
    .max(100, 'Brief description should be under 100 characters'),
  eventDate: Yup.date()
    .nullable()
    .typeError('Please enter a valid date')
});

const MemoryForm = ({ contributorId, onMemoryAdded, onComplete }) => {
  const [memories, setMemories] = useState([]);
  const [currentPhoto, setCurrentPhoto] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handlePhotoUploaded = (photoUrl) => {
    console.log('Received photo URL in MemoryForm:', photoUrl);
    setCurrentPhoto(photoUrl);
  };

  const handleAddMemory = async (values, { resetForm }) => {
    if (!currentPhoto) {
      setError('Please upload a photo for this memory');
      return;
    }
  
    setSubmitting(true);
    try {
      const newMemory = {
        photoUrl: currentPhoto,
        description: values.description,
        briefDescription: values.briefDescription,
        eventDate: values.eventDate || null,
        contributorId
      };
  
      // Add to local state first
      const updatedMemories = [...memories, newMemory];
      setMemories(updatedMemories);
      
      setSuccess('Memory added! You can add more memories or submit all.');
      setCurrentPhoto(null); // Clear the current photo to allow adding another
      resetForm();
      
      // Call the callback function if provided
      if (onMemoryAdded) {
        onMemoryAdded(newMemory);
      }
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        setSuccess('');
      }, 3000);
    } catch (err) {
      setError('Failed to add memory. Please try again.');
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteMemory = (index) => {
    const updatedMemories = [...memories];
    updatedMemories.splice(index, 1);
    setMemories(updatedMemories);
  };

  const handleSubmitAll = async () => {
    if (memories.length === 0) {
      setError('Please add at least one memory');
      return;
    }

    setSubmitting(true);
    try {
      // Send each memory to the backend
      for (const memory of memories) {
        if (!memory.saved) { // Only submit memories that haven't been saved yet
          await submitMemory(memory);
        }
      }
      
      if (onComplete) {
        onComplete(memories);
      }
    } catch (err) {
      setError('Failed to submit memories. Please try again.');
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Box>
      <Paper elevation={3} sx={{ p: 3, mb: 3 }}>
        <Box sx={{ mb: 3 }}>
          <Stepper activeStep={memories.length > 0 ? 1 : 0} alternativeLabel>
            <Step key="upload">
              <StepLabel>Upload Photos</StepLabel>
            </Step>
            <Step key="submit">
              <StepLabel>Submit All Memories</StepLabel>
            </Step>
          </Stepper>
        </Box>
        
        <Typography variant="h5" component="h2" gutterBottom>
          Add Memories
        </Typography>
        <Typography variant="body1" color="text.secondary" paragraph>
          Upload photos and provide details about each memory to help with recognition.
          You can add multiple photos and descriptions before submitting.
        </Typography>
        
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}
        
        {success && (
          <Alert severity="success" sx={{ mb: 2 }}>
            {success}
          </Alert>
        )}
        
        <Typography variant="h6" gutterBottom sx={{ mt: 3 }}>
          {memories.length > 0 ? 'Add Another Memory' : 'Add Your First Memory'}
        </Typography>
        
        <PhotoUpload onPhotoUploaded={handlePhotoUploaded} />
        
        {currentPhoto && (
          <Formik
            initialValues={{
              description: '',
              briefDescription: '',
              eventDate: ''
            }}
            validationSchema={MemorySchema}
            onSubmit={handleAddMemory}
          >
            {({ errors, touched, values, handleChange, handleSubmit }) => (
              <Form>
                <Accordion defaultExpanded sx={{ mb: 2 }}>
                  <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                    <Typography variant="subtitle1" color="primary">
                      Description Guidelines
                    </Typography>
                  </AccordionSummary>
                  <AccordionDetails>
                    <Box sx={{ mb: 2 }}>
                      <Typography variant="subtitle2" color="primary">
                        Detailed Description (For Question Generation):
                      </Typography>
                      <ul>
                        <li>Include specific details about who was present</li>
                        <li>Mention the exact location</li>
                        <li>Include the date or time period</li>
                        <li>Describe emotions and reactions</li>
                      </ul>
                      <Typography variant="caption" color="text.secondary">
                        Example: "On July 15th, we celebrated Sarah's birthday at Miami Beach with Mom and Dad. Sarah was overjoyed with her new watch."
                      </Typography>
                    </Box>
                    <Box>
                      <Typography variant="subtitle2" color="primary">
                        Brief Description (For Patient Display):
                      </Typography>
                      <ul>
                        <li>Keep it under 30 words</li>
                        <li>Avoid specific names</li>
                        <li>Use general locations</li>
                        <li>Focus on the type of event</li>
                      </ul>
                      <Typography variant="caption" color="text.secondary">
                        Example: "A family celebration at the beach during summer"
                      </Typography>
                    </Box>
                  </AccordionDetails>
                </Accordion>

                <TextField
                  fullWidth
                  id="description"
                  name="description"
                  label="Detailed Description"
                  multiline
                  rows={4}
                  value={values.description}
                  onChange={handleChange}
                  error={touched.description && Boolean(errors.description)}
                  helperText={touched.description && errors.description}
                  margin="normal"
                  placeholder="What was happening in this photo? Who was there? What makes this memory special?"
                />

                <TextField
                  fullWidth
                  id="briefDescription"
                  name="briefDescription"
                  label="Brief Description (For Patient)"
                  multiline
                  rows={2}
                  value={values.briefDescription}
                  onChange={handleChange}
                  error={touched.briefDescription && Boolean(errors.briefDescription)}
                  helperText={touched.briefDescription && errors.briefDescription}
                  margin="normal"
                  placeholder="Provide a general description without specific details"
                />

                <TextField
                  fullWidth
                  id="eventDate"
                  name="eventDate"
                  label="When did this happen? (Optional)"
                  type="date"
                  value={values.eventDate}
                  onChange={handleChange}
                  error={touched.eventDate && Boolean(errors.eventDate)}
                  helperText={touched.eventDate && errors.eventDate}
                  margin="normal"
                  InputLabelProps={{
                    shrink: true,
                  }}
                />
                
                <Button
                  type="submit"
                  variant="contained"
                  color="primary"
                  startIcon={<AddIcon />}
                  sx={{ mt: 2 }}
                  disabled={submitting}
                >
                  {submitting ? 'Adding...' : 'Add This Memory'}
                </Button>
              </Form>
            )}
          </Formik>
        )}
      </Paper>
      
      {memories.length > 0 && (
        <Paper elevation={3} sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            Added Memories ({memories.length})
          </Typography>
          <Divider sx={{ mb: 2 }} />
          
          <Grid container spacing={2}>
            {memories.map((memory, index) => (
              <Grid item xs={12} sm={6} md={4} key={index}>
                <Card>
                  <CardMedia
                    component="img"
                    height="140"
                    image={memory.photoUrl}
                    alt={`Memory ${index + 1}`}
                  />
                  <CardContent>
                    <Typography variant="body2" color="text.secondary" noWrap>
                      {memory.description}
                    </Typography>
                    <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 1 }}>
                      <IconButton 
                        size="small" 
                        color="error"
                        onClick={() => handleDeleteMemory(index)}
                      >
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
          
          <Box sx={{ mt: 3, display: 'flex', justifyContent: 'center' }}>
            <Button
              variant="contained"
              color="success"
              onClick={handleSubmitAll}
              disabled={submitting}
              startIcon={submitting && <CircularProgress size={20} color="inherit" />}
              size="large"
            >
              {submitting ? 'Submitting...' : 'Submit All Memories'}
            </Button>
          </Box>
        </Paper>
      )}
    </Box>
  );
};

export default MemoryForm;