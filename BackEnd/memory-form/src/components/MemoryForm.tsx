import React, { useState } from 'react';
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import type { MemoryFormData, MediaData, MediaType } from '../types/memory';

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
const ACCEPTED_MEDIA_TYPES = {
  image: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
  video: ['video/mp4', 'video/webm', 'video/quicktime']
};

const schema = z.object({
  caregiver: z.object({
    fullName: z.string().min(2, 'Full name is required'),
    email: z.string().email('Invalid email address'),
    phoneNumber: z.string().optional(),
    relationshipType: z.string().min(1, 'Please select a relationship type'),
    yearsKnown: z.number().min(0, 'Years known must be 0 or greater'),
  }),
  mediaItems: z.array(z.object({
    description: z.string().min(1, 'Description is required'),
    date: z.date().optional(),
    location: z.string().min(1, 'Location is required'),
    peoplePresent: z.string().min(1, 'Please list people present'),
    eventDetails: z.string().min(1, 'Event details are required'),
    emotions: z.string().min(1, 'Please describe emotions/feelings'),
  })).min(1, 'At least one media item is required'),
});

export default function MemoryForm() {
    const [isSubmitted, setIsSubmitted] = useState(false);
    const [showMediaUpload, setShowMediaUpload] = useState(false);
  
    const {
      register,
      handleSubmit,
      control,
      watch,
      setValue,
      trigger,
      formState: { errors, isSubmitting },
    } = useForm<MemoryFormData>({
      resolver: zodResolver(schema),
      defaultValues: {
        caregiver: {
          fullName: '',
          email: '',
          phoneNumber: '',
          relationshipType: '',
          yearsKnown: 0,
        },
        mediaItems: [],
      },
    });
  
    const { fields, append, remove } = useFieldArray({
      control,
      name: 'mediaItems',
    });
  
    const handleMediaUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0];
      if (!file) return;
      
      if (file.size > MAX_FILE_SIZE) {
        alert('File is too large. Maximum size is 50MB');
        return;
      }
      
      let mediaType: MediaType = 'image';
      if (ACCEPTED_MEDIA_TYPES.video.includes(file.type)) {
        mediaType = 'video';
      } else if (!ACCEPTED_MEDIA_TYPES.image.includes(file.type)) {
        alert('Unsupported file format');
        return;
      }
  
      const reader = new FileReader();
      reader.onload = (e) => {
        append({
          file,
          preview: e.target?.result as string,
          mediaType,
          description: '',
          location: '',
          peoplePresent: '',
          eventDetails: '',
          emotions: '',
        });
      };
      reader.readAsDataURL(file);
    };
  
    const handleCaregiverSubmit = async () => {
      const isValid = await trigger('caregiver');
      if (isValid) {
        setShowMediaUpload(true);
      }
    };
  
    const onSubmit = async (data: MemoryFormData) => {
      try {
        // Handle form submission here
        console.log('Form data:', data);
        setIsSubmitted(true);
      } catch (error) {
        console.error('Error submitting form:', error);
      }
    };
  
    if (isSubmitted) {
      return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="bg-white p-8 rounded-lg shadow-xl max-w-md w-full text-center">
            <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100">
              <svg className="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <h3 className="mt-4 text-xl font-medium text-gray-900">Thank you for sharing your memories!</h3>
            <p className="mt-2 text-gray-600">
              Your memories have been successfully submitted.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="mt-6 w-full px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700"
            >
              Add More Memories
            </button>
          </div>
        </div>
      );
    }
  
    return (
      <form onSubmit={handleSubmit(onSubmit)} className="max-w-4xl mx-auto p-4 space-y-8">
        {/* Caregiver Information */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-2xl font-semibold mb-6">Caregiver Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700">Full Name</label>
              <input
                type="text"
                {...register('caregiver.fullName')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              {errors.caregiver?.fullName && (
                <p className="mt-1 text-sm text-red-600">{errors.caregiver.fullName.message}</p>
              )}
            </div>
  
            <div>
              <label className="block text-sm font-medium text-gray-700">Email</label>
              <input
                type="email"
                {...register('caregiver.email')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              {errors.caregiver?.email && (
                <p className="mt-1 text-sm text-red-600">{errors.caregiver.email.message}</p>
              )}
            </div>
  
            <div>
              <label className="block text-sm font-medium text-gray-700">Phone Number (Optional)</label>
              <input
                type="tel"
                {...register('caregiver.phoneNumber')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>
  
            <div>
              <label className="block text-sm font-medium text-gray-700">Relationship Type</label>
              <select
                {...register('caregiver.relationshipType')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="">Select relationship</option>
                <option value="family">Family Member</option>
                <option value="friend">Friend</option>
                <option value="caregiver">Professional Caregiver</option>
                <option value="other">Other</option>
              </select>
              {errors.caregiver?.relationshipType && (
                <p className="mt-1 text-sm text-red-600">{errors.caregiver.relationshipType.message}</p>
              )}
            </div>
  
            <div>
              <label className="block text-sm font-medium text-gray-700">Years Known</label>
              <input
                type="number"
                {...register('caregiver.yearsKnown', { valueAsNumber: true })}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              {errors.caregiver?.yearsKnown && (
                <p className="mt-1 text-sm text-red-600">{errors.caregiver.yearsKnown.message}</p>
              )}
            </div>
          </div>
  
          {!showMediaUpload && (
            <div className="mt-6 flex justify-end">
              <button
                type="button"
                onClick={handleCaregiverSubmit}
                className="px-6 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
              >
                Continue to Add Memories
              </button>
            </div>
          )}
        </div>
  
        {showMediaUpload && (
          <>
            {/* Memory Items */}
            {fields.map((field, index) => (
              <div key={field.id} className="bg-white rounded-lg shadow-md p-6 space-y-6">
                <div className="flex justify-between items-center">
                  <h2 className="text-2xl font-semibold">Memory #{index + 1}</h2>
                  <button
                    type="button"
                    onClick={() => remove(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Remove Memory
                  </button>
                </div>
  
                <div className="relative">
                  {watch(`mediaItems.${index}.mediaType`) === 'video' ? (
                    <video
                      src={watch(`mediaItems.${index}.preview`)}
                      className="w-full h-64 object-cover rounded-lg"
                      controls
                    />
                  ) : (
                    <img
                      src={watch(`mediaItems.${index}.preview`)}
                      alt={`Memory ${index + 1}`}
                      className="w-full h-64 object-cover rounded-lg"
                    />
                  )}
                </div>
  
                <div className="space-y-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Description</label>
                    <textarea
                      {...register(`mediaItems.${index}.description`)}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      rows={4}
                    />
                    {errors.mediaItems?.[index]?.description && (
                      <p className="mt-1 text-sm text-red-600">
                        {errors.mediaItems[index]?.description?.message}
                      </p>
                    )}
                  </div>
  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Date</label>
                    <div className="flex items-center space-x-4">
                    <DatePicker
                      selected={watch(`mediaItems.${index}.date`)}
                      onChange={(date: Date | null) => {
                        setValue(`mediaItems.${index}.date`, date || undefined);
                      }}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      isClearable
                      placeholderText="Select a date"
                    />
                      <button
                        type="button"
                        onClick={() => setValue(`mediaItems.${index}.date`, undefined)}
                        className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md"
                      >
                        Don't know
                      </button>
                    </div>
                  </div>
  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Location</label>
                    <input
                      type="text"
                      {...register(`mediaItems.${index}.location`)}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    {errors.mediaItems?.[index]?.location && (
                      <p className="mt-1 text-sm text-red-600">
                        {errors.mediaItems[index]?.location?.message}
                      </p>
                    )}
                  </div>
  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">People Present</label>
                    <input
                      type="text"
                      {...register(`mediaItems.${index}.peoplePresent`)}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    {errors.mediaItems?.[index]?.peoplePresent && (
                      <p className="mt-1 text-sm text-red-600">
                        {errors.mediaItems[index]?.peoplePresent?.message}
                      </p>
                    )}
                  </div>
  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Event Details</label>
                    <textarea
                      {...register(`mediaItems.${index}.eventDetails`)}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      rows={3}
                    />
                    {errors.mediaItems?.[index]?.eventDetails && (
                      <p className="mt-1 text-sm text-red-600">
                        {errors.mediaItems[index]?.eventDetails?.message}
                      </p>
                    )}
                  </div>
  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Emotions/Feelings</label>
                    <textarea
                      {...register(`mediaItems.${index}.emotions`)}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      rows={3}
                    />
                    {errors.mediaItems?.[index]?.emotions && (
                      <p className="mt-1 text-sm text-red-600">
                        {errors.mediaItems[index]?.emotions?.message}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            ))}
  
            {/* Add Memory Button */}
            <div className="flex justify-center">
              <label className="px-6 py-3 bg-green-600 text-white rounded-lg cursor-pointer hover:bg-green-700 transition-colors">
                <span className="flex items-center space-x-2">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                  </svg>
                  <span>Add New Memory</span>
                </span>
                <input
                  type="file"
                  accept="image/*,video/*"
                  className="hidden"
                  onChange={handleMediaUpload}
                />
              </label>
            </div>
  
            {/* Submit Button */}
            {fields.length > 0 && (
              <div className="flex justify-end">
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  Submit All Memories
                </button>
              </div>
            )}
          </>
        )}
      </form>
    );
  }