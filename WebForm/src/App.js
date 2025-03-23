import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { createTheme, ThemeProvider, CssBaseline } from '@mui/material';
import SubmissionPage from './pages/SubmissionPage';
import ShareRedirectPage from './pages/ShareRedirectPage';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
    background: {
      default: '#f5f5f5',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Routes>
          {/* Share link route - this is the entry point from the mobile app */}
          <Route path="/share" element={<ShareRedirectPage />} />
          
          {/* Add this contribute route */}
        <Route path="/contribute" element={<SubmissionPage />} />
        
          {/* Submission routes */}
          <Route path="/submission/:token" element={<SubmissionPage />} />
          <Route path="/submission" element={<SubmissionPage />} />
          
          {/* Original route - maintain backward compatibility */}
          <Route path="/memories/:token" element={<SubmissionPage />} />
          
          {/* Default route */}
          <Route path="/" element={<SubmissionPage />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;