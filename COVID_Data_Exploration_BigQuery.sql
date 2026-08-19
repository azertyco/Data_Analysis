-- 1. Initial Data Inspection
SELECT 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
FROM `covid_project.CovidDeaths`
WHERE continent IS NOT NULL 
ORDER BY 1, 2;

-- 2. Total Cases vs Total Deaths (Likelihood of dying in your country)
SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (SAFE_CAST(total_deaths AS FLOAT64) / SAFE_CAST(total_cases AS FLOAT64)) * 100 AS DeathPercentage
FROM `covid_project.CovidDeaths`
WHERE location LIKE '%France%' 
  AND continent IS NOT NULL 
ORDER BY location, date;

-- 3. Total Cases vs Population
SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (SAFE_CAST(total_deaths AS FLOAT64) / SAFE_CAST(total_cases AS FLOAT64)) * 100 AS DeathPercentage
FROM `covid_project.CovidDeaths`
WHERE location LIKE '%France%' 
  AND continent IS NOT NULL 
ORDER BY 1,2;


-- 4. Countries with Highest Infection Rate Compared to Population
SELECT 
  location, 
  population, 
  MAX(SAFE_CAST(total_cases AS FLOAT64)) AS HighestInfectionCount, 
  MAX((SAFE_CAST(total_cases AS FLOAT64) / SAFE_CAST(population AS FLOAT64))) * 100 AS PercentPopulationInfected
FROM `covid_project.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 5. Countries with Highest Death Count per Population
SELECT 
  location, 
  MAX(SAFE_CAST(total_deaths AS INT64)) AS TotalDeathCount
FROM `covid_project.CovidDeaths`
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 6. Breaking Down Highest Death Counts by Continent
SELECT 
  continent, 
  MAX(SAFE_CAST(total_deaths AS INT64)) AS TotalDeathCount
FROM `covid_project.CovidDeaths`
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 7. Global Totals Across the Entire World
SELECT 
  SUM(SAFE_CAST(new_cases AS FLOAT64)) AS total_cases, 
  SUM(SAFE_CAST(new_deaths AS FLOAT64)) AS total_deaths, 
  (SUM(SAFE_CAST(new_deaths AS FLOAT64)) / SUM(SAFE_CAST(new_cases AS FLOAT64))) * 100 AS DeathPercentage
FROM `covid_project.CovidDeaths`
WHERE continent IS NOT NULL;



-- 8. Total Population vs Vaccinations (Rolling Cumulative Count using Window Functions)
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(SAFE_CAST(vac.new_vaccinations AS INT64)) OVER (
    PARTITION BY dea.location 
    ORDER BY dea.location, dea.date
  ) AS RollingPeopleVaccinated
FROM `covid_project.CovidDeaths` dea
JOIN `covid_project.CovidVaccination` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date;




-- 9. Using a CTE (Common Table Expression) to Calculate Vaccination Percentage
WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(SAFE_CAST(vac.new_vaccinations AS INT64)) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
  FROM `covid_project.CovidDeaths` dea
  JOIN `covid_project.CovidVaccination` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT 
  *, 
  (RollingPeopleVaccinated / SAFE_CAST(population AS FLOAT64)) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

