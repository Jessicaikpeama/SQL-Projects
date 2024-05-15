-- Exploreratory Data Analysis

select *
from layoffs_staging2;

-- Checked the max  total people laid off

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;



select min(`date`), max(`date`)
from layoffs_staging2;

-- checking the sum of total laid off by industry, country, date

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select *
from layoffs_staging2;

select country, sum(total_laid_off)
from layoffs_staging2
group by  country
order by 2 desc;

select year (`date`), sum(total_laid_off)
from layoffs_staging2
group by  year (`date`)
order by 2 desc;

-- rolling total of Layoffs by month

select substring(`DATE`, 1,7) AS `MONTH`, sum(total_laid_off)
from layoffs_staging2
WHERE substring(`DATE`, 1,7) IS NOT NULL
group by  `MONTH`
order by 1;


WITH Rolling_total as
(
select substring(`DATE`, 1,7) AS `MONTH`, sum(total_laid_off) as total_off
from layoffs_staging2
WHERE substring(`DATE`, 1,7) IS NOT NULL
group by  `MONTH`
order by 1
)
select country,`MONTH`, total_off,
 sum( total_off) over(order by `month`) as rolling_total
from Rolling_total;


-- the Rolling total laid off in company

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by  company, `date`
order by 3 desc;

WITH Company_years  ( company, years, total_laid_off) as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by  company, year(`date`)
), company_year_rank as
(select *, 
dense_rank() OVER ( partition by years order by total_laid_off desc) as ranking
from Company_years
where years is not null
)
select *
from company_year_rank
where ranking <=5;



























