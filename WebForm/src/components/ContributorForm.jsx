import React from 'react';
import { Formik, Form } from 'formik';
import * as Yup from 'yup';
import { 
  Box, 
  Button, 
  TextField, 
  Typography, 
  MenuItem, 
  FormControl, 
  Select, 
  InputLabel, 
  FormHelperText,
  Paper
} from '@mui/material';

// Validation schema
const ContributorSchema = Yup.object().shape({
  name: Yup.string()
    .required('Name is required'),
  email: Yup.string()
    .email('Invalid email address')
    .required('Email is required'),
  relationshipType: Yup.string()
    .required('Please select your relationship'),
  relationshipYears: Yup.number()
    .required('Please specify how many years')
    .positive('Must be a positive number')
    .integer('Must be a whole number'),
});

// Relationship types
const relationshipTypes = [
  'Family',
  'Friend',
  'Neighbor',
  'Colleague',
  'Caregiver',
  'Other'
];

const ContributorForm = ({ onSubmit, userId }) => {
  return (
    <Paper elevation={3} sx={{ p: 3, mb: 3 }}>
      <Typography variant="h5" component="h2" gutterBottom>
        Personal Information
      </Typography>
      <Typography variant="body1" color="text.secondary" paragraph>
        Please provide your details and relationship to the person you're helping.
      </Typography>
      
      <Formik
        initialValues={{
          name: '',
          email: '',
          relationshipType: '',
          relationshipYears: '',
          userId: userId || ''
        }}
        validationSchema={ContributorSchema}
        onSubmit={(values, { setSubmitting }) => {
          onSubmit(values);
          setSubmitting(false);
        }}
      >
        {({ errors, touched, values, handleChange, isSubmitting }) => (
          <Form> 
            <Box sx={{ mb: 2 }}>
              <TextField
                fullWidth
                id="name"
                name="name"
                label="Your Name"
                value={values.name}
                onChange={handleChange}
                error={touched.name && Boolean(errors.name)}
                helperText={touched.name && errors.name}
                margin="normal"
              />
            </Box>
            <Box sx={{ mb: 2 }}>
              <TextField
                fullWidth
                id="email"
                name="email"
                label="Email Address"
                value={values.email}
                onChange={handleChange}
                error={touched.email && Boolean(errors.email)}
                helperText={touched.email && errors.email}
                margin="normal"
              />
            </Box>
            <Box sx={{ mb: 2 }}>
              <FormControl 
                fullWidth 
                error={touched.relationshipType && Boolean(errors.relationshipType)}
                margin="normal"
              >
                <InputLabel id="relationship-type-label">Relationship Type</InputLabel>
                <Select
                  labelId="relationship-type-label"
                  id="relationshipType"
                  name="relationshipType"
                  value={values.relationshipType}
                  onChange={handleChange}
                  label="Relationship Type"
                >
                  {relationshipTypes.map((type) => (
                    <MenuItem key={type} value={type}>
                      {type}
                    </MenuItem>
                  ))}
                </Select>
                {touched.relationshipType && errors.relationshipType && (
                  <FormHelperText>{errors.relationshipType}</FormHelperText>
                )}
              </FormControl>
            </Box>
            <Box sx={{ mb: 3 }}>
              <TextField
                fullWidth
                id="relationshipYears"
                name="relationshipYears"
                label="Years Known"
                type="number"
                value={values.relationshipYears}
                onChange={handleChange}
                error={touched.relationshipYears && Boolean(errors.relationshipYears)}
                helperText={touched.relationshipYears && errors.relationshipYears}
                margin="normal"
                InputProps={{ inputProps: { min: 1 } }}
              />
            </Box>





          </Form>
        )}
      </Formik>
    </Paper>
  );
};

export default ContributorForm;