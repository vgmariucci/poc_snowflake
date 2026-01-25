CREATE OR REPLACE PROCEDURE LOAD_BRONZE_ORDERS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Insert data into BRONZE_ORDERS using COPY INTO command.
    COPY INTO BRONZE_ORDERS
    FROM (
            SELECT 
            CAST($1 AS VARIANT) AS RAW,
            metadata$filename AS FILENAME, 
            CURRENT_TIMESTAMP() AS CREATED_AT
            FROM @FORMACAO.PUBLIC.NORTH/orders (FILE_FORMAT => 'PARQUET_FORMAT')
        );
    RETURN 'Load Bronze Orders table sucessfully';
END;
$$;

