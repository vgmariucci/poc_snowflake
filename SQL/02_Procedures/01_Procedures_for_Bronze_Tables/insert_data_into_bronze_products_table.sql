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
$$;

