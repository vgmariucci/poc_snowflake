CREATE OR REPLACE PROCEDURE LOAD_BRONZE_CUSTOMERS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Insert data into BRONZE_CUSTOMERS using COPY INTO command.
    COPY INTO BRONZE_CUSTOMERS
    FROM (
            SELECT 
            CAST($1 AS VARIANT) AS RAW,
            metadata$filename AS FILENAME, 
            CURRENT_TIMESTAMP() AS CREATED_AT
            FROM @FORMACAO.PUBLIC.NORTH/customers (FILE_FORMAT => 'PARQUET_FORMAT')
        );
    RETURN 'Load Bronze Customers table sucessfully';
END;
$$;
