SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
--Shows Likelihood of dying if a person contract covid in specific countries: in this case Canada

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2

--Looking at Total Cases VS Population
--Shows what percentage of poulation got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS contracted_population
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
GROUP BY location, population
ORDER BY percent_population_infected desc

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--Showing continents with highest death counts

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Canada%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

With POPvsVACC (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 FROM POPvsVACC



--Temp table

DROP TABLE IF exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 FROM #PercentPopVaccinated


