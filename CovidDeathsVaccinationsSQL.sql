--select * from PortfolioProject..CovidDeaths order by 3,4;
--select * from PortfolioProject..CovidVaccinations order by 3,4;

--select the data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2
 
 -- looking at Total Cases vs Total Deaths
 -- Shows the likelihood of dying if you contract Covid in your country 

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths 
--where location like '%sudan%'
where location = 'Sudan' and where continent is not null
order by 2

 -- looking at Total Cases vs the Population
 -- shows what percentage got Covid

 select location, date, population, total_cases, (total_cases/population)*100  as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate Compared to Population

 select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100  as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Country

 select location,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
where continent is not null
Group by location
order by TotalDeathCount desc


-- Let's Break Things Down by Continent
--showing continents with highest death count
 select location,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
where continent is null
Group by location
order by TotalDeathCount desc


--Global Numbers
select --date, 
Sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as NewDeaths,(Sum(cast(new_deaths as int)) /Sum(new_cases) ) *100  as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null and new_cases is not null
--Group by date
order by DeathPercentage desc



-- User CTE

With PopvsVac ( Continent, Location , Date, Population,NewVaccination,  RollingPeopleVaccinated)

as
(
--Looking at Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on
dea.location = vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2,3


)

select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


--Temp table 
Drop table if exists #PercentPopulationVaccinated
Create table  #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on
dea.location = vac.location and dea.date= vac.date



select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


--Creating View to Store Data for later Visualizations

Create View VPercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on
dea.location = vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select * from VPercentPopulationVaccinated