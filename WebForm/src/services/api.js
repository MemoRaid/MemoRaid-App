import axios from 'axios';

// Create an axios instance with default config
const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL  || 'https://memoraid-app.onrender.com/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor for debugging
api.interceptors.request.use(request => {
  console.log('Starting Request', request);
  return request;
});

// Add response interceptor for debugging
api.interceptors.response.use(
  response => {
    console.log('Response:', response);
    return response;
  },
  error => {
    console.log('Response Error:', error);
    return Promise.reject(error);
  }
);

// Memory contributors API functions
export const submitContributor = async (contributorData) => {
  try {
    console.log('Submitting contributor data:', contributorData);
    const response = await api.post('/memories/contributor', contributorData);
    console.log('Contributor submitted successfully:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error submitting contributor:', error);
    throw error;
  }
};

// Memory submission API functions
export const uploadPhoto = async (file) => {
  try {
    const formData = new FormData();
    formData.append('photo', file);
    
    console.log('Uploading file:', file);
    
    const response = await api.post('/memories/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    console.log('Upload response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error uploading photo:', error);
    throw error;
  }
};

export const submitMemory = async (memory) => {
  try {
    const response = await api.post('/memories', {
      contributorId: memory.contributorId,
      photoUrl: memory.photoUrl,
      description: memory.description,
      briefDescription: memory.briefDescription,
      eventDate: memory.eventDate
    });
    return response.data;
  } catch (error) {
    console.error('Error submitting memory:', error);
    throw error;
  }
};

// Function to get user info from token
export const getUserFromToken = async (token) => {
  try {
    console.log("Sending token for verification:", token);
    const response = await api.post('/auth/verify-share-token', { token });
    console.log("Verification response:", response.data);
    return response.data.user;
  } catch (error) {
    console.error("Full API error:", error);
    console.error("Error response:", error.response?.data);
    throw error;
  }
};

export default api;