SELECT * 
FROM layoffs;

-- Create staging table 

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- Identify Duplicates

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Delete Duplicates

CREATE TABLE `layoffs_stage2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_stage2;

INSERT INTO layoffs_stage2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_stage2;

SELECT * 
FROM layoffs_stage2
WHERE row_num > 1;

DELETE
FROM layoffs_stage2
WHERE row_num > 1;

-- Standardizing Data

SELECT company, TRIM(company)
FROM layoffs_stage2;

UPDATE layoffs_stage2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_stage2
order by 1;

SELECT *
FROM layoffs_stage2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_stage2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct country
from layoffs_stage2
order by 1;

UPDATE layoffs_stage2
SET country = 'United States'
where country like 'United States%';

SELECT `date`, str_to_date(`date`, '%m/%d/%Y') 
from layoffs_stage2;

UPDATE layoffs_stage2
SET `date` = str_to_date(`date`, '%m/%d/%Y') ;

SELECT `date`
from layoffs_stage2;

alter table layoffs_stage2
modify column `date` DATE;

SELECT *
from layoffs_stage2;

-- Review NULL/BLANK Values

select *
from layoffs_stage2
WHERE industry is null or industry = '';

UPDATE layoffs_stage2
SET industry = null
where industry = '';

select *
from layoffs_stage2 t1
join layoffs_stage2 t2
	on t1.company = t2.company
    and t1.location = t2.location
WHERE (t1.industry is null or t1.industry = '')
and t2.industry is not null;

UPDATE layoffs_stage2 t1
join layoffs_stage2 t2
	on t1.company = t2.company
    and t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry is null
and t2.industry is not null;

select *
from layoffs_stage2
where company like 'Bally%';

-- Remove Rows/Columns

SELECT *
from layoffs_stage2
where total_laid_off is null
and percentage_laid_off is null;

DELETE 
from layoffs_stage2
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoffs_stage2;

alter table layoffs_stage2
drop column row_num;

