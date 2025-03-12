import React, { useState } from 'react';
import { 
  Box, 
  Button, 
  Typography, 
  CircularProgress, 
  Paper,
  Alert
} from '@mui/material';
import { styled } from '@mui/material/styles';
import AddPhotoAlternateIcon from '@mui/icons-material/AddPhotoAlternate';
import { uploadPhoto } from '../services/api';

// Styled component for the upload area
const UploadBox = styled(Box)(({ theme }) => ({
  border: `2px dashed ${theme.palette.primary.main}`,
  borderRadius: theme.shape.borderRadius,
  padding: theme.spacing(3),
  textAlign: 'center',
  cursor: 'pointer',
  backgroundColor: theme.palette.background.default,
  '&:hover': {
    backgroundColor: theme.palette.action.hover,
  },
  marginBottom: theme.spacing(2),
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  justifyContent: 'center',
  minHeight: 200,
}));

// Styled component for the preview image
const PreviewImage = styled('img')({
  maxWidth: '100%',
  maxHeight: 300,
  objectFit: 'contain',
  marginTop: 16,
  marginBottom: 16,
});

const PhotoUpload = ({ onPhotoUploaded }) => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [preview, setPreview] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    
    if (!file) return;
    
    // Check file type
    if (!file.type.match('image.*')) {
      setError('Please select an image file (jpg, png, etc)');
      return;
    }
    
    // Check file size (limit to 5MB)
    if (file.size > 5 * 1024 * 1024) {
      setError('File size should not exceed 5MB');
      return;
    }
    
    setError('');
    setSelectedFile(file);
    
    // Create preview
    const reader = new FileReader();
    reader.onload = () => {
      setPreview(reader.result);
    };
    reader.readAsDataURL(file);
  };

  const handleUpload = async () => {
    if (!selectedFile) return;
    
    setLoading(true);
    try {
      // Upload the photo and get the URL
      const result = await uploadPhoto(selectedFile);
      console.log('Upload result:', result);
      
      // Pass the URL to parent component
      onPhotoUploaded(result.photoUrl);
      
      // Clear the current preview and file for the next upload
      setSelectedFile(null);
      setPreview('');
      setLoading(false);
    } catch (error) {
      setLoading(false);
      setError('Failed to upload photo. Please try again.');
      console.error('Upload error:', error);
    }
  };

  return (
    <Paper elevation={2} sx={{ p: 3, mb: 3 }}>
      <Typography variant="h6" gutterBottom>
        Upload a Photo
      </Typography>
      
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      
      <input
        accept="image/*"
        style={{ display: 'none' }}
        id="photo-upload"
        type="file"
        onChange={handleFileChange}
      />
      
      <label htmlFor="photo-upload">
        <UploadBox component="div">
          {!preview ? (
            <>
              <AddPhotoAlternateIcon fontSize="large" color="primary" />
              <Typography variant="body1" sx={{ mt: 1 }}>
                Click to select a photo
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Max file size: 5MB
              </Typography>
            </>
          ) : (
            <PreviewImage src={preview} alt="Preview" />
          )}
        </UploadBox>
      </label>
      
      {selectedFile && (
        <Box sx={{ mt: 2, display: 'flex', justifyContent: 'center' }}>
          <Button
            variant="contained"
            color="primary"
            onClick={handleUpload}
            disabled={loading}
            startIcon={loading && <CircularProgress size={20} color="inherit" />}
          >
            {loading ? 'Uploading...' : 'Describe here'}
          </Button>
        </Box>
      )}
    </Paper>
  );
};


export default PhotoUpload;