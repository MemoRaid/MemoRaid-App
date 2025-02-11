export type MediaType = 'image' | 'video';

export type MediaData = {
  file: File;
  preview: string;
  mediaType: MediaType;
  description: string;
  date?: Date;
  location: string;
  peoplePresent: string;
  eventDetails: string;
  emotions: string;
};

export type MemoryFormData = {
  caregiver: {
    fullName: string;
    email: string;
    phoneNumber?: string;
    relationshipType: string;
    yearsKnown: number;
  };
  mediaItems: MediaData[];
};