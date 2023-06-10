
SELECT * FROM portfolio_covid..CovidDeaths$
Where continent is not null
order by 3,4

--SELECT * FROM portfolio_covid..CovidVaccinations$
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_covid..CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying due to covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_covid..CovidDeaths$
where location like '%nepal%'
order by 1,2

-- Looking at total cases vs population @nepal

SELECT location, date, total_cases, population, (total_cases/population)*100 as casePercentage
FROM portfolio_covid..CovidDeaths$
where location like '%nepal%'
order by 1,2

-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
FROM portfolio_covid..CovidDeaths$
--where location like '%nepal%'
Group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio_covid..CovidDeaths$
--where location like '%nepal%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--lets break down the data by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio_covid..CovidDeaths$
--where location like '%nepal%'
Where continent is null
Group by location
order by TotalDeathCount desc


-- GLOBAL Numbers 
SELECT  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
--where location like '%nepal%'
FROM portfolio_covid..CovidDeaths$
where continent is not null
Group by date
order by 1,2

--looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinatedCount
FROM portfolio_covid..CovidDeaths$ dea
Join portfolio_covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte

with PopsvsVac (Continent, location, Date, Population, new_vaccinations, PeopleVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinatedCount
FROM portfolio_covid..CovidDeaths$ dea
Join portfolio_covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (PeopleVaccinatedCount/Population)*100 as PercentageVaccinated
FROM PopsvsVac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedCount numeric
)
INSERT into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinatedCount
FROM portfolio_covid..CovidDeaths$ dea
Join portfolio_covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (PeopleVaccinatedCount/Population)*100 as PercentageVaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinatedview as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinatedCount
FROM portfolio_covid..CovidDeaths$ dea
Join portfolio_covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
