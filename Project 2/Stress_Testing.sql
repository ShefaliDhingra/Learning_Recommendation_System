use sd_LearningRecDB;

show tables;

-- Stress Testing Table Wise -- 

/* A. COMPLETION RECORDS */

-- 1. Entire table displayed
select * from sd_completion_records;

-- 2. Check Unique Values for a Specific User (Sanity Check)
select * from sd_completion_records where sd_user_id = 5;

-- 3. Ensure SD_RECORD_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(sd_record_id)) AS unique_records
FROM sd_completion_records;

-- Since both the values are same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_completion_records WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Entries (User & Course Combinations Should Be Unique)
SELECT sd_user_id, sd_course_id, COUNT(*)
FROM sd_completion_records
GROUP BY sd_user_id, sd_course_id
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate records present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT sd_user_id FROM sd_completion_records WHERE sd_user_id LIKE '%,%';

-- No comma seperated values, hence 1NF present

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_completion_records'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_completion_records'
);

-- This reveals that 2 columns in the table could be vulverable in the future, hence we will refine those fields

-- 7.1. Adding Not null constraint to Completion Records

ALTER TABLE sd_completion_records 
MODIFY SD_COMPLETION_DATE DATE NOT NULL;

-- 7.2. Adding check constraint to completion records since the data needs to be within 0 to 100%

ALTER TABLE sd_completion_records 
ADD CONSTRAINT check_progress 
CHECK (SD_PROGRESS_PERCENTAGE BETWEEN 0 AND 100);

-- 8. Foreign Key constraint check

-- 8.1. 
SELECT scr.* 
FROM sd_completion_records scr
LEFT JOIN sd_users su ON scr.sd_user_id = su.sd_user_id
WHERE su.sd_user_id IS NULL;

-- No Output, hence all sd_user_id values in sd_completion_records exist in sd_users

--  8.2. 

SELECT scr.* 
FROM sd_completion_records scr
LEFT JOIN sd_courses sc ON scr.sd_course_id = sc.sd_course_id
WHERE sc.sd_course_id IS NULL;

-- No Output, hence all sd_course_id values in sd_completion_records exist in sd_courses

-- 9. Check for Orphaned Records

-- 9.1
SELECT * FROM sd_completion_records
WHERE sd_user_id NOT IN (SELECT sd_user_id FROM sd_users);

-- Null output, hence no records exist in sd_completion_records with a sd_user_id that does not exist in sd_users

-- 9.2

SELECT * FROM sd_completion_records
WHERE sd_course_id NOT IN (SELECT sd_course_id FROM sd_courses);

-- Null output, hence no records exist with a sd_course_id that does not exist in sd_courses

-- 10. Check for invalid Dates

SELECT * FROM sd_completion_records 
WHERE SD_COMPLETION_DATE > CURDATE();

-- Null output, hence no invalid dates are present

-- 11. Check for Users with More Than One 100% Completed Course

SELECT sd_user_id, COUNT(*) AS completed_courses 
FROM sd_completion_records 
WHERE SD_PROGRESS_PERCENTAGE = 100
GROUP BY sd_user_id
HAVING completed_courses > 1;

-- 12. Check for Users Who Haven't Completed Any Course (0% Progress)

SELECT * FROM sd_completion_records 
WHERE SD_PROGRESS_PERCENTAGE = 0;

-- 13. Indexing for Faster Queries

CREATE INDEX idx_user_id ON sd_completion_records(sd_user_id);
CREATE INDEX idx_course_id ON sd_completion_records(sd_course_id);

-- ------------------------------------------------------------------------------------

-- B. USERS --

-- 1. Entire table displayed
SELECT * FROM sd_users;

-- 2. Check Unique Values for a Specific User (Sanity Check)
SELECT * FROM sd_users WHERE sd_user_id = 5;

