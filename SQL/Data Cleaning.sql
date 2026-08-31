SELECT * 
FROM layoffs;

SET AUTOCOMMIT = 0;
-- CREATE THE DUPLLICATE TABLE OF LAYOFFS  FOR DATA CLEANING

SELECT *
FROM layoffs_stagging;

CREATE TABLE  layoffs_stagging
LIKE layoffs;

INSERT INTO layoffs_stagging
SELECT *
FROM layoffs;

-- Before DATA CLEANING 
--   						NOT NULL     NULl
-- total rows				 4575		  0
-- comapny					 4575         0
-- location 				 4574		  1
-- total_laid_off  			 2989		  1586
-- date  					 4575		  0
-- percentage_laid_off 		 2871		  1704
-- industry  				 4573		  2
-- source      				 4572		  3
-- stage     				 4567		  8
-- funds_raised  		 	 4033		  542
-- country 					 4573         2
-- date_added   			 4575		  0

-- CHECK FOR DUPLICATES
WITH duplicates AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, total_laid_off, `date`,
					percentage_laid_off, industry,  `source`,  stage,  funds_raised,  
					country, date_added) AS Row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicates
WHERE Row_num>1;

-- there is no duplicate row available 


-- STANDARDIZATION 

SELECT DISTINCT company,trim(company)
FROM layoffs_stagging;

ALTER TABLE layoffs_stagging
MODIFY COLUMN company VARCHAR(255);


SELECT DISTINCT location
FROM layoffs_stagging;

SELECT * 
FROM layoffs_stagging
WHERE location = '';

SELECT *
FROM layoffs_stagging
WHERE company ='Product Hunt';

SELECT *
FROM layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
WHERE ls.location = ''
AND ls1.location !='';

ALTER TABLE layoffs_stagging
MODIFY COLUMN location VARCHAR(255);


SELECT total_laid_off
FROM layoffs_stagging;

UPDATE layoffs_stagging
SET total_laid_off = NULL
WHERE total_laid_off = '';

SELECT *
FROM layoffs_stagging
WHERE total_laid_off IS NULL;

ALTER TABLE layoffs_stagging
MODIFY COLUMN total_laid_off INT;


SELECT `date`,STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_stagging;

UPDATE layoffs_stagging
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_stagging
MODIFY COLUMN `date` DATE;


SELECT *
FROM layoffs
WHERE percentage_laid_off = '';

SELECT *
FROM layoffs_stagging
WHERE percentage_laid_off IS NOT NULL;

UPDATE layoffs_stagging
SET percentage_laid_off= NULL
WHERE percentage_laid_off='' ;

ALTER TABLE layoffs_stagging
MODIFY COLUMN percentage_laid_off DECIMAL(10,2);


SELECT DISTINCT industry
FROM layoffs_stagging;

SELECT *
FROM layoffs_stagging
WHERE industry ='';

SELECT DISTINCT industry
FROM layoffs_stagging;

SELECT * 
FROM layoffs_stagging
WHERE industry IS NULL;

UPDATE layoffs_stagging
SET industry = NULL
WHERE industry = '';

SELECT ls.company,ls.industry,ls1.company,ls1.industry
FROM layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
WHERE (ls.industry IS NULL  OR ls.industry ='')
AND ls1.industry IS NOT NULL;

ALTER TABLE layoffs_stagging
MODIFY COLUMN industry VARCHAR(255);


SELECT *
FROM layoffs_stagging
WHERE `source` IS NULL;

UPDATE layoffs_stagging
SET `source` = NULL 
WHERE `source` = '';

SELECT *
FROM layoffs_stagging
WHERE company ='Tapas Media';

SELECT ls.company,ls.`source`,ls1.company,ls1.`source`
FROM layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
WHERE (ls.`source` IS NULL  OR ls.`source` ='')
AND ls1.`source` IS NOT NULL;

UPDATE layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
SET ls.`source` = ls1.`source`
WHERE (ls.`source` IS NULL  OR ls.`source` ='')
AND ls1.`source` IS NOT NULL;

ALTER TABLE layoffs_stagging
MODIFY COLUMN `source` VARCHAR(500);


SELECT DISTINCT stage
FROM layoffs_stagging;

SELECT *
FROM layoffs_stagging
WHERE stage ='Unknown';

SELECT *
FROM layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
WHERE (ls.stage IS NULL  OR ls.stage ='')
AND ls1.stage IS NOT NULL;

UPDATE layoffs_stagging
SET stage = NULL 
WHERE stage = '';

UPDATE layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
SET ls.stage = ls1.stage
WHERE (ls.stage IS NULL OR ls.stage ='')
AND ls1.stage IS NOT NULL;

ALTER TABLE layoffs_stagging
MODIFY COLUMN stage VARCHAR(500);


SELECT * 
FROM layoffs_stagging
WHERE funds_raised IS NULL;

UPDATE layoffs_stagging
SET funds_raised = NULL 
WHERE funds_raised = '';

ALTER TABLE layoffs_stagging
MODIFY COLUMN funds_raised DECIMAL(12,2);


SELECT DISTINCT country
FROM layoffs_stagging;

SELECT *
FROM layoffs_stagging
WHERE country IS NULL;

SELECT *
FROM layoffs_stagging
WHERE company = 'Fit Analytics';

UPDATE layoffs_stagging
SET country = null
WHERE country = '';

SELECT *
FROM layoffs_stagging ls
JOIN layoffs_stagging ls1
ON ls.company = ls1.company
WHERE ls.country IS NULL
AND ls1.country IS NOT NULL;


SELECT date_added,STR_TO_DATE(date_added,'%m/%d/%Y')
FROM layoffs_stagging;
 
UPDATE layoffs_stagging
SET date_added = STR_TO_DATE(date_added,'%m/%d/%Y');

ALTER TABLE layoffs_stagging
MODIFY COLUMN  date_added DATE;

-- Removed Records Without Layoff Information

SELECT COUNT(*)
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_stagging;
COMMIT;  
SET AUTOCOMMIT = 1;

-- DATA VALIDATION

SELECT *
FROM layoffs_stagging
WHERE percentage_laid_off < 0
   OR percentage_laid_off > 1;

SELECT *
FROM layoffs_stagging
WHERE location IS NULL
   OR industry IS NULL
   OR stage IS NULL
   OR country IS NULL;

   SELECT *
   FROM layoffs_stagging;
   
-- AFTER DATA CLEANING 
--   						NOT NULL     NULl
-- total rows				 3832		  0
-- comapny					 3832         0
-- location 				 3831		  1
-- total_laid_off  			 2989		  843
-- date  					 3832		  0
-- percentage_laid_off 		 2871		  961
-- industry  				 3830		  2
-- source      				 3832		  0
-- stage     				 3827		  5
-- funds_raised  		 	 3392		  440
-- country 					 3830         2
-- date_added   			 3832		  0	


