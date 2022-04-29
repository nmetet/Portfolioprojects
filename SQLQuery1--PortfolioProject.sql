

Select*
From[PortfolioProject].dbo.[CovidDeaths ]
Where continent is null
Order by 3,4


Select*
From [PortfolioProject].dbo.CovidVaccinations
Where continent is null
Order by 3,4


--Select data that you are going to use

 Select location,date,total_cases,new_cases,total_deaths,population
 From [PortfolioProject].dbo.[CovidDeaths ]
 Where continent is null
 Order by 1,2


 --Looking at total cases vs total deaths as a percentage
 --Shows likelihood of dying if you contract covid in your country

 Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
 From [PortfolioProject].dbo.[CovidDeaths ]
 Where location like '%state%' and continent is null
 Order by 1,2

 --Looking at total_cases vs population
 --Shows what population got covid

 Select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
 From [PortfolioProject].dbo.[CovidDeaths ]
 Where location like '%state%' and continent is null
 Order by 1,2

 --Looking for countries with the highest infection rate compared to population

 Select location,Max(total_cases) as Highestinfectioncount,population,Max(total_cases/population)*100 
 as PercentagePopulationInfected
 From [PortfolioProject].dbo.[CovidDeaths ]
 --Where location like '%state%'
 Where continent is null
 Group by population,location
 Order by PercentagePopulationInfected desc
 

 --Showing countries with the highest death count per population
 --Cast is used to change varchar to int

 Select location,Max(Cast(total_deaths as int)) as TotalDeathCount
 From [PortfolioProject].dbo.[CovidDeaths ]
 Where continent is not null
 Group by location
 Order by TotalDeathCount desc

 --Lets break things down by continent

 Select continent,Max(Cast(total_deaths as int)) as TotalDeathCount
 From [PortfolioProject].dbo.[CovidDeaths ]
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc

 --Lets break per location

 Select location,Max(Cast(total_deaths as int)) as TotalDeathCount
 From [PortfolioProject].dbo.[CovidDeaths ]
 Where continent is null
 Group by location
 Order by TotalDeathCount desc

 --Showing continents with the highest death count per population

 Select continent,Max(Cast(total_deaths as int)) as TotalDeathCount
 From[PortfolioProject].dbo.[CovidDeaths ]
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc

 --GLOBAL NUMBERS

 Select date,Sum(new_cases)as TotalCases,Sum(Cast(new_deaths as int)) as TotalDeaths,Sum(Cast(new_deaths as int))/Sum(new_cases)
 *100 as DeathPercentage
 From [PortfolioProject].dbo.[CovidDeaths ]
-- Where location like '%state%' and
Where continent is not null
Group by date
Order by 1,2

--Total cases of death percentage across the world

Select Sum(new_cases)as TotalCases,Sum(Cast(new_deaths as int)) as TotalDeaths,Sum(Cast(new_deaths as int))/Sum(new_cases)
 *100 as DeathPercentage
 From [PortfolioProject].dbo.[CovidDeaths ]
-- Where location like '%state%' and
Where continent is not null
--Group by date
Order by 1,2


--SECTION B
--FROM COVID VACCINATIONS
--Use CTE
with popvsvac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
Select dea.continent ,dea.location ,dea.date,dea.population 
,Vac.new_vaccinations ,
Sum(Convert(bigint,Vac.new_vaccinations )) OVER (Partition by dea.location 
order by dea.location,dea.date) as Rollingpeoplevaccinated
From [PortfolioProject].dbo.[CovidDeaths ] dea
Join [PortfolioProject].dbo.CovidVaccinations Vac
On dea.date= Vac.date
and dea.location=Vac.location
Where dea.continent is not null
--Order by 2,3
)

Select*,(Rollingpeoplevaccinated/population)*100 as Percentage
From popvsvac

--TEMP TABLE
Drop Table if exists #percentpeoplevaccinated
Create Table  #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #percentpopulationvaccinated
Select dea.continent ,dea.location ,dea.date,dea.population 
,Vac.new_vaccinations ,
Sum(Convert(bigint,Vac.new_vaccinations )) OVER (Partition by dea.location 
order by dea.location,dea.date) as Rollingpeoplevaccinated
From [PortfolioProject].dbo.[CovidDeaths ] dea
Join [PortfolioProject].dbo.CovidVaccinations Vac
On dea.date= Vac.date
and dea.location=Vac.location
Where dea.continent is not null

Select*,(Rollingpeoplevaccinated/population)*100 as Percentage
from #percentpopulationvaccinated


--Creating view for later vizualization

Create View percentpopulationvaccinated as
Select dea.continent ,dea.location ,dea.date,dea.population 
,Vac.new_vaccinations ,
Sum(Convert(bigint,Vac.new_vaccinations )) OVER (Partition by dea.location 
order by dea.location,dea.date) as Rollingpeoplevaccinated
From [PortfolioProject].dbo.[CovidDeaths ] dea
Join [PortfolioProject].dbo.CovidVaccinations Vac
On dea.date= Vac.date
and dea.location=Vac.location
Where dea.continent is not null

Select*
from percentpopulationvaccinated


Create view deathcases as
Select Sum(new_cases)as TotalCases,Sum(Cast(new_deaths as int)) as TotalDeaths,Sum(Cast(new_deaths as int))/Sum(new_cases)
 *100 as DeathPercentage
 From [PortfolioProject].dbo.[CovidDeaths ]
-- Where location like '%state%' and
Where continent is not null
--Group by date
--Order by 1,2



create view  deathgroupings as
Select date,Sum(new_cases)as TotalCases,Sum(Cast(new_deaths as int)) as TotalDeaths,Sum(Cast(new_deaths as int))/Sum(new_cases)
 *100 as DeathPercentage
 From [PortfolioProject].dbo.[CovidDeaths ]
-- Where location like '%state%' and
Where continent is not null
Group by date
--Order by 1,2