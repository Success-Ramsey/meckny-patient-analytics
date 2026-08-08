-- step 1: create a database
CREATE DATABASE meckny_patient_db; 

-- step 3: create a staging table
CREATE TABLE patient_staging 
LIKE messy_patients;

-- 4. insert values into the staged table
INSERT INTO patient_staging
SELECT *
FROM messy_patients;

-- 5. preview the new table
SELECT *
FROM patient_staging; -- I have 97 rows and 8 fields

-- 6. 	EDA!
-- 1. explore each fields
SELECT *
FROM patient_staging; -- patient_id, full_name, gender, age, diagnosis, blood_pressure, weight_kg, admission_date

-- a. name field
SELECT full_name
FROM patient_staging;  -- there are blanks, improper standardization, white space

-- i. check the rows with blank
SELECT full_name
FROM patient_staging
WHERE full_name = ''; -- there are 4 blank rows

-- CLEANING THE BLANK ROWS
UPDATE patient_staging
SET full_name = 'N/A'
WHERE full_name = ''; -- 4 changes where made 

-- ii. check for whitespace
SELECT full_name
FROM patient_staging
WHERE full_name != TRIM(full_name); -- there are 14 names with white spaces 

-- CLEANING FOR WHITESPACE
UPDATE patient_staging
SET full_name = TRIM(full_name); -- 14 rows cleaned

-- iii. check rows with improper standardization
SELECT DISTINCT full_name
FROM patient_staging
ORDER BY full_name ASC; -- there are 3 rws with improper standardztion; LINDA WILSON, CHRIS GONZALEZ, ANNA JONES, DAVID WILLIAMS, ELUZABETH MILLER, LINDA WILLIAMS, MARIA SMITH, ROBERT JOHNSON

-- CLEANING FR IMPROPER STANDARDIZATION
UPDATE patient_staging p
JOIN messy_patients m ON p.patient_id = m.patient_id
SET p.full_name = m.full_name;

-- removing ',' in full name
UPDATE patient_staging
SET full_name = replace(full_name,',',''); -- changed 15 rows

-- CREATED A PROPERCASE FUNCTION

-- proper standardization
UPDATE patient_staging
SET full_name = ProperCase(full_name);


-- b. gender
SELECT DISTINCT gender
FROM patient_staging; -- there are blanks, improper standardization, F and M

-- i. check for blanks
SELECT gender, full_name
FROM patient_staging 
WHERE gender = ''; -- there are 9 blank rows

-- CLEANING AND FILLING BLANKS
-- for male patients with bank gender rows
UPDATE patient_staging
SET gender = 'M'
WHERE full_name IN ('james Brown','Charles Anderson', 'Charles Smith'); -- affected 5 rows these shws there are duplicates

-- for female patients with bank gender rows
UPDATE patient_staging
SET gender = 'F'
WHERE full_name IN ('ELIZABETH MILLER', 'Anna Martin', 'Jane Jackson', 'Emily Rodriguez', 'Maria Davis', 'EMILY RODRIGUEZ'); -- 9 rows changed, these indiates duplicates

-- ii. check improper standardization
SELECT gender
FROM patient_staging
WHERE gender = 'FEMALE'; -- there are 15

-- CLEANING THE GENDER TO F,M
-- aii. to 'F'
UPDATE patient_staging
SET gender = 'F'
WHERE gender IN ('FEMALE', 'Female'); -- 23 rows changed
-- bii. to 'M'
UPDATE patient_staging
SET gender = 'M'
WHERE gender = 'male';

select gender, full_name
FROM patient_staging; --   Jennifer Anderson, David Rodriguez, Michael Jackson, (Gonzalez, Robert), DAVID WILLIAMS, LINDA WILSON, (Thomas, Linda), Sarah Taylor, Susan Thomas, Thomas Johnson, Michael Jackson,   Anna Thomas, Jennifer Jackson, Thomas Jones, (Smith, Mike), Robert Wilson, Emily Garcia, John Hernandez, Patricia Jackson, (Brown, Anna), Susan Jones, Thomas Rodriguez  

-- dii.  reset these frm 'm' to 'f'
UPDATE patient_staging
SET gender = 'F'
WHERE TRIM(full_name) IN ('Jennifer Anderson', 'LINDA WILSON', 'Thomas, Linda', 'Sarah Taylor', 'Susan Thomas', 'Anna Thomas', 'Jennifer Jackson', 'Emily Garcia', 'Patricia Jackson', 'Brown, Anna', 'Susan Jones'); -- HANGED 12 ROWS

