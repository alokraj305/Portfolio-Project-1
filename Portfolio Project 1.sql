
--select * from master.dbo.CovidDeath order by 3, 4


--select * from master.dbo.CovidVaccination order by 3, 4

--select location, date, total_cases, new_cases, total_deaths, population 
--from master.dbo.CovidDeath order by 1,2

--looking as total cases vs total death
--shows the likelihood if you contract ciovid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'death ratio'
from master.dbo.CovidDeath
where location like '%states%' 
order by 1,2



--looking at total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as '% of population infected'
from master.dbo.CovidDeath
where location like 'India%' 
order by 2

--looking at country with highest infecton rate wrt population
select distinct location, population, max(total_cases) AS 'Highest Infection Count', max((total_cases/population)*100) as 'highest infection rate'
from master..CovidDeath
--where location like 'India%' 
group by location, population
order by 'Highest Infection Rate' desc

--Looking at the death rate in a country
select location, max(CAST(total_deaths AS INT)) as DeathCount
from master..CovidDeath WHERE CONTINENT IS NOT NULL
group by location
order by dEATHcOUNT DESC

--ANALYZING THINGS AS PER CONTINENT

select LOCATION, max(CAST(total_deaths AS INT)) as DeathCount
from master..CovidDeath WHERE CONTINENT IS NULL
group by LOCATION
order by dEATHcOUNT DESC
-- ADDED IS NULL HERE BECAUSE IN THE DATASET THE COUNTRIES ARE LISTED WITH CONTINENT NAME AND THE CONTINENTS ARE LISTED WITHOUT CONTINENT NAME
--SO THIS JUSTIFIES THEW DIFFERENCE BETWEEN IS NULL AND NOT NULL.

--GLOBAL NUMBERS

select date, SUM(NEW_CASES) AS 'TOTAL NEW CASES/DAY' , SUM(CAST(NEW_deaths AS INT)) AS 'TOTAL NEW DEATH/DAY', SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS 'DAILY NEW DEATH %'--, (total_deaths/total_cases)*100 as 'death ratio'
from master.dbo.CovidDeath
--where location like '%states%'
WHERE CONTINENT IS NOT NULL
GROUP BY DATE
order by 1

select LOCATION date, SUM(NEW_CASES) AS 'TOTAL NEW CASES/DAY' , SUM(CAST(NEW_deaths AS INT)) AS 'TOTAL NEW DEATH/DAY', SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS 'DAILY NEW DEATH %'--, (total_deaths/total_cases)*100 as 'death ratio'
from master.dbo.CovidDeath
--where location like '%states%'
WHERE CONTINENT IS NOT NULL
GROUP BY LOCATION
order by 4 DESC

--TOTAL DEATH % OVERALL
select SUM(NEW_CASES) AS 'TOTAL NEW CASES' , SUM(CAST(NEW_deaths AS INT)) AS 'TOTAL NEW DEATH', SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS 'OVERALL DEATH %'--, (total_deaths/total_cases)*100 as 'death ratio'
from master.dbo.CovidDeath
--where location like '%states%'
WHERE CONTINENT IS NOT NULL
--GROUP BY DATE
order by 1


--looking at total population vs total vaccination (USING CTE)
with popvsvac (continent, location, date, population, new_vaccinations, people_fully_vaccinated, total_vaccination_running_count, fully_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.people_fully_vaccinated, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.date, dea.location) as 'Total vaccines Administered Running count'
,sum(convert(numeric, people_fully_vaccinated)) over (partition by dea.location order by dea.date, dea.location)
FROM master..coviddeath dea
join MASTER..CovidVaccination Vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null and vac.location = 'india'
	--group by vac.location
--order by 2,3
)
select *, (total_vaccination_running_count/population)*100 as 'Vaccination%', (people_fully_vaccinated/population)*100 as 'Fully Vaccinated%' from popvsvac







--Vaccination Drive of INDIA
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations FROM master..coviddeath Dea
join MASTER..CovidVaccination Vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null and vac.location = 'india'
order by 2, 3


--Dates when India administered more than 1Cr vaccines in a single day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations FROM master..coviddeath Dea
join MASTER..CovidVaccination Vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null and new_vaccinations is not null and vac.location = 'india' and vac.new_vaccinations > 10000000
order by 2, 3



--creating view for later visualization

create view percentpeoplevaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.date, dea.location) as 'Total vaccines Administered Running count'
FROM master..coviddeath dea
join MASTER..CovidVaccination Vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	--group by vac.location
--order by 2,3
select *, (total_vaccination_running_count/population)*100 as 'Vaccination%', (people_fully_vaccinated/population)*100 as 'Fully Vaccinated%' from popvsvac

select * from percentpeoplevaccinated
where new_vaccinations is not null and  location = 'pakistan'