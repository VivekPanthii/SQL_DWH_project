/*
===============================================================================
Procedure Name: Populate Silver Layer from Bronze
===============================================================================
Overview:
    This procedure executes the transformation and loading logic required to 
    update the 'silver' schema tables using raw data from the 'bronze' schema.
    
Operations Included:
    - Clears existing data from Silver tables.
    - Loads cleaned and standardized data into Silver tables from Bronze sources.

Input:
    None. 
    This procedure takes no input arguments and does not return any output.

How to Run:
    CALL load_silver();
===============================================================================
*/




CALL load_silver ();

DELIMITER $$

DROP PROCEDURE IF EXISTS load_silver $$

CREATE PROCEDURE load_silver()
    BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;

    /*error HANDLER*/
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN
        SELECT '==========================================' AS msg;
        SELECT 'ERROR OCCURRED DURING LOADING SILVER LAYER' AS msg;
        SELECT '==========================================' AS msg;
     END;

     SET batch_start_time = NOW();
        SELECT '================================================' AS msg;
        SELECT 'Loading Silver Layer' AS msg;
        SELECT '================================================' AS msg;

    /*Load silver.crm_cust_info*/
    set start_time=NOW();
    SELECT '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    SELECT '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date)
SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE 
    WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single' 
    WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married' 
    
    ELSE 'n/a'
    
END AS cst_marital_status,
CASE 
    WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female' 
    WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male' 
    
    ELSE 'n/a'
    
END AS cst_gndr,
cst_create_date
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS newDateUpdate
FROM bronze.crm_cust_info
) AS t 
WHERE newDateUpdate=1;
set end_time=NOW();
SELECT CONCAT('>>Load Duration', TIMESTAMPDIFF(SECOND,start_time,end_time),'seconds') as msg;

/*load silver.crm_prd_info*/
set start_time=NOW();
SELECT '>> Truncating Table: silver.crm_prd_info';
TRUNCATE Table silver.crm_prd_info;
SELECT '>> Inserting Data Into: silver.crm_prd_info';
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        DATE_SUB(
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
            INTERVAL 1 DAY
        ) AS DATE
    ) AS prd_end_dt
FROM bronze.crm_prd_info;

SET end_time=NOW();
SELECT CONCAT('>>Load Duration', TIMESTAMPDIFF(SECOND,start_time,end_time),'Seconds') AS msg;


/*--load silver.crm_sales_details*/
SET start_time=NOW();
SELECT '>> Truncating Table: silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_info;
SELECT '>> Inserting Data Into: silver.crm_sales_details';
INSERT INTO silver.crm_sales_info(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN LENGTH(CAST(sls_order_dt AS CHAR)) = 8 AND sls_order_dt > 0 
        THEN STR_TO_DATE(CAST(sls_order_dt AS CHAR),'%Y%m%d')
        ELSE NULL
    END AS sls_order_dt,
    CASE 
        WHEN LENGTH(CAST(sls_ship_dt AS CHAR)) = 8 AND sls_ship_dt > 0 
        THEN STR_TO_DATE(CAST(sls_ship_dt AS CHAR),'%Y%m%d')
        ELSE NULL
    END AS sls_ship_dt,
    CASE 
        WHEN LENGTH(CAST(sls_due_dt AS CHAR)) = 8 AND sls_due_dt > 0 
        THEN STR_TO_DATE(CAST(sls_due_dt AS CHAR),'%Y%m%d')
        ELSE NULL
    END AS sls_due_dt,
    CASE 
        
        WHEN ((sls_sales IS NULL) OR (sls_sales <= 0) OR (sls_sales != sls_quantity * ABS(sls_sales/sls_quantity)))
        THEN (sls_quantity * ABS(sls_price))
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE 
        WHEN (sls_price IS NULL OR sls_price <= 0) AND sls_quantity!=0
        THEN sls_sales / sls_quantity
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_info;

UPDATE silver.crm_sales_info 
SET sls_sales=sls_quantity*sls_price
WHERE sls_sales!=sls_quantity*sls_price;

SET end_time=NOW();
SELECT CONCAT('>>Load Duration', TIMESTAMPDIFF(SECOND,start_time,end_time),'Seconds') AS msg;

/*-- Load silver.erp_cust_az12*/
SET start_time=NOW();
SELECT '>> Truncating Table: silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
SELECT '>> Inserting Data Into: silver.crm_sales_details';
INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)
SELECT
CASE 
    WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))  /*--Remove 'NAS' prefix if present*/
    ELSE cid 
END AS cid,
CASE 
    WHEN bdate>CURDATE()  THEN NULL
    ELSE  bdate
END AS bdate, /*--set future birthdates to NULL*/
CASE 
    WHEN UPPER(TRIM(REPLACE(REPLACE(REPLACE(gen, '\r', ''), '\n', ''), '\t', ''))) IN ('F', 'FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(REPLACE(REPLACE(REPLACE(gen, '\r', ''), '\n', ''), '\t', ''))) IN ('M', 'MALE') THEN 'Male'
    ELSE 'n/a'
END AS gen /*--normalize gender VALUES and handle unknown case*/ 
FROM bronze.erp_cust_az12;
 
/*--Removing invisible characters like \r, \n, and \t.*/
SET end_time = NOW();
SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;


/*-- Load silver.erp_loc_a101*/
SET start_time = NOW();
SELECT '>> Truncating Table: silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101;
SELECT '>> Inserting Data Into: silver.erp_loc_a101';

INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
)
SELECT
/*-- Remove hyphens from customer ID for normalization*/
REPLACE(cid,'-','') AS cid,
/*-- Standardize country names by cleaning up and mapping to full names*/
CASE 
    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', ''), '\t', '')) = 'DE' THEN 'Germany' 
    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', ''), '\t', '')) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;   

/*--Removing invisible characters like \r, \n, and \t.*/
SET end_time=NOW();
SELECT CONCAT('>>Load Duration', TIMESTAMPDIFF(SECOND,start_time,end_time),'Seconds') AS msg;


/*--load silver.erp_px_cat_g1v2*/
SET start_time = NOW();
SELECT '>> Truncating Table: silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
SELECT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)
SELECT 
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;
SET end_time = NOW();
SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

/*--End of process*/
SET batch_end_time =NOW();
SELECT '==========================================' AS msg;
SELECT 'Loading Silver Layer is Completed' AS msg;
SELECT CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time), ' seconds') AS msg;
SELECT '==========================================' AS msg;

END $$

DELIMITER;