-- eii. reset these frm f to 'm'
UPDATE patient_staging
SET gender = 'M'
WHERE TRIM(full_name) IN ('John Miller','David Rodriguez', 'Michael Jackson', 'Gonzalez, Robert', 'DAVID WILLIAMS', 'Thomas Johnson', 'Michael Jackson','Smith, Mike', 'Robert Wilson', 'John Hernandez','Thomas Rodriguez'); -- HANGED 12 ROWS

-- c. age
SELECT age
FROM patient_staging; -- there are outliers and invalid values

-- i. check for outliners
SELECT age, full_name
FROM patient_staging
WHERE age = 999; -- there are 4 rows
-- CLEAN UTLIERS
UPDATE patient_staging
SET age = NULL  -- CHANGED FRM 44 TO NULL
WHERE TRIM(full_name) IN ('CHRIS GONZALEZ','John Miller','Robert Wilson','Thomas Jones'); -- i wanted to use 'N/A' but it was reognised as a string so i used 44

-- ii. check for invalids
SELECT age
FROM patient_staging
WHERE age LIKE '%-%'; -- there are 3 rows (-59, -75, -86)
-- CLEAN NEGATIVE AGE
UPDATE patient_staging
SET age = REPLACE(age, '-', ''); -- 3 rws changed

-- d. diagnosis
SELECT distinct diagnosis
FROM patient_staging; -- there blanks, aroynms that needs to be replaced ; CAD, OA, T2DM, HTN

-- i. check for blanks
SELECT diagnosis, full_name, blood_pressure
FROM patient_staging
WHERE diagnosis = ''; -- there 6 rows
--  
UPDATE patient_staging
SET diagnosis = 'N/A'
WHERE diagnosis = ''; -- 6 rows changed
--
UPDATE patient_staging
SET diagnosis = 'Coronary Artery Disease'
WHERE diagnosis IN ('CAD'); -- 2 ROWS HAANGED

UPDATE patient_staging
SET diagnosis = 'Type II Diabetes'
WHERE diagnosis IN ('Type 2 Diabetes', 'T2DM', 'Diabetes Type 2'); -- 10 RWS CHANGED

UPDATE patient_staging
SET diagnosis = 'Osteo Arthritis'
WHERE diagnosis IN ('osteoarthritis', 'OA'); -- 6 ROWS CHANGED

UPDATE patient_staging
SET diagnosis = 'Osteoarthritis'
WHERE diagnosis = 'Osteo Arthritis'; -- 6 changed

UPDATE patient_staging
SET diagnosis = 'Hypertension'
WHERE diagnosis IN ('Htn'); -- I ROW HANGED

UPDATE patient_staging
SET diagnosis = 'Influenza'
WHERE diagnosis IN ('Flu'); -- 1 changed

UPDATE patient_staging
SET diagnosis = 'Hypothyroid'
WHERE diagnosis IN ('hypothyroidism'); -- 2 ROWS HANGED

UPDATE patient_staging
SET diagnosis = 'Anxiety Disorder'
WHERE diagnosis IN ('Anxiety'); -- 4 changed

-- ii. check for the IMPROPER STANDARDIZATION
update patient_staging
set diagnosis = ProperCase(diagnosis); -- 36 changed

-- e. blood pressure
SELECT blood_pressure
FROM patient_staging; -- there are blanks, - speratoor, white space

-- i. check for blanks
SELECT blood_pressure
FROM patient_staging
WHERE blood_pressure = ''; -- 15 rows
-- CLEAN BLANKS, REPLACE WITH N/alter
UPDATE patient_staging
SET blood_pressure = 'N/A'
WHERE blood_pressure = ''; -- 15 CHANGED

-- ii. check for - seperator
SELECT blood_pressure
FROM patient_staging
WHERE blood_pressure LIKE '%-%'; -- 15 rows
-- REPLACE - WITH /
UPDATE patient_staging
SET blood_pressure = REPLACE(blood_pressure,'-','/'); -- 15 CHANGED

-- iii. check fr whitespaces
SELECT blood_pressure
FROM patient_staging
WHERE blood_pressure LIKE '% %'; -- 5 rows
-- CLEAN WHITESPACE
UPDATE patient_staging
SET blood_pressure = REPLACE(blood_pressure, ' ', ''); -- 5 rows cleaned

