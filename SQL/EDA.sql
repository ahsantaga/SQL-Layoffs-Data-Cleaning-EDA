-- EDA 

-- top 10 companies by total layoffs

SELECT
    company,
    SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY Total_Laid_Off DESC
Limit 10;

-- largest single layoff events.
SELECT company ,
total_laid_off ,
percentage_laid_off,
date,
industry,
country
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;

-- MAX & min 
SELECT MAX(total_laid_off) AS Max_Total_Laid_Off,
MAX(percentage_laid_off) AS Max_Percentage_Laid_Off
FROM layoffs_stagging;

SELECT company,
    total_laid_off,
    percentage_laid_off,
    funds_raised,
    `date`
FROM layoffs_stagging
WHERE percentage_laid_off =1
ORDER BY funds_raised DESC;

-- Starting and ending date
SELECT MIN(`date`) AS Starting_date ,MAX(`date`) AS Latest_date
FROM layoffs_stagging;

-- by Industry
SELECT industry,
SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;

-- by country
SELECT country,
SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;
-- TOTAL_LAID_OFF
-- by location
SELECT location,
SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;


WITH monthly_layoffs AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`,SUM(total_laid_off) AS Total_Off
FROM layoffs_stagging
where total_laid_off IS NOT NULL
GROUP BY  `MONTH`
ORDER BY 1 ASC
)
SELECT `Month`,Total_Off,
LAG(Total_Off) OVER(ORDER BY `Month`) AS Prev_month,
Lead(Total_Off) OVER(ORDER BY `Month`) AS Next_month,
SUM(Total_Off) OVER(ORDER BY `Month`) AS running_Total
FROM monthly_layoffs;

-- yearly layoff
SELECT YEAR(`date`) AS `Year`,
SUM(total_laid_off ) AS Total_off,
SUM(SUM(total_laid_off )) OVER
(ORDER BY YEAR(`date`)) AS Running_total
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY `Year`;

-- total_laid_off by company over time
SELECT company,
YEAR(`date`) AS `Year`,
sum(total_laid_off)
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;

-- top 5 company by year 
WITH company_year AS
(
 SELECT company,YEAR(`date`) AS Years,sum(total_laid_off) Total_off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY company,YEAR(`date`)
),
company_year_rank AS
(
 SELECT *,
 DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_off DESC) AS Ranking
 FROM company_year 
)
SELECT *
FROM company_year_rank
WHERE ranking <=5;