# SQL Layoffs Data Cleaning & Exploratory Data Analysis

### MySQL | Data Cleaning | Exploratory Data Analysis | Window Functions | Business Intelligence

An end-to-end **MySQL data cleaning and exploratory data analysis project** using a layoffs dataset.

The project demonstrates how raw data can be cleaned, standardized, validated, and analyzed using SQL to identify trends in layoffs across companies, industries, countries, locations, and time periods.

---

## Project Overview

This project focuses on two major stages:

1. **Data Cleaning**
2. **Exploratory Data Analysis (EDA)**

The raw dataset contained missing values, inconsistent data types, empty strings, and incomplete records.

A staging table was created to preserve the original dataset while performing the cleaning process.

The cleaned dataset was then analyzed to identify major layoff patterns and business insights.

---

## Dataset

The dataset contains information about company layoffs.

| Column | Description |
|---|---|
| `company` | Name of the company |
| `location` | Location associated with the company |
| `total_laid_off` | Number of employees laid off |
| `date` | Date of the layoff event |
| `percentage_laid_off` | Percentage of the workforce laid off |
| `industry` | Industry of the company |
| `source` | Source of the layoff information |
| `stage` | Company funding/business stage |
| `funds_raised` | Funds raised by the company |
| `country` | Country associated with the company |
| `date_added` | Date the record was added |

---

# Data Cleaning

## 1. Created a Staging Table

A duplicate staging table was created from the original `layoffs` table so that the original data remained unchanged.

```sql
CREATE TABLE layoffs_stagging
LIKE layoffs;

INSERT INTO layoffs_stagging
SELECT *
FROM layoffs;
```

---

## 2. Initial Data Quality Assessment

Before cleaning, the dataset contained **4,575 records**.

| Column | Non-NULL | NULL |
|---|---:|---:|
| Company | 4,575 | 0 |
| Location | 4,574 | 1 |
| Total Laid Off | 2,989 | 1,586 |
| Date | 4,575 | 0 |
| Percentage Laid Off | 2,871 | 1,704 |
| Industry | 4,573 | 2 |
| Source | 4,572 | 3 |
| Stage | 4,567 | 8 |
| Funds Raised | 4,033 | 542 |
| Country | 4,573 | 2 |
| Date Added | 4,575 | 0 |

---

## 3. Duplicate Detection

Duplicates were checked using `ROW_NUMBER()`.

```sql
WITH duplicates AS
(
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company,
                            location,
                            total_laid_off,
                            `date`,
                            percentage_laid_off,
                            industry,
                            `source`,
                            stage,
                            funds_raised,
                            country,
                            date_added
           ) AS Row_num
    FROM layoffs_stagging
)
SELECT *
FROM duplicates
WHERE Row_num > 1;
```

No duplicate records were identified during the duplicate check.

---

## 4. Missing Value Standardization

Empty strings were converted to `NULL` values where appropriate.

### Total Laid Off

```sql
UPDATE layoffs_stagging
SET total_laid_off = NULL
WHERE total_laid_off = '';
```

### Percentage Laid Off

```sql
UPDATE layoffs_stagging
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';
```

### Industry

```sql
UPDATE layoffs_stagging
SET industry = NULL
WHERE industry = '';
```

### Source

```sql
UPDATE layoffs_stagging
SET `source` = NULL
WHERE `source` = '';
```

### Stage

```sql
UPDATE layoffs_stagging
SET stage = NULL
WHERE stage = '';
```

### Funds Raised

```sql
UPDATE layoffs_stagging
SET funds_raised = NULL
WHERE funds_raised = '';
```

### Country

```sql
UPDATE layoffs_stagging
SET country = NULL
WHERE country = '';
```

---

## 5. Data Type Conversion

The columns were converted to appropriate data types.

```sql
ALTER TABLE layoffs_stagging
MODIFY COLUMN company VARCHAR(255);

ALTER TABLE layoffs_stagging
MODIFY COLUMN location VARCHAR(255);

ALTER TABLE layoffs_stagging
MODIFY COLUMN total_laid_off INT;

ALTER TABLE layoffs_stagging
MODIFY COLUMN percentage_laid_off DECIMAL(10,2);

ALTER TABLE layoffs_stagging
MODIFY COLUMN industry VARCHAR(255);

ALTER TABLE layoffs_stagging
MODIFY COLUMN `source` VARCHAR(500);

ALTER TABLE layoffs_stagging
MODIFY COLUMN stage VARCHAR(500);

ALTER TABLE layoffs_stagging
MODIFY COLUMN funds_raised DECIMAL(12,2);
```

---

## 6. Date Standardization

The `date` column was converted from text into the SQL `DATE` data type.

```sql
SELECT
    `date`,
    STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_stagging;

UPDATE layoffs_stagging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_stagging
MODIFY COLUMN `date` DATE;
```

The `date_added` column was also converted.

```sql
SELECT
    date_added,
    STR_TO_DATE(date_added, '%m/%d/%Y')
FROM layoffs_stagging;

UPDATE layoffs_stagging
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

ALTER TABLE layoffs_stagging
MODIFY COLUMN date_added DATE;
```

