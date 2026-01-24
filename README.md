
# Automated Snowflake View Deployment With AWS S3 External Catalog and GitHub Actions for CI/CD 

## Project Overview

1. Account creation in Snowflake platform (30-day trial);
2. Account creation in AWS for data storage using S3;
3. Database creation with independent schemas for:
    - Public stage connection with AWS S3 using IAM for access management (PUBLIC)
    - Development (DEV) 
    - Testing (QA)
    - Production (PRD);  
4. Data organization applying Medallion Architecture (Bronze, Silver, and Gold tables) for each raw data available from the business in Parquet file format.
5. Creation of data ingestion procedures and tasks using only SQL scripts;
6. Creation and configuration of a .yaml file for CI/CD with GitHub Actions.  
