CREATE OR REPLACE PROCEDURE LOAD_BRONZE_PRODUCTS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Insert data into BRONZE_PRODUCTS using COPY INTO command.
    COPY INTO BRONZE_PRODUCTS
    FROM (
            SELECT 
            CAST($1 AS VARIANT) AS RAW,
            metadata$filename AS FILENAME, 
            CURRENT_TIMESTAMP() AS CREATED_AT
            FROM @FORMACAO.PUBLIC.NORTH/products (FILE_FORMAT => 'PARQUET_FORMAT')
        );
    RETURN 'Load Bronze Products table sucessfully';
END;
$$;CREATE OR REPLACE PROCEDURE LOAD_SILVER_CUSTOMERS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    TRUNCATE TABLE SILVER_CUSTOMERS;


    INSERT INTO SILVER_CUSTOMERS
    SELECT
        COALESCE(UPPER($1:"customer_id"::STRING),'N/A')     AS customer_id,
        COALESCE(UPPER($1:"company_name"::STRING),'N/A')    AS company_name,
        COALESCE(UPPER($1:"contact_name"::STRING),'N/A')    AS contact_name,
        COALESCE(UPPER($1:"contact_title"::STRING),'N/A')   AS contact_title,
        COALESCE(UPPER($1:"address"::STRING),'N/A')         AS address,
        COALESCE(UPPER($1:"city"::STRING),'N/A')            AS city,
        COALESCE(UPPER($1:"postal_code"::STRING),'N/A')     AS postal_code,
        COALESCE(UPPER($1:"country"::STRING),'N/A')         AS country,
        COALESCE(UPPER($1:"phone"::STRING),'N/A')           AS phone,
        COALESCE(UPPER($1:"fax"::STRING),'N/A')             AS fax,
        CURRENT_TIMESTAMP                                   AS created_at
    FROM BRONZE_CUSTOMERS;

    RETURN 'Load Silver Customers table successfully';
END;
$$;




