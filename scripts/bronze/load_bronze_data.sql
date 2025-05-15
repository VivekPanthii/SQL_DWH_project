/*
## Enabling `local_infile` in MySQL (Temporary)

To allow loading local CSV files using `LOAD DATA LOCAL INFILE`, you may need to enable the `local_infile` setting temporarily on your MySQL server.

Run this SQL command after connecting to your MySQL server:

```sql
SET GLOBAL local_infile = 1;
 */
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

-- ============================================
--            Loading Bronze Layer
-- ============================================

-- Truncate all bronze tables and reload CSV data

-- CRM Tables
SELECT '>> Truncating Table: bronze.crm_cust_info';
TRUNCATE TABLE bronze.crm_cust_info;

SELECT '>> Inserting Data Into: bronze.crm_cust_info';
LOAD DATA LOCAL INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

SELECT '>> Truncating Table: bronze.crm_prd_info';
TRUNCATE TABLE bronze.crm_prd_info;

SELECT '>> Inserting Data Into: bronze.crm_prd_info';
LOAD DATA LOCAL INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

SELECT '>> Truncating Table: bronze.crm_sales_info';
TRUNCATE TABLE bronze.crm_sales_info;

SELECT '>> Inserting Data Into: bronze.crm_sales_info';
LOAD DATA LOCAL INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_info
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

-- ============================================
--            Loading Bronze Layer
-- ============================================

-- ERP Tables
SELECT '>> Truncating Table: bronze.erp_cust_az12';
TRUNCATE TABLE bronze.erp_cust_az12;

SELECT '>> Inserting Data Into: bronze.erp_cust_az12';
LOAD DATA LOCAL INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/source_erp/cust_az12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

SELECT '>> Truncating Table: bronze.erp_loc_a101';
TRUNCATE TABLE bronze.erp_loc_a101;

SELECT '>> Inserting Data Into: bronze.erp_loc_a101';
LOAD DATA LOCAL INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/source_erp/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2';
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
LOAD DATA LOCAL INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;
