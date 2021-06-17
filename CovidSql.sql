SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..Covid_deaths
ORDER BY 1,2

-- Total cases Vs Total Deaths
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_deaths
WHERE location like '%India%'
ORDER BY 1,2

-- Total Cases VS Total Populations
SELECT location, date, total_cases,population, (total_cases/population)*100 AS Percent_Population
FROM PortfolioProject..Covid_deaths
WHERE location like '%India%'
ORDER BY 1,2

-- Highest Infection Rate
SELECT location,MAX(total_cases) AS HighestInfection, population ,MAX(total_cases/population)*100 AS Percent_Population
FROM PortfolioProject..Covid_deaths
GROUP BY location,population
ORDER BY 2 DESC

-- Highest Death Count Per Population
SELECT location,MAX(cast(total_deaths as int)) AS Total_Death,MAX(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC


-- Continent with highest death counts
SELECT continent,MAX(cast(total_deaths as int)) AS Total_Death,MAX(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- Contient with Highest Infection Rate
SELECT continent,MAX(total_cases) AS HighestInfection,MAX(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- New cases each day/ World
SELECT date, SUM(new_cases)
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
Group BY date
ORDER BY 1

-- New Cases/ New Deaths / World
SELECT date,SUM(new_cases) as Total_new_cases, SUM(cast(new_deaths as int)) as Total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Deaths table Vs Vaccine Table

SELECT *
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date

-- Total Population VS Vaccine
SELECT dea.continent,dea.location,dea.date, dea.population, Vac.new_vaccinations
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date
WHERE dea.continent is not null
ORDER BY 1,2


SELECT dea.continent,dea.location,dea.date, dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)AS Cumilative_Vaccination
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date
WHERE dea.continent is not null
ORDER BY 1,2

-- Vaccinations in India
SELECT dea.continent,dea.location,dea.date, dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Cumilative_Vaccination
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date
WHERE dea.continent is not null AND dea.location = 'India'
ORDER BY 1,2

-- CTE for India 

WITH PopvsVac (continent,location,date,population,new_vaccinations,Cumilative_Vaccination)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Cumilative_Vaccination
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date
WHERE dea.continent is not null AND dea.location = 'India'
--ORDER BY 1,2
)
SELECT *,(Cumilative_Vaccination/population)*100
FROM PopvsVac

-- TEMP table for World
DROP TABLE if exists PercentPopulationVaccinated  -- Useful when changes are done
Create Table PercentPopulationVaccinated
( continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cummilative_Vaccination numeric)

Insert into PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Cumilative_Vaccination
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date
WHERE dea.continent is not null
--ORDER BY 1,2

SELECT *, (Cummilative_Vaccination/Population)*100 as Percent_vaccine 
FROM PercentPopulationVaccinated

-- Create View to store data for visualization
CREATE VIEW Percent_Population_Vaccinated AS 
SELECT dea.continent,dea.location,dea.date, dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Cumilative_Vaccination
FROM PortfolioProject..Covid_deaths as Dea
Join PortfolioProject..Covid_Vaccine$ as Vac
	ON	Dea.location = Vac.location
	AND	Dea.date = Vac.date
WHERE dea.continent is not null
--ORDER BY 1,2

SELECT * FROM Percent_Population_Vaccinated