-- 3. Ensure SD_USER_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(sd_user_id)) AS unique_records
FROM sd_users;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_users WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Email Addresses (Unique Constraint Check)
SELECT sd_user_email, COUNT(*) 
FROM sd_users 
GROUP BY sd_user_email 
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate email records present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT sd_user_id FROM sd_users WHERE sd_user_first_name LIKE '%,%' OR sd_user_last_name LIKE '%,%';

-- No comma-separated values, hence 1NF present

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_users'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_users'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- 7.1. Adding NOT NULL constraint to crucial fields

ALTER TABLE sd_users 
MODIFY sd_user_first_name VARCHAR(50) NOT NULL,
MODIFY sd_user_email VARCHAR(60) NOT NULL,
MODIFY sd_user_last_name VARCHAR(50) NOT NULL;

-- 7.2. Adding CHECK constraint to enforce valid email format (Only syntactic check)
ALTER TABLE sd_users 
ADD CONSTRAINT check_email_format 
CHECK (sd_user_email LIKE '%_@_%._%');

-- 8. Foreign Key constraint check (If this table references another table)

-- No foreign keys in this table, skipping this step

-- 9. Check for Orphaned Records (Not applicable since this is the primary table)

-- 10. Check for Invalid Dates (Future Signup Dates)
SELECT * FROM sd_users 
WHERE SD_USER_signup_date > CURDATE();

-- Null output, hence no invalid signup dates are present

-- 11. Check for Users with No Preferences Listed
SELECT * FROM sd_users WHERE SD_USER_preferences IS NULL OR SD_USER_preferences = '';

-- 12. Indexing for Faster Queries
CREATE INDEX idx_user_email ON sd_users(sd_user_email);

-- ------------------------------------------------------------------------------------

-- C. CATEGORIES --

-- 1. Entire table displayed
SELECT * FROM sd_categories;

-- 2. Check Unique Values for a Specific Category (Sanity Check)
SELECT * FROM sd_categories WHERE SD_CATEGORY_ID = 5;

-- 3. Ensure SD_CATEGORY_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(SD_CATEGORY_ID)) AS unique_records
FROM sd_categories;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_categories WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Category Names (Unique Constraint Check)
SELECT SD_CATEGORY_NAME, COUNT(*) 
FROM sd_categories 
GROUP BY SD_CATEGORY_NAME 
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate category names present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT SD_CATEGORY_ID FROM sd_categories WHERE SD_CATEGORY_NAME LIKE '%,%';

-- No comma-separated values, hence 1NF present

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_categories'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_categories'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- Adding NOT NULL constraint to category distribution

ALTER TABLE sd_categories 
MODIFY SD_CATEGORY_DESCRIPTION VARCHAR(100) NOT NULL;

-- 8. Foreign Key constraint check (If this table references another table)

-- No foreign keys in this table, skipping this step

-- 9. Check for Orphaned Records (Not applicable since this is a primary table)

-- 10. Check for Categories Without Descriptions
SELECT * FROM sd_categories WHERE SD_CATEGORY_DESCRIPTION IS NULL OR SD_CATEGORY_DESCRIPTION = '';

-- 11. Indexing for Faster Queries
CREATE INDEX idx_category_name ON sd_categories(SD_CATEGORY_NAME);

-- ------------------------------------------------------------------------------------

-- C. COURSES --

-- 1. Entire table displayed
SELECT * FROM sd_courses;

-- 2. Check Unique Values for a Specific Course (Sanity Check)
SELECT * FROM sd_courses WHERE SD_COURSE_ID = 5;

-- 3. Ensure SD_COURSE_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(SD_COURSE_ID)) AS unique_records
FROM sd_courses;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_courses WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Course Names (Unique Constraint Check)
SELECT SD_COURSE_NAME, COUNT(*) 
FROM sd_courses 
GROUP BY SD_COURSE_NAME 
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate course names present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT SD_COURSE_ID FROM sd_courses WHERE SD_COURSE_NAME LIKE '%,%';

