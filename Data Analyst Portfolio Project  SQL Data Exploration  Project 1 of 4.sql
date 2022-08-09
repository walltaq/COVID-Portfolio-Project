


/*-------------------------------------------Data Analyst Portfolio Project  SQL Data Exploration  Project 1 of 4-------------------------------------------*/

--Ctrl+K+C: for commenting seclected portion
--Ctrl+K+U: for uncommenting selected portion

--COVID Database

CREATE DATABASE PortfolioProject;

USE PortfolioProject;

SELECT *
FROM dbo.CovidDeaths

SELECT *
FROM dbo.CovidVaccinations

--Another way of querying

SELECT *
FROM PortfolioProject..CovidDeaths	--takes longer to resolve

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 4 DESC						--Another way of sorting (meaning that we can also use column numbers to ask for sorting or ordering)

--so

--CovidDeaths
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--CovidVaccinations
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select the data that we are going to use
SELECT Location, Date, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs the total deaths
SELECT Location, Date, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 DESC

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Afghanistan'
ORDER BY 1,2 DESC

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United States'
ORDER BY 1,2 DESC

--OR

--Shows likelihood of death from contraction of COVID'19 Virus if you contract
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Sweden'
ORDER BY 1,2 DESC

--Shows what percentage of the population contracted the COVID virus
SELECT Location, Date, population, total_cases, (total_cases/population) AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Sweden%'
ORDER BY 1,2 DESC

--Looking at the countries with the highest infection rate compared to population
SELECT TOP 10 Location, Population, MAX (total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PopulationInfectedPercentage DESC

--For Sweden
SELECT TOP 10 Location, Population, MAX (total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Sweden'
GROUP BY Location, population
ORDER BY PopulationInfectedPercentage DESC

--Showing countries with the highest death count per population
SELECT Location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount --, MAX((Total_Deaths/Population)) *100 AS DeathsPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL		--removing 'World' and all continents
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Looking at the data at a continental level
SELECT Continent, MAX (CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

SELECT Location, MAX (CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death count per population
SELECT Continent, MAX (CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT Date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(New_Deaths AS INT))/SUM(New_Cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1, 2


SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(New_Deaths AS INT))/SUM(New_Cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2


SELECT *
FROM dbo.CovidVaccinations

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
ORDER BY 2,3

--Using CTE
/*
https://www.sqlshack.com/sql-server-common-table-expressions-cte/#:~:text=A%20Common%20Table%20Expression%2C%20also,be%20used%20in%20a%20View.)

A Common Table Expression, also called as CTE in short form, is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. The CTE can also be used in a View.

*/


--Looking at total population vs vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population) *100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
	WHERE dea.Continent IS NOT NULL
	--ORDER BY 2,3
	)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac

--the no of columns in the CTE should be the same as in the underlying query


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date Datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population) *100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
	WHERE dea.Continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations using				'CREATE VIEW AS' and thwn followed by the query as usual for the first time only

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population) *100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
	WHERE dea.Continent IS NOT NULL
	--ORDER BY 2,3


--So now we can go directly to a custom created View, extracted from a query

SELECT *
FROM PercentPopulationVaccinated

 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------