SELECT * FROM CovidPortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM CovidPortfolioProject..covid_vaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM CovidPortfolioProject..covid_deaths 
ORDER BY 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you infected

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM CovidPortfolioProject..covid_deaths 
WHERE location like '%turkey%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as covid_percentage
FROM CovidPortfolioProject..covid_deaths 
WHERE location like '%faer%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as highest_infection_count,
MAX((total_cases/population))*100 as covid_percentage
FROM CovidPortfolioProject..covid_deaths 
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY 4 desc

-- Looking at countries with highest death count per population

SELECT location,population,MAX(cast(total_deaths as int)) as highest_death_count,
MAX((total_cases/population))*100 as covid_percentage
FROM CovidPortfolioProject..covid_deaths 
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 3 desc

-- by continent

SELECT location,MAX(cast(total_deaths as int)) as highest_death_count,
MAX((total_cases/population))*100 as covid_percentage
FROM CovidPortfolioProject..covid_deaths 
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage 
FROM CovidPortfolioProject..covid_deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT death.continent, death.location, death.date, population,new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) as people_vaccinated_count FROM CovidPortfolioProject..covid_deaths death
JOIN CovidPortfolioProject..covid_vaccinations vac
ON death.location=vac.location and death.date=vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE


WITH PopVsVac (continent,location,date,population,new_vaccinations,people_vaccinated_count)
AS
(
SELECT death.continent, death.location, death.date, population,new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) as people_vaccinated_count FROM CovidPortfolioProject..covid_deaths death
JOIN CovidPortfolioProject..covid_vaccinations vac
ON death.location=vac.location and death.date=vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(people_vaccinated_count/population)*100 as vaccinated_pop_percent
FROM PopVsVac


-- Use Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations float,
 people_vaccinated_count float
 )

INSERT INTO #PercentPopulationVaccinated 
SELECT death.continent, death.location, death.date, population,new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) as people_vaccinated_count FROM CovidPortfolioProject..covid_deaths death
JOIN CovidPortfolioProject..covid_vaccinations vac
ON death.location=vac.location and death.date=vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(people_vaccinated_count/population)*100 as vaccinated_pop_percent
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW percent_population_vaccinated as
SELECT death.continent, death.location, death.date, population,new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) as people_vaccinated_count FROM CovidPortfolioProject..covid_deaths death
JOIN CovidPortfolioProject..covid_vaccinations vac
ON death.location=vac.location and death.date=vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3


SELECT * FROM percent_population_vaccinated