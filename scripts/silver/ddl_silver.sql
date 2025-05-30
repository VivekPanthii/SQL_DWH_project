/*
===============================================================================
DDL Script: Silver Layer Table Definitions
===============================================================================
Description:
    This script defines the necessary tables under the 'silver' schema. 
    It will first remove any existing tables of the same name to ensure 
    a clean setup.
    Use this script when reinitializing the structure of the 'silver' layer 
    based on the transformed data from the 'bronze' layer.
===============================================================================
*/


DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50) CHARACTER SET utf8mb4,
    cst_firstname VARCHAR(50) CHARACTER SET utf8mb4,
    cst_lastname VARCHAR(50) CHARACTER SET utf8mb4,
    cst_marital_status VARCHAR(50) CHARACTER SET utf8mb4,
    cst_gndr VARCHAR(50) CHARACTER SET utf8mb4,
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
    prd_id INT,
    cat_id VARCHAR(50) CHARACTER SET utf8mb4,
    prd_key VARCHAR(50) CHARACTER SET utf8mb4,
    prd_nm VARCHAR(50) CHARACTER SET utf8mb4,
    prd_cost INT,
    prd_line VARCHAR(50) CHARACTER SET utf8mb4,
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP

);

DROP TABLE IF EXISTS silver.crm_sales_info;
CREATE TABLE silver.crm_sales_info(
    sls_ord_num VARCHAR(50) CHARACTER SET utf8mb4,
    sls_prd_key VARCHAR(50) CHARACTER SET utf8mb4,
    sls_cust_id INT,
    sls_order_dt DATE NULL,
    sls_ship_dt DATE NULL,
    sls_due_dt DATE NULL,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP

);

DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101(
    cid VARCHAR(50) CHARACTER SET utf8mb4,
    cntry VARCHAR(50) CHARACTER SET utf8mb4,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP

);

DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12(
    cid VARCHAR(50) CHARACTER SET utf8mb4,
    bdate DATE,
    gen VARCHAR(50) CHARACTER SET utf8mb4,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP

);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2(
    id VARCHAR(50) CHARACTER SET utf8mb4,
    cat VARCHAR(50) CHARACTER SET utf8mb4,
    subcat VARCHAR(50) CHARACTER SET utf8mb4,
    maintenance VARCHAR(50) CHARACTER SET utf8mb4,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP

);