-- No comma-separated values, hence 1NF present

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_courses'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_courses'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- 7.1. Adding NOT NULL constraint 

ALTER TABLE sd_courses 
MODIFY SD_COURSE_NAME VARCHAR(255) NOT NULL,
MODIFY SD_COURSE_RATING VARCHAR(255) NOT NULL;

-- 7.2. Ensuring Course Rating is Within Valid Range (0-5)
ALTER TABLE sd_courses 
ADD CONSTRAINT check_course_rating 
CHECK (SD_COURSE_RATING BETWEEN 0 AND 5);

-- 8. Foreign Key constraint check

-- 8.1. Check for courses with non-existent category IDs
SELECT sc.* 
FROM sd_courses sc
LEFT JOIN sd_categories cat ON sc.SD_CATEGORY_ID = cat.SD_CATEGORY_ID
WHERE cat.SD_CATEGORY_ID IS NULL;

-- No output displayed, hence all category IDs in sd_courses exist in sd_categories

-- 9. Check for Orphaned Records

-- 9.1. Ensure every course has a valid category
SELECT * FROM sd_courses
WHERE SD_CATEGORY_ID NOT IN (SELECT SD_CATEGORY_ID FROM sd_categories);

-- Null output, hence no records exist with an invalid category ID

-- 10. Check for Invalid Ratings (Values Outside Allowed Range)
SELECT * FROM sd_courses 
WHERE SD_COURSE_RATING < 0 OR SD_COURSE_RATING > 5;

-- Null output, hence no invalid ratings present

-- 11. Check for Courses Without Categories (NULL Foreign Key Values)
SELECT * FROM sd_courses WHERE SD_CATEGORY_ID IS NULL;

-- 12. Indexing for Faster Queries
CREATE INDEX idx_course_name ON sd_courses(SD_COURSE_NAME);
CREATE INDEX idx_category_id ON sd_courses(SD_CATEGORY_ID);

-- ------------------------------------------------------------------------------------

-- E. REVIEWS --

-- 1. Entire table displayed
SELECT * FROM sd_reviews;

-- 2. Check Unique Values for a Specific Review (Sanity Check)
SELECT * FROM sd_reviews WHERE SD_REVIEW_ID = 5;

-- 3. Ensure SD_REVIEW_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(SD_REVIEW_ID)) AS unique_records
FROM sd_reviews;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_reviews WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Reviews (Unique Constraint Check)
SELECT SD_USER_ID, SD_COURSE_ID, COUNT(*) 
FROM sd_reviews 
GROUP BY SD_USER_ID, SD_COURSE_ID
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate user-course reviews present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT SD_REVIEW_ID FROM sd_reviews WHERE SD_REVIEW LIKE '%,%';

-- No clear voilation of 1NF, still fixing the problem:

-- 6.1

SELECT SD_REVIEW_ID, SD_REVIEW 
FROM sd_reviews 
WHERE SD_REVIEW REGEXP '[0-9]+/[0-9]+'; 

-- The data is now present in 1NF

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_reviews'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_reviews'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- 7.1. Adding NOT NULL constraint to crucial fields

ALTER TABLE sd_reviews 
MODIFY SD_REVIEW TEXT NOT NULL,
MODIFY SD_REVIEW_RATING varchar (2) NOT NULL;

-- 7.2. Ensuring Review Rating is Within Valid Range (1-5)
ALTER TABLE sd_reviews 
ADD CONSTRAINT check_review_rating 
CHECK (SD_REVIEW_RATING BETWEEN 1 AND 5);

-- 8. Foreign Key constraint check

-- 8.1. Check for reviews with non-existent user IDs
SELECT sr.* 
FROM sd_reviews sr
LEFT JOIN sd_users su ON sr.SD_USER_ID = su.SD_USER_ID
WHERE su.SD_USER_ID IS NULL;

