select *
from CovidDeaths
order by 3,4;

select *
from CovidVaccinations
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by Location, date;

-- Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Percentage of deaths over total cases'
from CovidDeaths
order by Location, date;

-- Likelihood of dying if you got infected in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Percentage of deaths over total cases'
from CovidDeaths
where Location = 'United States'
order by Location, date;

-- Likelihood of dying if you got infected in Vietnam 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Percentage of deaths over total cases'
from CovidDeaths
where location like '%Nam'
order by location, date;

-- Countries with highest infection rate per population 
select location, population, max(total_cases) as 'HighestInfectionCount', max((total_cases/population))*100 as 'PercentagePopulationInfected'
from CovidDeaths
group by location, population
order by PercentagePopulationInfected desc;

-- Countries with highest death count
select location, max(cast(total_deaths as unsigned)) as 'HighestDeathCount'
from CovidDeaths
where continent != ""
group by location
order by HighestDeathCount desc;

-- Continent with highest death count
select location, max(cast(total_deaths as unsigned)) as 'HighestDeathCount'
from CovidDeaths
where continent = "" and location != "World" and location != "International"
group by location
order by HighestDeathCount desc;

-- Global numbers
select sum(new_cases) as 'total_deaths', sum(new_deaths) as 'total_deaths', (sum(new_deaths)/sum(new_cases))*100 as 'DeathPercentage'
from CovidDeaths
where continent != ""
order by sum(new_cases), sum(new_deaths);

-- Total population vs Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as 'RollingPeopleVaccinated',
from CovidDeaths d join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent != ""
order by d.location, d.date;

-- Use CTE
with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as 'RollingPeopleVaccinated'
from CovidDeaths d join CovidVaccinations v
on (d.location = v.location and d.date = v.date)
where d.continent != ""
order by d.location, d.date
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac;

-- Use Temp table

drop table if exists PopVsVacTemp;

create temporary table PopVsVacTemp
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as 'RollingPeopleVaccinated'
from CovidDeaths d join CovidVaccinations v
on (d.location = v.location and d.date = v.date)
where d.continent != ""
order by d.location, d.date;

select *, (RollingPeopleVaccinated/Population)*100
from PopVsVacTemp;


-- create View to store data for visualizations
create view PopVsVacView as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as 'RollingPeopleVaccinated'
from CovidDeaths d join CovidVaccinations v
on (d.location = v.location and d.date = v.date)
where d.continent != ""
order by d.location, d.date;

select *
from PopVsVacView;