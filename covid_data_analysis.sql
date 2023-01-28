SELECT *
from portfolio_project..covidDeaths$
order by 3,4

select *
from portfolio_project..covidVaccination$
order by 3,4

--select data that we are going to use

select location, date, total_cases,new_cases,total_deaths,population
from portfolio_project..covidDeaths$
order by 1,2

--looking at total cases vs total deaths
-- showes the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio_project..covidDeaths$
where location like '%India%'
order by 1,2

--looking at total cases vs population
--showes what percentage of population got covid
select location, date,population, total_cases, (total_cases/population)*100 as DeathPercentage
from portfolio_project..covidDeaths$
--where location like '%India%'
order by 1,2


--looking at countris have highest infection rate compared to poppulation

select location, population, max(total_cases) as HighestInfectinCount, max(total_cases/population)*100 as Percentagepopulationinfaction
from portfolio_project..covidDeaths$
--where location like '%India%'
group by location,population
order by Percentagepopulationinfaction desc

--showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolio_project..covidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

--lets take continent


--showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolio_project..covidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select date, SUM(new_cases) as Sum_of_Cases, SUM(cast(new_deaths as int)) as Sum_of_Deaths, (SUM(cast(new_deaths as int)) /SUM(new_cases))*100 as DeathPercentage
from portfolio_project..covidDeaths$
where continent is not null
Group by date
order by 1,2

-- Looking at TOTAL POPULATION vs VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location  ORDER BY dea.location, dea.date) as People_Vaccinated
from portfolio_project..covidDeaths$ dea
left outer join portfolio_project..covidVaccination$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not Null
order by 2,3


--CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, People_Vaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location  ORDER BY dea.location, dea.date) as People_Vaccinated
from portfolio_project..covidDeaths$ dea
left outer join portfolio_project..covidVaccination$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not Null
--order by 2,3
)
select *, (People_Vaccinated/Population)*100 as Percent_Vaccinated
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar (225),
Date Datetime,
Population numeric,
New_Vaccination numeric,
Population_Vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location  ORDER BY dea.location, dea.date) as People_Vaccinated
from portfolio_project..covidDeaths$ dea
left outer join portfolio_project..covidVaccination$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not Null
--order by 2,3
select *, (Population_Vaccinated/Population)*100 as Percent_Vaccinated
from #PercentPopulationVaccinated


--CREATING VIEW--

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location  ORDER BY dea.location, dea.date) as People_Vaccinated
from portfolio_project..covidDeaths$ dea
left outer join portfolio_project..covidVaccination$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not Null
--order by 2,3

