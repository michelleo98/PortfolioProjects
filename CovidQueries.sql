SELECT * 
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Select data we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM coviddeaths
ORDER BY 1,2;

-- Looking at total cases versus total deaths // Shows the likelihood of dying if you contract covid in USA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%States%' 
ORDER BY 1,2;

--Looking at total cases vs population // shows percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentofpopulationinfected
FROM coviddeaths
WHERE location LIKE '%States%' 
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 AS percentofpopulationinfected
FROM coviddeaths
GROUP BY location, population
ORDER BY 4 DESC;

--Showing countries with highest death count per population 

SELECT location, MAX(total_deaths) AS totaldeathcount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount desc;

-- Showing continents with highest death count 

SELECT continent, MAX(total_deaths) AS totaldeathcount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount desc;

--Global Numbers 

--Global total cases and deaths by date 

SELECT date, SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Global death percentage by date 

SELECT date, SUM(new_cases) as totalcases, SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Total Global death percentage

SELECT SUM(new_cases) as totalcases, SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at total population vs vaccination // Using join and CTE

WITH popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
AS 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS  rollingpeoplevaccinated

FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *,(rollingpeoplevaccinated/population) *100
FROM popvsvac

--Using temp table

DROP TABLE IF EXISTS percentpopulationvaccinated;

CREATE TEMP TABLE percentpopulationvaccinated 
(
continent text, 
location text,
date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
);

INSERT INTO percentpopulationvaccinated 

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS  rollingpeoplevaccinated

FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT *,(rollingpeoplevaccinated/population) *100
FROM percentpopulationvaccinated 

-- Creating view to store data for later visualizations 

CREATE VIEW percentpopulationvaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS  rollingpeoplevaccinated

FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



 

