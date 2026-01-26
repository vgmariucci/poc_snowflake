CREATE OR REPLACE PROCEDURE GOLD_DIM_CALENDAR()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$

BEGIN

CREATE OR REPLACE TABLE GOLD_DIM_CALENDAR AS
WITH bound AS (
    SELECT
        MIN(order_date) AS min_date,
        MAX(order_date) AS max_date
    FROM SILVER_ORDERS
),
dates AS(
    SELECT
        DATEADD(
            day,
            seq4(),
            b.min_date
        ) AS date_day
    FROM bound b
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 10000)) g
    WHERE DATEADD(day, seq4(), b.min_date) <= b.max_date
)
SELECT
    ROW_NUMBER() OVER (ORDER BY date_day) AS date_sk,
    date_day AS date_key,
    YEAR(date_day) AS quarter,
    MONTH(date_day) AS month,
    DAY(date_day) AS day,
    MONTHNAME(date_day) AS month_name,
    DAYNAME(date_day) AS day_name,
    WEEKOFYEAR(date_day) AS week_number,
    IFF(DAYNAME(date_day) IN ('Sat', 'Sun'), true, false) AS is_weekend
FROM dates
ORDER BY date_day

;

RETURN 'Load Gold Dim Calendar table successfully';

END
$$;


