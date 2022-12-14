--Analysis on covid 19 death and vaccination datsets
--Performing select,where,group,aggreagte
--CTE , VIEW, TEMP tables

USe Portfolio --using desired datasbase

select * from CovidDeaths 
select * from CovidVaccinations --looking into dasets just to observe how our data looks

--how big our datasets is 

select count(*) from CovidDeaths --170342 observations
select count(*) from CovidVaccinations--85171 observations

--lets check datatype in our datasets 
exec sp_help CovidDEaths
exec sp_help CovidVaccinations --sp_help is a stored procedure in  SSMS just to check metadata of our dataset

--ok let's work with desired columns 

select location,date,total_cases,new_cases,total_deaths,population
 from CovidDeaths
 order by 1,2 --order of display results according to 1 and second column in ascending manner

 ----------------------------------------------------------------------------------------------------------------------
 --OKK LET'S WORK ON SOME STATISTICS

--Q1. what are the chances of death in your country.
--looking for total cases vs total deaths
--shows lilkelyhood of death percentage if you contract with covid in your country

select location,date,total_cases,total_deaths,
	(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location = 'India' --filtering result according to requirement
order by 1,2 desc

--so if you live in India you have chance of 1.1% approx chance of death with covid
--------------------------------------------------------------------------------------------------------------------------
--Q2. what is the percentage of population affected by covid in India

--looking for Total cases vs Population

select location,date,population,total_cases,
	(total_cases/population)*100 as PercentPopulationAffected
from CovidDeaths
where location = 'India' --filtering result according to requirement 
order by 1,2 desc

--at the end of april of 2021 1.38% approx population got affected in india
-------------------------------------------------------------------------------------------------------------------------------
--Q3. which country is had the highest infection rate.
--looking for infection rate by country comparing to population


select location,population,max(total_cases) as HighestInfectionRate,
	max((total_cases/population)*100) as MaxPercentPopulationAffected
from CovidDeaths
where continent is not null --filtering result according to requirement 
group by location,population --grouping is needed when we use any aggregate function like max here.
order by MaxPercentPopulationAffected desc

--Andorra is leading at top with 17.12% population is infected with covid.
----------------------------------------------------------------------------------------------------------------------------------

--Q4 which country have the highest Death count
--location vs total_death


select 
	location,
	max(cast(total_deaths as int)) as HighestDeathCount
	--convert total_deaths into intiger data type
	--cause it is presents as nvarchar data type in orignal dataset
	--which is not suitable for counting orders.
from CovidDeaths

where continent is not null--continents is presents in both continent
							--and location column

group by location --grouping is needed when we use any aggregate function like max here.
order by HighestDeathCount desc
--yey as i guessing United states leading the death count by 5,76,232 

-----------------------------------------------------------------------------------------------------
--LET'S BREAK THINGS BY CONTINENT

--Q5.which continent having highest death count

select 
	location,
	max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths

where continent is  null
group by location 
order by HighestDeathCount desc

--Europe leading with 10,16,750 death count
---------------------------------------------------------------------------------------------------------
--Global Numbers
--Q6. How covid cases progress gone through the world according to date


select 
	--date,
	sum(new_cases) as total_cases,
	sum(CONVERT(int,new_deaths)) as total_deaths,
	sum(CONVERT(int,new_deaths))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date 
order by 1,2

--Total Cases 30,11,49,954
--Total Deaths 63,60,412
--Total Percentage of death 2.12%

-----------------------------------------------------------------------------------------------------------------
--let's level up querries and now working with
--both CovidDeaths and CovidVaccinations

--looking at total Population vs total vaccinations

--Q7. Total vacccinations by country
select 
	cd.continent,--neede alias name before column
	cd.location, --just to help database easily 
	cd.date,    -- recongnize from which table column is coming
	cd.population,
	cv.new_vaccinations
	,sum(convert(int,cv.new_vaccinations))
	over (partition by cd.location order by cd.location,cd.date)
	as RollingPopVac

from Portfolio..CovidDeaths cd
	join Portfolio..CovidVaccinations cv -- performing inner join
	on cd.date = cv.date and cd.location = cv.location
	
where cd.continent is not null
order by 2,3
------------------------------------------------------------------------------
--Q8. Percent population get vaccinated

--CTE {common Table expression}

with PopVsVac  (continent,
	location,date,population,
	new_vaccinations,RollingPopVac)
as
(
select 
	cd.continent,--neede alias name before column
	cd.location, --just to help database easily 
	cd.date,    -- recongnize from which table column is coming
	cd.population,
	cv.new_vaccinations
	,sum(convert(int,cv.new_vaccinations))
	over (partition by cd.location order by cd.location,cd.date)
	as RollingPopVac

from Portfolio..CovidDeaths cd
	join Portfolio..CovidVaccinations cv -- performing inner join
	on cd.date = cv.date and cd.location = cv.location
	
where cd.continent is not null
--order by 2,3
)
select *,(RollingPopVac/population)*100 as popVaccinated
from PopVsVac


------------------------------------------------------------------------------------

--TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percentpopvacc
create table #percentpopvacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpopvacc numeric
)
insert into #percentpopvacc
select 
	cd.continent,--neede alias name before column
	cd.location, --just to help database easily 
	cd.date,    -- recongnize from which table column is coming
	cd.population,
	cv.new_vaccinations
	,sum(convert(int,cv.new_vaccinations))
	over (partition by cd.location order by cd.location,cd.date)
	as RollingPopVac

from Portfolio..CovidDeaths cd
	join Portfolio..CovidVaccinations cv -- performing inner join
	on cd.location = cv.location and cd.date = cv.date
	
--where cd.continent is not null
--order by 2,3

select *,(Rollingpopvacc/Population)*100 as popVaccinated
from #percentpopvacc

-------------------------------------------------------------------------------------------------
VIEWS
GO
CREATE VIEW  WorldUnderCovid as 
select	
	location,
	max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths

where continent is null and location != 'World'
group by location 
--order by HighestDeathCount desc / order by clause is not supported by Views
GO

select * from WorldUnderCovid

---------------------------------------------------------------------------------------------------------