-- No output displayed, hence all user IDs in sd_reviews exist in sd_users

-- 8.2. Check for reviews with non-existent course IDs
SELECT sr.* 
FROM sd_reviews sr
LEFT JOIN sd_courses sc ON sr.SD_COURSE_ID = sc.SD_COURSE_ID
WHERE sc.SD_COURSE_ID IS NULL;

-- No output displayed, hence all course IDs in sd_reviews exist in sd_courses

-- 9. Check for Orphaned Records

-- 9.1. Ensure every review has a valid user
SELECT * FROM sd_reviews
WHERE SD_USER_ID NOT IN (SELECT SD_USER_ID FROM sd_users);

-- Null output, hence no records exist with an invalid user ID

-- 9.2. Ensure every review has a valid course
SELECT * FROM sd_reviews
WHERE SD_COURSE_ID NOT IN (SELECT SD_COURSE_ID FROM sd_courses);

-- Null output, hence no records exist with an invalid course ID

-- 10. Check for Invalid Ratings (Values Outside Allowed Range)
SELECT * FROM sd_reviews 
WHERE SD_REVIEW_RATING < 1 OR SD_REVIEW_RATING > 5;

-- Null output, hence no invalid ratings present

-- 11. Check for Reviews Without Any Text
SELECT * FROM sd_reviews WHERE SD_REVIEW IS NULL OR SD_REVIEW = '';

-- 12. Indexing for Faster Queries
CREATE INDEX idx_user_id ON sd_reviews(SD_USER_ID);
CREATE INDEX idx_course_id ON sd_reviews(SD_COURSE_ID);

-- ------------------------------------------------------------------------------------

-- F. COURSE OUTLINES --

-- 1. Entire table displayed
SELECT * FROM sd_course_outlines;

-- 2. Check Unique Values for a Specific Outline (Sanity Check)
SELECT * FROM sd_course_outlines WHERE SD_OUTLINE_ID = 5;

-- 3. Ensure SD_OUTLINE_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(SD_OUTLINE_ID)) AS unique_records
FROM sd_course_outlines;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_course_outlines WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Outlines (Unique Constraint Check)
SELECT SD_USER_ID, COUNT(*) 
FROM sd_course_outlines 
GROUP BY SD_USER_ID
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate outlines for the same user present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT SD_OUTLINE_ID FROM sd_course_outlines WHERE SD_COURSE_OUTLINE_CONTENT LIKE '%,%';

-- Rectifying the output and making it into 1NF

-- 6.1. Check
SELECT SD_OUTLINE_ID, SD_COURSE_OUTLINE_CONTENT 
FROM sd_course_outlines 
WHERE SD_COURSE_OUTLINE_CONTENT LIKE '%,%';

