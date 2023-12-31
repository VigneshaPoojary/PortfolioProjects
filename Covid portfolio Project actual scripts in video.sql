SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that are we goint to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total cases vs Total deaths
--Possibilty of dying due covid infection
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total cases vs Total deaths in India
--Possibilty of dying due covid infection
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Total cases vs population
--percentage covid per total population

SELECT location, date, population, total_cases, (total_cases/population) * 100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

--Total cases vs population in India
--percentage covid per total population
SELECT location, date, population, total_cases, (total_cases/population) * 100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2


--Countries with Highest Infectionn rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc

--Shownig highest death count per poulation
SELECT location, MAX(CAST(total_deaths as int)) as Total_death
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death DESC

--On continent
SELECT location, MAX(CAST(total_deaths as int)) as Total_deaths
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_death DESC

--Global Numbers
SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths,  SUM(CAST(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date,dea.population, dea.new_vaccinations,
SUM(convert(int,dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date   = vac.date
where dea.continent is not null
order by 2,3


--CTE
WITH PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date   = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac
order by 2, 3


--create tmep table
DROP Table if  Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date   = vac.date
where dea.continent is not null
--order by 2,3

Select * ,(RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated
order by 2,3


--Creating view to store data foe visualisation

Create view PercentPopualationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, dea.new_vaccinations,
SUM(convert(int,dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date   = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopualationVaccinated