/* 
Queries used for Tableau Project
*/


--1: Overall Total cases VS total deaths

SELECT SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS int)) AS Total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
ORDER BY 1,2




--2: Showing continents with highest death count

SELECT location,SUM(CAST(new_deaths AS int)) AS Total_death_count
FROM Covid_Database..Covid_Deaths
WHERE continent is null
	AND location not in ('World','International','European Union')
GROUP BY location
ORDER BY Total_death_count DESC



-- 3: showing percent population infected per country

SELECT location,population,MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
GROUP BY location,population
ORDER BY Percent_population_infected DESC



--4: timelapse showing percent population infected per country

SELECT location,population,date,MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM Covid_Database..Covid_Deaths
WHERE continent is not null
GROUP BY location,population,date
ORDER BY Percent_population_infected DESC


-- export the results of these querries into excel to visualize data in tableau