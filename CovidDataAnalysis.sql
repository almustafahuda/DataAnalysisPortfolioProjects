/* ============================================================
   Portfolio Project - Covid Data Analysis (SQL + Power BI Prep)
   Author: Huda Ahmedelmustafa
   Purpose: Showcase advanced SQL skills, exploratory analysis,
            and preparation of BI-ready aggregated tables
   ============================================================ */

/* =============================
   1. Create Base Tables
   ============================= */
DROP TABLE IF EXISTS PortfolioProject..CovidDeaths;
DROP TABLE IF EXISTS PortfolioProject..CovidVaccinations;

-- CovidDeaths Table
CREATE TABLE PortfolioProject..CovidDeaths (
    iso_code NVARCHAR(20),
    continent NVARCHAR(50),
    location NVARCHAR(100),
    date DATE,
    total_cases BIGINT,
    new_cases BIGINT,
    new_cases_smoothed FLOAT,
    total_deaths BIGINT,
    new_deaths BIGINT,
    new_deaths_smoothed FLOAT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients BIGINT,
    icu_patients_per_million FLOAT,
    hosp_patients BIGINT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions FLOAT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions FLOAT,
    weekly_hosp_admissions_per_million FLOAT,
    new_tests BIGINT,
    total_tests BIGINT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed BIGINT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units NVARCHAR(50),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    stringency_index FLOAT,
    population BIGINT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT
);

-- CovidVaccinations Table
CREATE TABLE PortfolioProject..CovidVaccinations (
    iso_code NVARCHAR(20),
    continent NVARCHAR(50),
    location NVARCHAR(100),
    date DATE,
    new_tests BIGINT,
    total_tests BIGINT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed BIGINT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units NVARCHAR(50),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    stringency_index FLOAT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT
);

/* =============================
   2. IMPORT DATA (adjust paths to your machine)
   ============================= */

-- CovidDeaths
BULK INSERT PortfolioProject..CovidDeaths
FROM 'C:\Temp\CovidDeaths.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- CovidVaccinations
BULK INSERT PortfolioProject..CovidVaccinations
FROM 'C:\Temp\CovidVaccinations.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

/* =============================
   3. Exploratory Analysis
   ============================= */

-- Global numbers
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CAST(SUM(new_deaths) AS FLOAT) / NULLIF(SUM(new_cases),0) * 100 AS death_rate_percent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Cases & deaths by continent
SELECT continent, 
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC;

-- Vaccination progress
SELECT location, MAX(people_vaccinated_per_hundred) AS max_vaccinated_percent
FROM PortfolioProject..CovidVaccinations
GROUP BY location
ORDER BY max_vaccinated_percent DESC;

/* =============================
   4. Using CTEs
   ============================= */

-- CTE for rolling cases per country
WITH CasesCTE AS (
    SELECT location, date, 
           SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS cumulative_cases,
           population
    FROM PortfolioProject..CovidDeaths
    WHERE continent IS NOT NULL
)
SELECT location, date, cumulative_cases,
       (cumulative_cases * 1.0 / population) * 100 AS percent_population_infected
FROM CasesCTE;

/* =============================
   5. Using Temp Tables
   ============================= */

DROP TABLE IF EXISTS #CountryStats;
CREATE TABLE #CountryStats (
    location NVARCHAR(100),
    total_cases BIGINT,
    total_deaths BIGINT,
    max_vaccinated_percent FLOAT
);
GO

INSERT INTO #CountryStats
SELECT d.location,
       MAX(d.total_cases),
       MAX(d.total_deaths),
       MAX(v.people_vaccinated_per_hundred)
FROM PortfolioProject..CovidDeaths d
LEFT JOIN PortfolioProject..CovidVaccinations v
     ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.location;

SELECT * FROM #CountryStats ORDER BY total_cases DESC;
GO
/* =============================
   6. Views (Reusable Analysis)
   ============================= */

-- View 1: Cases by Continent
CREATE OR ALTER VIEW vw_CovidCasesByContinent AS
SELECT continent, date,
       SUM(new_cases) AS cases,
       SUM(new_deaths) AS deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, date;
GO
-- View 2: Vaccination Progress
CREATE OR ALTER VIEW vw_VaccinationProgress AS
SELECT location, date,
       people_vaccinated,
       people_fully_vaccinated,
       people_vaccinated_per_hundred,
       people_fully_vaccinated_per_hundred
FROM PortfolioProject..CovidVaccinations;

GO

/* =============================
   7. Aggregation Tables for Power BI
   ============================= */

-- Daily aggregated table
DROP TABLE IF EXISTS PortfolioProject..Agg_DailyCovid;
SELECT d.location, d.continent, d.date,
       d.new_cases, d.new_deaths,
       v.new_vaccinations, v.people_vaccinated, v.people_fully_vaccinated
INTO PortfolioProject..Agg_DailyCovid
FROM PortfolioProject..CovidDeaths d
LEFT JOIN PortfolioProject..CovidVaccinations v
     ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- Summary by location
DROP TABLE IF EXISTS PortfolioProject..Agg_SummaryByLocation;
SELECT d.location, d.continent,
       MAX(d.total_cases) AS total_cases,
       MAX(d.total_deaths) AS total_deaths,
       MAX(v.total_vaccinations) AS total_vaccinations,
       MAX(v.people_fully_vaccinated_per_hundred) AS vaccinated_percent
INTO PortfolioProject..Agg_SummaryByLocation
FROM PortfolioProject..CovidDeaths d
LEFT JOIN PortfolioProject..CovidVaccinations v
     ON d.location = v.location
GROUP BY d.location, d.continent;

/* =============================
   8. Indexing for Performance
   ============================= */

CREATE NONCLUSTERED INDEX idx_CovidDeaths_date
ON PortfolioProject..CovidDeaths (date);

CREATE NONCLUSTERED INDEX idx_CovidDeaths_location_date
ON PortfolioProject..CovidDeaths (location, date);

CREATE NONCLUSTERED INDEX idx_CovidVaccinations_location_date
ON PortfolioProject..CovidVaccinations (location, date);------------------------------
