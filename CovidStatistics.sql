--Select * 
--From PortofolioProject..CovidDeaths$
--order by 3,4

--Select * 
--From PortofolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths

--Shows likelihood of dying in Canada
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths$
Where location like 'Canada' 
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of the population has gotten covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortofolioProject..CovidDeaths$
Where location like 'Canada'
and continent is not null
order by 1,2

--Lets look at countries with the highest infection rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths$
--Where location like 'Canada'
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

--Countries with highest death count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc


--numbers across the world
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage --, (total_cases/population)*100 as CovidPercentage
From PortofolioProject..CovidDeaths$
--Where location like 'Canada'
Where continent is not null
Group by date
order by 1,2


--using cte
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null

)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