-- Since it is expected output (the outline content is supposed to contain CSV values hence, it is no in 1NF form voilation
-- Hence to not complicate the data further, we did not split it into mupliple columns 

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_course_outlines'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_course_outlines'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- 7.1. Adding NOT NULL constraint to crucial fields

ALTER TABLE sd_course_outlines 
MODIFY SD_COURSE_OUTLINE_CONTENT TEXT NOT NULL;

-- 8. Foreign Key constraint check

-- 8.1. Check for outlines with non-existent user IDs
SELECT sco.* 
FROM sd_course_outlines sco
LEFT JOIN sd_users su ON sco.SD_USER_ID = su.SD_USER_ID
WHERE su.SD_USER_ID IS NULL;

-- No output displayed, hence all user IDs in sd_course_outlines exist in sd_users

-- 9. Check for Orphaned Records

SELECT * FROM sd_course_outlines
WHERE SD_USER_ID NOT IN (SELECT SD_USER_ID FROM sd_users);

-- Null output, hence no records exist with an invalid user ID

-- 10. Check for Empty Course Outlines
SELECT * FROM sd_course_outlines WHERE SD_COURSE_OUTLINE_CONTENT IS NULL OR SD_COURSE_OUTLINE_CONTENT = '';

-- 11. Indexing for Faster Queries
CREATE INDEX idx_user_id ON sd_course_outlines(SD_USER_ID);

-- ------------------------------------------------------------------------------------

-- G. RECOMMENDATIONS --

-- 1. Entire table displayed
SELECT * FROM sd_recommendations;

-- 2. Check Unique Values for a Specific Recommendation (Sanity Check)
SELECT * FROM sd_recommendations WHERE SD_RECOMMENDATION_ID = 5;

-- 3. Ensure SD_RECOMMENDATION_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(SD_RECOMMENDATION_ID)) AS unique_records
FROM sd_recommendations;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_recommendations WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Recommendations (Unique Constraint Check)
SELECT SD_USER_ID, SD_COURSE_ID, COUNT(*) 
FROM sd_recommendations 
GROUP BY SD_USER_ID, SD_COURSE_ID
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate recommendations present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT SD_RECOMMENDATION_ID FROM sd_recommendations WHERE SD_RECOMMENDATION_LOGIC LIKE '%,%';

-- Multiple values exist, hence exploring further

-- 6.1. check for voilations

SELECT SD_RECOMMENDATION_ID, SD_RECOMMENDATION_LOGIC 
FROM sd_recommendations 
WHERE SD_RECOMMENDATION_LOGIC LIKE '%,%' AND SD_RECOMMENDATION_LOGIC REGEXP '[0-9]+'; 

-- Only 1 record having values, but since it is text data it is supposed to have this comma value, hence no unexpected voilation of 1NF

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_recommendations'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_recommendations'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- 7.1. Adding NOT NULL constraint to crucial fields

ALTER TABLE sd_recommendations 
MODIFY SD_RECOMMENDATION_LOGIC TEXT NOT NULL;

-- 8. Foreign Key constraint check

-- 8.1. Check for recommendations with non-existent user IDs
SELECT sr.* 
FROM sd_recommendations sr
LEFT JOIN sd_users su ON sr.SD_USER_ID = su.SD_USER_ID
WHERE su.SD_USER_ID IS NULL;

-- No output displayed, hence all user IDs in sd_recommendations exist in sd_users

-- 8.2. Check for recommendations with non-existent course IDs
SELECT sr.* 
FROM sd_recommendations sr
LEFT JOIN sd_courses sc ON sr.SD_COURSE_ID = sc.SD_COURSE_ID
WHERE sc.SD_COURSE_ID IS NULL;

-- No output displayed, hence all course IDs in sd_recommendations exist in sd_courses

-- 9. Check for Orphaned Records

-- 9.1. Ensure every recommendation has a valid user
SELECT * FROM sd_recommendations
WHERE SD_USER_ID NOT IN (SELECT SD_USER_ID FROM sd_users);

-- Null output, hence no records exist with an invalid user ID

-- 9.2. Ensure every recommendation has a valid course
SELECT * FROM sd_recommendations
WHERE SD_COURSE_ID NOT IN (SELECT SD_COURSE_ID FROM sd_courses);

-- Null output, hence no records exist with an invalid course ID

-- 10. Check for Empty Recommendation Logic
SELECT * FROM sd_recommendations WHERE SD_RECOMMENDATION_LOGIC IS NULL OR SD_RECOMMENDATION_LOGIC = '';

-- 11. Indexing for Faster Queries
CREATE INDEX idx_user_id ON sd_recommendations(SD_USER_ID);
CREATE INDEX idx_course_id ON sd_recommendations(SD_COURSE_ID);

-- ------------------------------------------------------------------------------------

-- H. OUTLINE-BASED RECOMMENDATIONS --

-- 1. Entire table displayed
SELECT * FROM sd_outline_recommendations;

