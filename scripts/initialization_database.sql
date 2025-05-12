/*
=============================================================
            Database Initialization Script
=============================================================

Description:
    This script initializes the 'DataWarehouse' database. If the database 
    already exists, it will be dropped and recreated. The script also 
    sets up three logical groupings for organizing data: 'bronze', 'silver', 
    and 'gold' schemas within the database.

Note:
    Executing this script will permanently delete the existing 'DataWarehouse' 
    database along with all its data. Ensure that proper backups are taken 
    before running this script.
*/

-- drop the existing 'DateWarehouse' database completely
DROP DATABASE IF EXISTS DataWarehouse;


-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

use DataWarehouse;
CREATE TABLE bronze (
    id INT PRIMARY KEY,
    data VARCHAR(100)
);

CREATE TABLE silver (
    id INT PRIMARY KEY,
    data VARCHAR(100)
);

CREATE TABLE gold (
    id INT PRIMARY KEY,
    data VARCHAR(100)
);
