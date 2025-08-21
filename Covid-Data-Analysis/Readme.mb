COVID-19 Data Analysis Project (SQL + Power BI Prep)

Author: Huda Ahmedelmustafa
Tools Used: SQL Server, T-SQL, Power BI
Dataset Source: Our World in Data
 (CSV files)

Project Overview

This project showcases the use of advanced SQL techniques to perform exploratory data analysis (EDA) and prepare aggregated datasets ready for use in Power BI dashboards.

The dataset covers global COVID-19 cases, deaths, testing, and vaccination metrics. Using SQL, the data is cleaned, transformed, and structured for deeper analysis and efficient visualization.

🗂️ Folder Structure

📁 /Covid-Data-Analysis

├── covid_analysis.sql         # Main SQL script for analysis and prep

├── /data                      # Folder to place raw CSV files

│   ├── CovidDeaths.csv

│   └── CovidVaccinations.csv

└── README.md                  # Project documentation


🔧 Setup Instructions
1. Create the Database (Optional)

  Ensure you have a SQL Server instance and a database named PortfolioProject (or modify the script to fit your database name).

  CREATE DATABASE PortfolioProject;

2. Prepare the CSV Files

  Download and place the following files into a local directory (e.g., C:\Temp\):

    CovidDeaths.csv

    CovidVaccinations.csv

    Update the file paths in the SQL script if your files are located elsewhere.

3. Run the Script

   Execute the full script (covid_analysis.sql) in SQL Server Management Studio (SSMS) or Azure Data Studio.

📊 Key Features in the SQL Script
  1. Table Creation

      CovidDeaths

      CovidVaccinations

  2. Data Ingestion

        Uses BULK INSERT for fast loading of large CSVs into SQL Server.

  3. Exploratory Data Analysis

      Includes queries for:

        Global totals

        Death rates

        Cases by continent

        Vaccination progress by location

    4. CTEs and Temp Tables

        Calculate cumulative cases by country.

        Create reusable temporary summary stats tables.

    5. Views for Reusability

        vw_CovidCasesByContinent

        vw_VaccinationProgress

    6. Power BI Aggregated Tables

        Agg_DailyCovid: Daily case, death, and vaccination metrics

        Agg_SummaryByLocation: One-line summary per country

    7. Performance Optimization

        Indexed key columns to improve query performance.

📈 Power BI Integration

  The output tables (Agg_DailyCovid and Agg_SummaryByLocation) are structured to be easily imported into Power BI for building dashboards and visualizations. These tables are clean, aggregated, and normalized for performance and usability.

💡 Learning Outcomes

      Writing efficient SQL for large datasets

      Using CTEs, temp tables, and views

      Preparing BI-ready data

      Indexing for performance optimization

      Integrating SQL output with Power BI


📝 License

    This project is open-source and free to use under the MIT License.