---

## 7. Missing Information Using Self Joins

Missing `source` and `stage` values were investigated by comparing records belonging to the same company.

### Source

```sql
SELECT
    ls.company,
    ls.`source`,
    ls1.company,
    ls1.`source`
FROM layoffs_stagging ls
JOIN layoffs_stagging ls1
    ON ls.company = ls1.company
WHERE (ls.`source` IS NULL OR ls.`source` = '')
AND ls1.`source` IS NOT NULL;
```

Missing source values were populated when another record for the same company contained the information.

```sql
UPDATE layoffs_stagging ls
JOIN layoffs_stagging ls1
    ON ls.company = ls1.company
SET ls.`source` = ls1.`source`
WHERE (ls.`source` IS NULL OR ls.`source` = '')
AND ls1.`source` IS NOT NULL;
```

### Stage

```sql
UPDATE layoffs_stagging ls
JOIN layoffs_stagging ls1
    ON ls.company = ls1.company
SET ls.stage = ls1.stage
WHERE (ls.stage IS NULL OR ls.stage = '')
AND ls1.stage IS NOT NULL;
```

---

# Removing Unusable Records

Records where both `total_laid_off` and `percentage_laid_off` were NULL were removed because they could not provide useful information for layoff analysis.

```sql
SELECT COUNT(*)
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```

The records were deleted using:

```sql
DELETE
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

COMMIT;

SET AUTOCOMMIT = 1;
```

The dataset was reduced from:

**4,575 records → 3,832 records**

---

# Data Validation

## Percentage Validation

```sql
SELECT *
FROM layoffs_stagging
WHERE percentage_laid_off < 0
   OR percentage_laid_off > 1;
```

No invalid percentage values were identified.

## Missing Value Validation

```sql
SELECT *
FROM layoffs_stagging
WHERE location IS NULL
   OR industry IS NULL
   OR stage IS NULL
   OR country IS NULL;
```

Remaining NULL values were retained where the dataset did not provide sufficient information.

## Final Record Count

```sql
SELECT COUNT(*)
FROM layoffs_stagging;
```

**Final dataset: 3,832 records**

---

# Exploratory Data Analysis

After cleaning and validation, SQL was used to analyze layoffs across companies, industries, countries, locations, and time.

---

## 1. Top 10 Companies by Total Layoffs

```sql
SELECT
    company,
    SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY Total_Laid_Off DESC
LIMIT 10;
```

### Screenshot

![Top 10 Companies by Total Layoffs](Screenshots/Top_10_companies_by_total_layoffs.png)

---

## 2. Largest Single Layoff Events

```sql
SELECT
    company,
    total_laid_off,
    percentage_laid_off,
    `date`,
    industry,
    country
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;
```

### Screenshot

![Largest Single Layoff Events](Screenshots/Largest_Single_Layoff_Events.png)

---

## 3. Companies That Laid Off 100% of Their Workforce

```sql
SELECT
    company,
    total_laid_off,
    percentage_laid_off,
    funds_raised,
    `date`
FROM layoffs_stagging
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;
```

A value of `1` represents **100% of the workforce**.

---

## 4. Maximum Layoffs

```sql
SELECT
    MAX(total_laid_off) AS Max_Total_Laid_Off,
    MAX(percentage_laid_off) AS Max_Percentage_Laid_Off
FROM layoffs_stagging;
```

---

## 5. Starting and Ending Date

```sql
SELECT
    MIN(`date`) AS Starting_Date,
    MAX(`date`) AS Latest_Date
FROM layoffs_stagging;
```

---

## 6. Layoffs by Industry

```sql
SELECT
    industry,
    SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY Total_Laid_Off DESC;
```

---

## 7. Layoffs by Country

```sql
SELECT
    country,
    SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY Total_Laid_Off DESC;
```

---

## 8. Layoffs by Location

```sql
SELECT
    location,
    SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY location
ORDER BY Total_Laid_Off DESC;
```

---

# Time-Series Analysis

## 9. Monthly Layoffs

Monthly layoffs were calculated using a CTE.

`LAG()` was used to compare the previous month, `LEAD()` was used to identify the next month, and a windowed `SUM()` was used to calculate the running total.

```sql
WITH monthly_layoffs AS
(
    SELECT
        SUBSTRING(`date`, 1, 7) AS `Month`,
        SUM(total_laid_off) AS Total_Off
    FROM layoffs_stagging
    WHERE total_laid_off IS NOT NULL
    GROUP BY `Month`
    ORDER BY 1 ASC
)
SELECT
    `Month`,
    Total_Off,
    LAG(Total_Off) OVER(
        ORDER BY `Month`
    ) AS Prev_Month,
    LEAD(Total_Off) OVER(
        ORDER BY `Month`
    ) AS Next_Month,
    SUM(Total_Off) OVER(
        ORDER BY `Month`
    ) AS Running_Total
FROM monthly_layoffs;
```

### Screenshot

![Monthly Layoffs](Screenshots/Monthly_layoff.png)

---

# 10. Yearly Layoffs and Running Total

