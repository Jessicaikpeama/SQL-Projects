

SELECT *
FROM PortfolioProject2..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject2.dbo.CovidVacination

--- Select everything we are going to be working with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM  PortfolioProject2..CovidDeaths
ORDER BY 1,2

--- let's look at Total cases VS Total Death (Lets see the % of deaths)

SELECT Location, date, total_cases, total_deaths,
CONVERT(FLOAT,total_deaths) / CONVERT(FLOAT, total_cases)*100 as DeathPercentage
FROM  PortfolioProject2..CovidDeaths
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths,
CONVERT(FLOAT,total_deaths) / CONVERT(FLOAT, total_cases)*100 as DeathPercentage
FROM  PortfolioProject2..CovidDeaths
WHERE location like '%Nigeria%'
and continent is not null
ORDER BY 1,2

--- Looking at Total Cases vs the Populattion 
--- shows the percentage of the population that got Covid

SELECT Location, date, total_cases, population,
CONVERT(FLOAT,total_cases) / CONVERT(FLOAT, population)*100 as PercentPopulationInfected
FROM  PortfolioProject2..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at Countires with the Highest Infection rate compared to Poplation

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as
PercentPopulationInfected
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY Location, population 
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death count per population

SELECT Location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is null
GROUP BY  location
ORDER BY TotalDeathCount desc

-- Showing Continents with Highest Death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY  continent
ORDER BY TotalDeathCount desc


-- GLOBAL Numbers


SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)
/NULLIF(SUM(new_cases),0 )*100 as DeathPercentage
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--lets join the covid deaths and the covid vaccination table 

SELECT *
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVacination Vac
  ON dea.location = Vac.location
  and dea.date = Vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT  dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVacination Vac
  ON dea.location = Vac.location
  and dea.date = Vac.date
WHERE dea.continent is not null
Order by 2,3

-- USING CTE TO LOOK AT THE TOTAL POPULATION VS VACCINATION 

with PopvsVac(continent, location, date,population, new_vaccinations, Rolling_peopleVaccinated)
as 
(
SELECT  dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVacination Vac
  ON dea.location = Vac.location
  and dea.date = Vac.date
WHERE dea.continent is not null
)
SELECT *, (Rolling_peopleVaccinated/population)*100
FROM PopvsVac 

-- USING TEMP TABLE  TO LOOK AT THE TOTAL POPULATION VS VACCINATION 

DROP TABLE if exists #PercentPopullationVaccinated
CREATE TABLE #PercentPopullationVaccinated
(
continent Nvarchar (225),
location nvarchar (225),
date Datetime,
population bigint,
new_vaccinations int,
Rolling_peopleVaccinated bigint
)
Insert Into #PercentPopullationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVacination Vac
  ON dea.location = Vac.location
  and dea.date = Vac.date
--WHERE dea.continent is not null

SELECT *, (Rolling_peopleVaccinated/population)*100
FROM #PercentPopullationVaccinated


-- creating a view to store data for later visualization

DROP Table if exists PopullationVaccinated

CREATE VIEW PopullationVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVacination Vac
  ON dea.location = Vac.location
  and dea.date = Vac.date
WHERE dea.continent is not null

CREATE VIEW GlobalDeathPercentage AS
SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)
/NULLIF(SUM(new_cases),0 )*100 as DeathPercentage
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2


CREATE VIEW ContinentHighestDeathCount AS
SELECT continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM  PortfolioProject2..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY  continent
--ORDER BY TotalDeathCount desc