-- ============================================================================
-- ABSENDO - COMPLETE SUPABASE DATABASE SCHEMA MIGRATION
-- ============================================================================
-- This script creates all required tables, columns, policies, and triggers
-- Run this in Supabase SQL Editor to set up the complete database schema
-- ============================================================================

-- ============================================================================
-- 1. PROFILES TABLE - User profile data with end-to-end encryption
-- ============================================================================

-- Create profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Add encryption-related columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS encryption_salt TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS has_pin BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pin_hash TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS encrypted_data TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_encrypted BOOLEAN DEFAULT false;

-- Add user profile data columns (encrypted)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS birthday TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS calendar_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS first_name_trainer TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_name_trainer TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_number_trainer TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email_trainer TEXT;

-- Add user preferences/settings columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS isFullNameEnabled BOOLEAN DEFAULT true;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS isFullSubjectEnabled BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS isDoNotSaveEnabled BOOLEAN DEFAULT false;

-- Add onboarding and statistics columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_absences INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS time_saved_minutes INTEGER DEFAULT 0;

-- Enable Row Level Security on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;

-- Create RLS policies for profiles
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
  ON public.profiles FOR DELETE
  USING (auth.uid() = id);

-- Create trigger function to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger to auto-create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- 2. PDF_FILES TABLE - Encrypted PDF metadata storage
-- ============================================================================

-- Create pdf_files table for storing encrypted PDF metadata
CREATE TABLE IF NOT EXISTS public.pdf_files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    date_of_absence TEXT NOT NULL,
    reason TEXT NOT NULL,
    pdf_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS pdf_files_user_id_idx ON public.pdf_files(user_id);
CREATE INDEX IF NOT EXISTS pdf_files_created_at_idx ON public.pdf_files(created_at DESC);

-- Enable Row Level Security on pdf_files
ALTER TABLE public.pdf_files ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own PDF files" ON public.pdf_files;
DROP POLICY IF EXISTS "Users can insert own PDF files" ON public.pdf_files;
DROP POLICY IF EXISTS "Users can delete own PDF files" ON public.pdf_files;

-- Create RLS policies for pdf_files
CREATE POLICY "Users can view own PDF files" ON public.pdf_files
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own PDF files" ON public.pdf_files
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own PDF files" ON public.pdf_files
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 3. FEEDBACK TABLE - Contact form submissions
-- ============================================================================

-- Create feedback table for contact form submissions
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    grund TEXT NOT NULL,
    nachricht TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS feedback_created_at_idx ON public.feedback(created_at DESC);

-- Enable Row Level Security on feedback
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can submit feedback" ON public.feedback;
DROP POLICY IF EXISTS "Service role can view all feedback" ON public.feedback;

-- Create RLS policies for feedback
-- Allow anyone (even unauthenticated users) to insert feedback
CREATE POLICY "Anyone can submit feedback" ON public.feedback
    FOR INSERT WITH CHECK (true);

-- Only service role can view all feedback (for admin purposes)
CREATE POLICY "Service role can view all feedback" ON public.feedback
    FOR SELECT USING (auth.jwt()->>'role' = 'service_role');

-- ============================================================================
-- 4. STORAGE BUCKETS - PDF file storage
-- ============================================================================

-- Create storage bucket for PDF files (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('pdf-files', 'pdf-files', false)
ON CONFLICT (id) DO NOTHING;

-- Drop existing storage policies if they exist
DROP POLICY IF EXISTS "Users can upload own PDFs" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own PDFs" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own PDFs" ON storage.objects;

-- Create storage policies for pdf-files bucket
CREATE POLICY "Users can upload own PDFs"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'pdf-files' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view own PDFs"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'pdf-files' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own PDFs"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'pdf-files' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ============================================================================
-- 5. REFRESH SCHEMA CACHE
-- ============================================================================

-- Refresh the PostgREST schema cache after migration
NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Tables created:
--   - profiles (with encryption support)
--   - pdf_files (encrypted PDF metadata)
--   - feedback (contact form)
--
-- Storage buckets created:
--   - pdf-files (encrypted PDF storage)
--
-- All Row Level Security policies configured
-- All indexes created for optimal performance
-- ============================================================================