```sql
SELECT
    YEAR(`date`) AS `Year`,
    SUM(total_laid_off) AS Total_Off,
    SUM(SUM(total_laid_off)) OVER(
        ORDER BY YEAR(`date`)
    ) AS Running_Total
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY `Year`;
```

This calculates total layoffs per year and the cumulative number of layoffs.

---

# Company Analysis Over Time

## 11. Layoffs by Company and Year

```sql
SELECT
    company,
    YEAR(`date`) AS `Year`,
    SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_stagging
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)
ORDER BY Total_Laid_Off DESC;
```

This allows company-level layoffs to be analyzed across different years.

---

# Ranking Analysis

## 12. Top 5 Companies by Year

A CTE was used to calculate total layoffs for each company by year.

`DENSE_RANK()` was then used to rank companies within each year.

```sql
WITH company_year AS
(
    SELECT
        company,
        YEAR(`date`) AS Years,
        SUM(total_laid_off) AS Total_Off
    FROM layoffs_stagging
    WHERE total_laid_off IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
company_year_rank AS
(
    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY Years
               ORDER BY Total_Off DESC
           ) AS Ranking
    FROM company_year
)
SELECT *
FROM company_year_rank
WHERE Ranking <= 5;
```

The output was split into two screenshots because the query returns multiple years of results.

### 2020–2023

![Top 5 Companies 2020-2023](Screenshots/top_5_company_by_year_2020_2023.png)

### 2024–2026

![Top 5 Companies 2024-2026](Screenshots/top_5_company_by_year_2024_2026.png)

---

# Key Findings

- A small number of companies account for a significant portion of total layoffs.
- Some individual layoff events were substantially larger than others.
- Several companies recorded layoffs affecting **100% of their workforce**.
- Layoffs varied significantly across months and years.
- Layoffs varied substantially across industries.
- Layoffs were concentrated in certain countries and locations.
- Running totals provide a cumulative view of layoffs over time.
- `DENSE_RANK()` identifies the companies with the highest layoffs within each year.

---

# Skills Demonstrated

## Data Cleaning

- Missing Value Handling
- NULL Handling
- Empty String Handling
- Duplicate Detection
- Data Type Conversion
- Date Standardization
- Data Validation
- Data Standardization
- Record Filtering

## SQL

- MySQL
- Aggregate Functions
- `GROUP BY`
- `ORDER BY`
- Joins
- Self Joins
- CTEs
- Window Functions
- `ROW_NUMBER()`
- `DENSE_RANK()`
- `LAG()`
- `LEAD()`
- Running Totals
- Date Functions

## Data Analysis

- Exploratory Data Analysis
- Company Analysis
- Industry Analysis
- Country Analysis
- Location Analysis
- Time-Series Analysis
- Trend Analysis
- Ranking Analysis
- Comparative Analysis
- Cumulative Analysis

## Business & Analytical Skills

- Business Question Framing
- Problem Solving
- Pattern Identification
- Trend Identification
- Insight Generation
- Data-Driven Analysis
- Business-Focused Analysis

---

# Analytical Workflow

```text
Raw Layoffs Dataset
        ↓
Create Staging Table
        ↓
Initial Data Quality Assessment
        ↓
Duplicate Detection
        ↓
Handle Missing Values
        ↓
Standardize Data
        ↓
Convert Data Types
        ↓
Remove Unusable Records
        ↓
Data Validation
        ↓
Exploratory Data Analysis
        ↓
Time-Series Analysis
        ↓
Window Functions & Ranking
        ↓
Business Insights
```

---

# Project Outcome

This project demonstrates a complete SQL workflow from **raw data to analytical insights**.

The dataset was cleaned and standardized before being analyzed across:

- Companies
- Industries
- Countries
- Locations
- Months
- Years

Advanced SQL techniques including **CTEs, self joins, window functions, `ROW_NUMBER()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, and running totals** were used to answer business questions and identify meaningful patterns.

---

# Tools Used

- **MySQL**
- **MySQL Workbench**
- **SQL**
- **GitHub**

---

# Repository Structure

```text
SQL-Layoffs-Data-Cleaning-EDA/
│
├── README.md
│
├── SQL/
│   ├── Data_Cleaning.sql
│   └── EDA.sql
│
└── Screenshots/
    ├── Largest_Single_Layoff_Events.png
    ├── Monthly_layoff.png
    ├── top_5_company_by_year_2020_2023.png
    ├── top_5_company_by_year_2024_2026.png
    └── Top_10_companies_by_total_layoffs.png
```

---

# Contact

## Muhammad Ahsan CH

**LinkedIn**

www.linkedin.com/in/muhammad-ahsan-ch-99b806426

**GitHub**

https://github.com/ahsantaga

---

# Conclusion

This project demonstrates how SQL can be used to transform raw layoffs data into a clean, validated, and analysis-ready dataset.

The complete workflow covers:

**Data Cleaning → Data Validation → Exploratory Data Analysis → Time-Series Analysis → Advanced SQL → Business Insights**

The project demonstrates practical skills in **MySQL, data cleaning, exploratory data analysis, window functions, ranking, time-series analysis, and business-focused SQL analysis**.
