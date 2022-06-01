SELECT * 
FROM portfolioproject ..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM portfolioproject ..covidvaccinations
--ORDER BY 3,4

-- Select data we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolioproject ..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases versus total deaths 
-- Shows the likelihood of dying if you contract covid in USA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM portfolioproject ..coviddeaths
WHERE location LIKE '%states%' AND
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases versus population
-- Shows what percentage of population got covid 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM portfolioproject ..coviddeaths
WHERE location LIKE '%states%' AND
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM portfolioproject ..coviddeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS bigint)) AS total_death_count
FROM portfolioproject ..coviddeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY location
ORDER BY total_death_count DESC

-- Breaking things down by continent


-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS bigint)) AS total_death_count
FROM portfolioproject ..coviddeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY continent
ORDER BY total_death_count DESC

-- Global Numbers 

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS bigint)) AS total_deaths, SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS death_percentage
FROM portfolioproject ..coviddeaths 
-- WHERE location LIKE '%states%' AND
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS bigint)) AS total_deaths, SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS death_percentage
FROM portfolioproject ..coviddeaths 
-- WHERE location LIKE '%states%' AND
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at total population versus vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

WITH popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
AS (SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM popvsvac

--Temp Table
DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated


