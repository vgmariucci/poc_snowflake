CREATE OR REPLACE PROCEDURE LOAD_BRONZE_ORDERS_DETAILS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Insert data into BRONZE_ORDERS_DETAILS using COPY INTO command.
    COPY INTO BRONZE_ORDERS_DETAILS
    FROM (
            SELECT 
            CAST($1 AS VARIANT) AS RAW,
            metadata$filename AS FILENAME, 
            CURRENT_TIMESTAMP() AS CREATED_AT
            FROM @FORMACAO.PUBLIC.NORTH/orders_details (FILE_FORMAT => 'PARQUET_FORMAT')
        );
    RETURN 'Load Bronze Orders Details table sucessfully';
END;
$$;

