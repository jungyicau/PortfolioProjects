ALTER DATABASE PortfolioProject MODIFY NAME = PortfolioProject;
-- SELECT REPLACE ('PortfolioProject','PortfolioProject','PortfolioProject') AS ModifiedString;

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL -- important!
ORDER BY 3,4; /*shows third then fourth column*/

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Canada from 2020-2021
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of people got Covid
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS CasePercentagePopulation
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases/population))*100 AS InfectionPercentagePopulation
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population -- Need GROUP BY because we used the MAX() function
ORDER BY InfectionPercentagePopulation DESC;

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location 
ORDER BY TotalDeaths DESC;

-- Showing Continents with Highest Death Count per Population
SELECT Continent, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeaths DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

/*
WITH AggregatedVaccinations AS (
    SELECT location, date, SUM(CONVERT(int, vac.new_vaccinations)) AS new_vaccinations
    FROM PortfolioProject..CovidVaccinations vac
    GROUP BY location, date
)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN AggregatedVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- troubleshoot for duplicates
SELECT location, date, COUNT(*)
FROM PortfolioProject..CovidDeaths
GROUP BY location, date
HAVING COUNT(*) > 1;

SELECT location, date, COUNT(*) AS Duplicates-- found duplicates
FROM PortfolioProject..CovidVaccinations
GROUP BY location, date
HAVING COUNT(*) > 1;
*/

/* Need to review why he did this*/
-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualizations
CREATE VIEW PercentPopulationVaccinated 
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

SELECT *
FROM PercentPopulationVaccinated
