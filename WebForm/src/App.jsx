import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import ShareRedirectPage from './pages/ShareRedirectPage';
import SubmissionPage from './pages/SubmissionPage';

function App() {
  return (
    <Router>
      <Routes>
        {/* Route for share links */}
        <Route path="/share" element={<ShareRedirectPage />} />
        
        {/* Routes for submission page */}
        <Route path="/submission/:token" element={<SubmissionPage />} />
        <Route path="/submission" element={<SubmissionPage />} />
        
        {/* Default route - redirect to submission */}
        <Route path="/" element={<SubmissionPage />} />
      </Routes>
    </Router>
  );
}

export default App;
