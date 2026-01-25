CREATE TABLE IF NOT EXISTS BRONZE_PRODUCTS (
    raw VARIANT,            -- JSON data at first column ($1)
    filename STRING,        -- Source File name
    created_at TIMESTAMP    -- Detetime when data was uploaded
);