-- Migration script to add category column to salons table
-- This script can be run manually on Railway database if needed
-- Note: With spring.jpa.hibernate.ddl-auto=update, this should be done automatically

-- Add category column to salons table
ALTER TABLE salons 
ADD COLUMN category VARCHAR(255) NULL 
COMMENT 'Salon category (e.g., Men''s Salon, Women''s Salon, Unisex, Makeup, Facial, Hair Care)';

-- Update existing salons with default category if needed (optional)
-- UPDATE salons SET category = 'Unisex' WHERE category IS NULL;

