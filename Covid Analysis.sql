  
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Looking at imported data

SELECT *
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
ORDER BY location,date



--Selecting data that we are going to be using 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
ORDER BY location,date




--Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Database..Covid_Deaths
WHERE location = 'India'
ORDER BY location,date




--Total Cases VS Populations
-- Shows what percentage of population infected with Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 AS infected_population_Percentage
FROM Covid_Database..Covid_Deaths
WHERE location = 'India'
ORDER BY location,date




--Countries with the highest infected rate compared to the population

SELECT location,population,MAX(total_cases) AS highest_infection_count
		,MAX((total_cases/population))*100 AS infected_population_Percentage
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
GROUP BY location,population
ORDER BY infected_population_Percentage DESC



--Countries with highest death count 

SELECT location,MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_death_count DESC



--Showing continents with highest death count

SELECT location,MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM Covid_Database..Covid_Deaths
WHERE continent is null
GROUP BY location
ORDER BY Total_death_count DESC



-- Global Numbers

SELECT SUM(new_cases) AS Total_cases,SUM(CAST(new_deaths AS int)) AS Total_deaths,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
ORDER BY 1,2



--Total Population VS Vaccinated population
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by vac.location ORDER BY vac.location,vac.date) AS Rolling_people_vaccinated
FROM Covid_Database..Covid_Deaths dea JOIN 
		Covid_Database..Covid_Vaccinations vac
			ON dea.date = vac.date 
			AND dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3



--Using CTE to perform calculation on partiition on previous query

WITH Pop_vs_Vac(continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by vac.location ORDER BY vac.location,vac.date) AS Rolling_people_vaccinated
FROM Covid_Database..Covid_Deaths dea JOIN 
		Covid_Database..Covid_Vaccinations vac
			ON dea.date = vac.date 
			AND dea.location = vac.location
WHERE dea.continent is not null
)
SELECT *,(Rolling_people_vaccinated/population)*100 AS Vaccination_percent
FROM Pop_vs_Vac




--Using temp table to perform calculation

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by vac.location ORDER BY vac.location,vac.date) AS Rolling_people_vaccinated
FROM Covid_Database..Covid_Deaths dea JOIN 
		Covid_Database..Covid_Vaccinations vac
			ON dea.date = vac.date 
			AND dea.location = vac.location

SELECT *,(Rolling_people_vaccinated/population)*100 AS Vaccination_percent
FROM #PercentPopulationVaccinated




-- Creating view to store data for later visualization

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by vac.location ORDER BY vac.location,vac.date) AS Rolling_people_vaccinated
FROM Covid_Database..Covid_Deaths dea JOIN 
		Covid_Database..Covid_Vaccinations vac
			ON dea.date = vac.date 
			AND dea.location = vac.location
WHERE dea.continent is not null

-- Data is ready to visualize in tableau