-- f. weight
SELECT weight_kg 
FROM patient_staging; -- there are vaues without 'kg', blanks, - values, no space before 'kg'

-- i. check values without kg
SELECT weight_kg
FROM patient_staging
WHERE weight_kg NOT LIKE '%kg%'; -- 71 rows
-- ADD KG TO THE VALUES
UPDATE patient_staging
SET weight_kg = CONCAT(weight_kg, ' kg')
WHERE weight_kg NOT LIKE '%kg%'; -- CHANGED 71 ROWS


-- ii. check blanks
SELECT weight_kg
FROM patient_staging
WHERE weight_kg = ''; -- 14 rows
-- CLEAN BLANKS 
UPDATE patient_staging
SET weight_kg = 'N/A'
WHERE weight_kg ='kg'; -- 14 CHANGED

-- iii. check fr values with - 
SELECT weight_kg
FROM patient_staging
WHERE weight_kg LIKE '%-%'; -- 3 rows with -5 value
-- CLEAN
UPDATE patient_staging
SET weight_kg = REPLACE(weight_kg, '-', ''); -- 3 changed

-- iv. check for values with no spce before 'kg'
SELECT weight_kg
FROM patient_staging
WHERE weight_kg NOT LIKE '% %'; -- over 15 rows

-- v. remoe whitesace from weght
UPDATE patient_staging
SET weight_kg = REPLACE(weight_kg, ' ', ''); -- cleaned 24 white spaces

-- h. admission date
SELECT admission_date
FROM patient_staging; -- / seperatoor, full string values, n/a values

-- i. replace
UPDATE patient_staging
SET admission_date = REPLACE (admission_date, '/', '-'); -- 30 changed

-- ii. fill blnks
UPDATE patient_staging
SET admission_date = NULL
WHERE admission_date = ''; -- 3 CHANGED

UPDATE patient_staging
SET diagnosis = NULL
WHERE diagnosis = 'N/A';

-- c. update the date format to YMD
UPDATE patient_staging
SET admission_date = 
  CASE
    -- Already YYYY-MM-DD
    WHEN admission_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      THEN STR_TO_DATE(admission_date, '%Y-%m-%d')

    -- MM-DD-YYYY (first number <= 12, safe assumption for US format)
    WHEN admission_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
         AND SUBSTRING_INDEX(admission_date, '-', 1) <= 12
      THEN STR_TO_DATE(admission_date, '%m-%d-%Y')

    -- DD-MM-YYYY (first number > 12, must be a day)
    WHEN admission_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
         AND SUBSTRING_INDEX(admission_date, '-', 1) > 12
      THEN STR_TO_DATE(admission_date, '%d-%m-%Y')
    -- "December 15, 2024" style
    WHEN admission_date REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$'
      THEN STR_TO_DATE(admission_date, '%M %d, %Y')
    ELSE NULL
  END;

SELECT admission_date
FROM patient_staging;

-- I. patient id
SELECT patient_id -- inconsitencies and dupliates
FROM patient_staging;

-- a. create a unique identifier column
ALTER TABLE patient_staging DROP COLUMN ID;
ALTER TABLE patient_staging ADD COLUMN ID INT AUTO_INCREMENT PRIMARY KEY;

UPDATE patient_staging 
SET patient_id = ID; -- HANGED

SELECT patient_id, ID
FROM patient_staging; -- CONFIRMED

-- J. REMOVE DUPIATES
select *
from patient_staging;

DELETE p1
FROM patient_staging p1
INNER JOIN patient_staging p2
WHERE p1.ID > p2.ID
AND p1.full_name = p2.full_name; -- 11 rows changed

select full_name 
from patient_staging
WHERE full_name > 1;

select full_name
from patient_staging
where full_name = 'Maria Davis';

select full_name, count(*)
from patient_staging
group by full_name
having count(*) > 1; -- patient_id, full_name, gender, age, blood_presure, weight, admission_date, id


select *
from patient_staging;

-- CREATE YEAR COLUMN 
ALTER TABLE patient_staging
ADD COLUMN admission_year INT GENERATED ALWAYS AS (YEAR(admission_date)) STORED; -- i realized that using n/a for date field is nt advisable and i changed to 'null'