-- 2. Check Unique Values for a Specific Recommendation (Sanity Check)
SELECT * FROM sd_outline_recommendations WHERE SD_RECOMMENDATION_ID = 5;

-- 3. Ensure SD_RECOMMENDATION_ID is Unique (Primary Key Check)
SELECT COUNT(*) AS total_records, COUNT(DISTINCT(SD_RECOMMENDATION_ID)) AS unique_records
FROM sd_outline_recommendations;

-- Since both values are the same, primary key is working correctly

-- 4. Confirm PRIMARY KEY Constraint Exists
SHOW KEYS FROM sd_outline_recommendations WHERE Key_name = 'PRIMARY';

-- 5. Check for Duplicate Outline Recommendations (Unique Constraint Check)
SELECT SD_OUTLINE_ID, SD_COURSE_ID, COUNT(*) 
FROM sd_outline_recommendations 
GROUP BY SD_OUTLINE_ID, SD_COURSE_ID
HAVING COUNT(*) > 1;

-- No output displayed, hence no duplicate recommendations present

-- 6. Check for 1st Normal Form Violations (No Multivalued Attributes)
SELECT SD_RECOMMENDATION_ID FROM sd_outline_recommendations WHERE SD_MATCH_SCORE LIKE '%,%';

-- No comma-separated values in structured format, hence 1NF present

-- 7. Find Columns Without Constraints (Potentially Uncontrolled Data)
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'sd_outline_recommendations'
AND column_name NOT IN (
    SELECT column_name FROM information_schema.key_column_usage
    WHERE table_name = 'sd_outline_recommendations'
);

-- This reveals that some columns could be vulnerable, refining constraints as needed

-- 7.1. Adding CHECK constraint to enforce valid match score range (0-100)
ALTER TABLE sd_outline_recommendations 
ADD CONSTRAINT check_match_score 
CHECK (SD_MATCH_SCORE BETWEEN 0 AND 100);

-- 8. Foreign Key constraint check

-- 8.1. Check for recommendations with non-existent outline IDs
SELECT sor.* 
FROM sd_outline_recommendations sor
LEFT JOIN sd_course_outlines sco ON sor.SD_OUTLINE_ID = sco.SD_OUTLINE_ID
WHERE sco.SD_OUTLINE_ID IS NULL;

-- No output displayed, hence all outline IDs in sd_outline_recommendations exist in sd_course_outlines

-- 8.2. Check for recommendations with non-existent course IDs
SELECT sor.* 
FROM sd_outline_recommendations sor
LEFT JOIN sd_courses sc ON sor.SD_COURSE_ID = sc.SD_COURSE_ID
WHERE sc.SD_COURSE_ID IS NULL;

-- No output displayed, hence all course IDs in sd_outline_recommendations exist in sd_courses

-- 9. Check for Orphaned Records

-- 9.1. Ensure every recommendation has a valid outline
SELECT * FROM sd_outline_recommendations
WHERE SD_OUTLINE_ID NOT IN (SELECT SD_OUTLINE_ID FROM sd_course_outlines);

-- Null output, hence no records exist with an invalid outline ID

-- 9.2. Ensure every recommendation has a valid course
SELECT * FROM sd_outline_recommendations
WHERE SD_COURSE_ID NOT IN (SELECT SD_COURSE_ID FROM sd_courses);

-- Null output, hence no records exist with an invalid course ID

-- 10. Check for Invalid Match Scores (Values Outside Allowed Range)
SELECT * FROM sd_outline_recommendations 
WHERE SD_MATCH_SCORE < 0 OR SD_MATCH_SCORE > 100;

-- Null output, hence no invalid match scores present

-- 11. Indexing for Faster Queries
CREATE INDEX idx_outline_id ON sd_outline_recommendations(SD_OUTLINE_ID);
CREATE INDEX idx_course_id ON sd_outline_recommendations(SD_COURSE_ID);

-- ---------------------------- End of Document ------------------------------------ --
