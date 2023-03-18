select *
from CovidDeath
Where continent is not null 
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Select Data That we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
Where continent is not null 
order by 1,2

-- Looking for Total Cases Vs Total deaths
--SELECT CAST(total_deaths AS numeric) / 100
--FROM CovidDeath

--SELECT CAST(total_cases AS numeric) / 100
--FROM CovidDeath

select location, date, total_cases,  total_deaths
FROM CovidDeath
Where continent is not null 


-- Looking for Total Cases Vs Total deaths -- Did not work with me !!!!
-- show s the likelihood of dying if you contact covid in your counrty 
Select Location, date, total_cases,total_deaths, (cast(total_deaths as int)/cast(total_cases as int)) as DeathToCases
From CovidDeath
Where location like '%states%'
and  continent is not null 
order by 1,2


-- Looking for Total Cases Vs populations
-- shows what percemtage of poplulations got covid 

Select Location, date, total_cases,population , (total_cases/population)*100 As PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
Where continent is not null 
order by 1,2


--Looking  country which have the highest cases compare to population



Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc


--- this is showing country with highest Death count per Populations

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount  desc


---Let us Break down by continent 

Select  continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount  desc


--Showing the continent with Highest death count per populations 

Select  continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount  desc



-- Global numbers 

select  Sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
from covidDeath
where continent is not null
--group by date
order by  1,2

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
--SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From CovidDeath
----Where location like '%states%'
--where continent is not null 
----Group By date
--order by 1,2


--Checking the other table CovidVac and the make a join on location and date
---total population Vs Vaccinations


select *
from CovidDeath as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date

---total population Vs Vaccinations

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeath as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- Using Partion by and windows functions to display the and know the roling count 

 select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(convert( bigint,vac.new_vaccinations )) over (partition by dea.location order by dea.location ,
 dea.date) as RollingPeopleVaccinated

from CovidDeath as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

  -- Use CTE 

  With PopVsVac (continent ,location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
  select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(convert( bigint,vac.new_vaccinations )) over (partition by dea.location order by dea.location ,
 dea.date) as RollingPeopleVaccinated

from CovidDeath as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfRolling
From PopvsVac



--Temp Table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later Visual work we might need it
 create view PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated

