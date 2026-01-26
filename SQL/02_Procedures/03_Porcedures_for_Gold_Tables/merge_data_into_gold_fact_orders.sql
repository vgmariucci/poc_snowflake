CREATE OR REPLACE PROCEDURE GOLD_FACT_ORDERS()
RETURNS STRING
LANGUAGE SQL
AS
$$

BEGIN
    MERGE INTO GOLD_FACT_ORDERS AS TARGET
    USING (
        WITH FACT AS (
            SELECT
                TO_CHAR(o.order_id) AS order_id,
                c.customer_sk,
                p.product_sk,
                dc_order.date_sk AS order_date_sk,
                dc_required.date_sk AS required_date_sk,
                dc_shipped.date_sk AS shipped_date_sk,
                od.unit_price,
                od.quantity,
                NVL(od.discount, 0) AS discount,
                od.quantity * od.unit_price AS total,
                -- HASH para detectar mudanças
                MD5(
                    NVL(TO_CHAR(o.order_id), '')            || '|' ||
                    NVL(TO_CHAR(c.customer_sk), '')         || '|' ||
                    NVL(TO_CHAR(p.product_sk), '')          || '|' ||
                    NVL(TO_CHAR(dc_order.date_sk), '')      || '|' ||
                    NVL(TO_CHAR(dc_required.date_sk), '')   || '|' ||
                    NVL(TO_CHAR(dc_shipped.date_sk), '')    || '|' ||
                    NVL(TO_CHAR(od.unit_price), '')         || '|' ||
                    NVL(TO_CHAR(od.quantity), '')           || '|' ||
                    NVL(TO_CHAR(od.discount), '')
                ) AS hash_diff
            FROM SILVER_ORDERS o
            INNER JOIN SILVER_ORDERS_DETAILS od
                ON o.order_id = od.order_id
            LEFT JOIN GOLD_DIM_CUSTOMERS c
                ON o.customer_id = c.customer_id
            LEFT JOIN GOLD_DIM_PRODUCTS p
                ON od.product_id = p.product_id
            LEFT JOIN GOLD_DIM_CALENDAR dc_order
                ON DATE(o.order_date) = dc_order.date_key
            LEFT JOIN GOLD_DIM_CALENDAR dc_required
                ON DATE(o.required_date) = dc_required.date_key
            LEFT JOIN GOLD_DIM_CALENDAR dc_shipped
                ON DATE(o.shipped_date) = dc_shipped.date_key
            WHERE c.customer_sk IS NOT NULL
                AND p.product_sk IS NOT NULL
                AND dc_order.date_sk IS NOT NULL
                AND o.order_date IS NOT NULL
        )
        SELECT
            order_id,
            customer_sk,
            product_sk,
            order_date_sk,
            required_date_sk,
            shipped_date_sk,
            unit_price,
            quantity,
            discount,
            total,
            hash_diff,
            total * discount AS total_discount,
            total - (total * discount) AS total_liquid
        FROM fact
    ) AS SOURCE
    ON TARGET.order_id = SOURCE.order_id
        AND TARGET.product_sk = SOURCE.product_sk

    WHEN MATCHED AND TARGET.hash_diff <> SOURCE.hash_diff THEN
        UPDATE SET
            TARGET.customer_sk = SOURCE.customer_sk,
            TARGET.order_date_sk = SOURCE.order_date_sk,
            TARGET.required_date_sk = SOURCE.required_date_sk,
            TARGET.shipped_date_sk = SOURCE.shipped_date_sk,
            TARGET.unit_price = SOURCE.unit_price,
            TARGET.quantity = SOURCE.quantity,
            TARGET.discount = SOURCE.discount,
            TARGET.total = SOURCE.total,
            TARGET.total_discount = SOURCE.total_discount,
            TARGET.total_liquid = SOURCE.total_liquid,
            TARGET.hash_diff = SOURCE.hash_diff,
            TARGET.last_updated = CURRENT_TIMESTAMP()

    WHEN NOT MATCHED THEN
        INSERT(
            order_id,
            customer_sk,
            product_sk,
            order_date_sk,
            required_date_sk,
            shipped_date_sk,
            unit_price,
            quantity,
            discount,
            total,
            total_discount,
            total_liquid,
            hash_diff,
            created_date,
            last_updated
        )
        VALUES(
            SOURCE.order_id,
            SOURCE.customer_sk,
            SOURCE.product_sk,
            SOURCE.order_date_sk,
            SOURCE.required_date_sk,
            SOURCE.shipped_date_sk,
            SOURCE.unit_price,
            SOURCE.quantity,
            SOURCE.discount,
            SOURCE.total,
            SOURCE.total_discount,
            SOURCE.total_liquid,
            SOURCE.hash_diff,
            CURRENT_TIMESTAMP(),
            CURRENT_TIMESTAMP()
        )
    ;

        RETURN 'Load Gold Fact Orders table successfuly';
    END;
    $$;

    CALL GOLD_FACT_ORDERS();