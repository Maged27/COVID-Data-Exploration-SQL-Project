SELECT *
FROM CovidSQLProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidSQLProject..CovidVaccinations
--ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidSQLProject..CovidDeaths
ORDER BY 1,2


SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
FROM CovidSQLProject..CovidDeaths
WHERE location like 'Egypt'
ORDER BY 1,2


SELECT location, Population, MAX(total_cases) as HighestInfectaionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM CovidSQLProject..CovidDeaths
--WHERE location like 'Egypt'
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc


SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidSQLProject..CovidDeaths
--WHERE location like 'Egypt'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc



SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidSQLProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVac)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVac
FROM CovidSQLProject..CovidDeaths dea
JOIN CovidSQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVac/Population)*100
FROM PopvsVac





DROP table if exists #percentPopulationVacc
Create table #percentPopulationVacc
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVac numeric
)

Insert into #percentPopulationVacc
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVac
FROM CovidSQLProject..CovidDeaths dea
JOIN CovidSQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVac/Population)*100
FROM #percentPopulationVacc


Create View percentPopulationVaccin as
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVac
FROM CovidSQLProject..CovidDeaths dea
JOIN CovidSQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 