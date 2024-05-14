-- Data Cleaning

Select * 
From layoffs;

-- Remove Duplicates
-- Standerdize Data
-- Null Values or Blan Values
-- Remove any columnes

Create Table Layoffs_staging
like layoffs;

select *
from Layoffs_staging;

Insert Layoffs_staging
Select * 
from layoffs;


-- Identifying and removing duplicates 

select *, 
row_number() 
Over( partition by company, location, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) as row_num
from Layoffs_staging;

with duplicate_cte as
( 
 select *, 
row_number() Over(
 partition by company, industry, location, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) as row_num
from Layoffs_staging
)

select *
from duplicate_cte
where row_num > 1; 

select *
from Layoffs_staging
where company = '100 Thieves';




CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
select *, 
row_number() 
Over( partition by company, location, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) as row_num
from Layoffs_staging;

Select *
from layoffs_staging2;

delete
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;


-- Standerdizing Data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company); 

select DISTINCT company
from layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry like 'crypto%';

update layoffs_staging2
SET industry = 'crypto'
WHERE industry like 'crypto%';

select DISTINCT country, trim(trailing '.' from country)
FROM layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united States%';

select *
FROM layoffs_staging2;

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY column `date` date;

select *
from layoffs_staging2;


-- nulls and balnks

select *
from layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off IS NULL;


update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company = 'Carvana';


select t1.company,t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
SET t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;



-- Deleating unwanted rows and columns

select *
from layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off IS NULL;

delete
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off IS NULL;

select *
from layoffs_staging2;

alter table layoffs_staging2
DROP column row_num;
