select *
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is not null
order by 3,4

--select *
--from PORTFOLIO_PROJECT..COVID_VACINATIONS
--order by 3,4

--Select Data that we are going to be working on

select location, date, total_cases, new_cases, total_deaths, population
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is not null
order by 1,2

--Looking at Total_Cases Vs Total_Deaths
--This shows the likelihood of dying if you contract Covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is not null
order by 1,2

--To check for Canada and Nigeria death_percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
where location like '%Canada%'
and continent is not null
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
where location like '%Nigeria%'
and continent is not null
order by 1,2

--Looking at the Total_Cases Vs Population
--Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as covid_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
where location like '%canada%'
and continent is not null
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as covid_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
--where location like '%Nigeria%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to the population

--3.

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 
as percent_population_infected
from PORTFOLIO_PROJECT..COVID_DEATHS
--where continent is not null
--where location like '%Nigeria%'
group by location, population
order by percent_population_infected desc

--4.

select location, population, date, max(total_cases) as highest_infection_count, max((total_cases/population))*100 
as percent_population_infected
from PORTFOLIO_PROJECT..COVID_DEATHS
--where location like '%Nigeria%'
group by location, population, date
order by percent_population_infected desc


--Showing countries with highest death count per population

select location, population, max(total_deaths) as total_death_count
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is not null
--where location like '%Nigeria%'
group by location, population
order by total_death_count desc

--Changing the data type of total_deaths from nvarchar to int data type to get a more accurate number

select location, population, max(cast(total_deaths as int)) as total_death_count
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is not null
--where location like '%Nigeria%'
group by location, population
order by total_death_count desc

--Let's break it down by continent

--Showing the continent with the highest death count


select continent, max(cast(total_deaths as int)) as total_death_count
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is not null
--where location like '%Nigeria%'
group by continent
order by total_death_count desc

--NOTE: that north america did not include total death count of Canada

--Let's break it down by location

--2. 

select location, max(cast(total_deaths as int)) as total_death_count
from PORTFOLIO_PROJECT..COVID_DEATHS
where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
--where location like '%Nigeria%'
group by location
order by total_death_count desc

--Global number's

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 
as death_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
--where location like '%Nigeria%'
where continent is not null
group by date 
order by 1,2

--Total_cases Vs Total_deaths Vs Total_death_percentage

--1.

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 
as death_percentage
from PORTFOLIO_PROJECT..COVID_DEATHS
--where location like '%Nigeria%'
where continent is not null
--group by date 
order by 1,2

--Checking COVID_VACINATIONS table

select *
from PORTFOLIO_PROJECT..COVID_VACINATIONS

--Joining the 2 tables together

select *
from PORTFOLIO_PROJECT..COVID_DEATHS cd
join PORTFOLIO_PROJECT..COVID_VACINATIONS cv
	on cd.location = cv.location
	and cd.date = cv.date

--looking at total population Vs vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from PORTFOLIO_PROJECT..COVID_DEATHS cd
join PORTFOLIO_PROJECT..COVID_VACINATIONS cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--Total numbers of vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated)* 100
from PORTFOLIO_PROJECT..COVID_DEATHS cd
join PORTFOLIO_PROJECT..COVID_VACINATIONS cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3


--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated)* 100
from PORTFOLIO_PROJECT..COVID_DEATHS cd
join PORTFOLIO_PROJECT..COVID_VACINATIONS cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select * , (rolling_people_vaccinated/population)*100
from popvsvac


--Temp Table

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percent_population_vaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated)* 100
from PORTFOLIO_PROJECT..COVID_DEATHS cd
join PORTFOLIO_PROJECT..COVID_VACINATIONS cv
	on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null
order by 2,3

select * , (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

create view percent_population_vaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated)* 100
from PORTFOLIO_PROJECT..COVID_DEATHS cd
join PORTFOLIO_PROJECT..COVID_VACINATIONS cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select * 
from percent_population_vaccinated


