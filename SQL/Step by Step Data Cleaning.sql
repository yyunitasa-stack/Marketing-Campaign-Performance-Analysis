-- DATA PREPARATION
--- Column & Data Type
SELECT * FROM marketingsc.events LIMIT 5;
--! interpretasi: kolom product_id memiliki tipe data numerik, sehingga perlu diperbaiki menjadi string

SELECT * FROM marketingsc.campaigns LIMIT 5;

SELECT * FROM marketingsc.customers LIMIT 5;

SELECT * FROM marketingsc.products LIMIT 5;

SELECT * FROM marketingsc.transactions LIMIT 5;
--! interpretasi: kolom product_id memiliki tipe data numerik, sehingga perlu diperbaiki menjadi string

--! mengubah tipe data kolom product_id menjadi string pada table events & transactions
ALTER TABLE marketingsc.events
ALTER COLUMN product_id TYPE VARCHAR(5)
USING product_id::INTEGER::VARCHAR;

ALTER TABLE marketingsc.transactions
ALTER COLUMN product_id TYPE VARCHAR(5)
USING product_id::INTEGER::VARCHAR;

--- Data Quality Check
---- a. Nilai tidak konsisten & whitespace
----- EVENTS -> !terdapat nilai tidak konsisten (traffic_source)
SELECT * FROM marketingsc.events LIMIT 5;

SELECT DISTINCT event_type FROM marketingsc.events;

SELECT DISTINCT device_type FROM marketingsc.events;

SELECT DISTINCT traffic_source FROM marketingsc.events;
SELECT traffic_source, COUNT(*) AS jumlah
FROM marketingsc.events
GROUP BY traffic_source
ORDER BY jumlah DESC;
--! interpretasi: terdapat beberapa nilai dengan penulisan yang tidak konsisten

SELECT DISTINCT page_category FROM marketingsc.events;

SELECT DISTINCT experiment_group FROM marketingsc.events;

----- CAMPAIGNS -> tidak memiliki nilai tidak konsisten/whitespace
SELECT * FROM marketingsc.campaigns LIMIT 5;

SELECT DISTINCT channel FROM marketingsc.campaigns;

SELECT DISTINCT objective FROM marketingsc.campaigns;

SELECT DISTINCT target_segment FROM marketingsc.campaigns;

----- CUSTOMERS -> tidak memiliki nilai tidak konsisten/whitespace
SELECT * FROM marketingsc.customers LIMIT 5;

SELECT DISTINCT country FROM marketingsc.customers;

SELECT DISTINCT gender FROM marketingsc.customers;

SELECT DISTINCT loyalty_tier FROM marketingsc.customers;

SELECT DISTINCT acquisition_channel FROM marketingsc.customers;

----- PRODUCTS -> tidak memiliki nilai tidak konsisten/whitespace
SELECT * FROM marketingsc.products LIMIT 5;

SELECT DISTINCT category FROM marketingsc.products;

SELECT DISTINCT brand FROM marketingsc.products;
SELECT brand, COUNT(*) AS jumlah
FROM marketingsc.products
GROUP BY brand
ORDER BY brand ASC;

SELECT DISTINCT is_premium FROM marketingsc.products;

----- TRANSACTIONS -> tidak memiliki nilai tidak konsisten/whitespace
SELECT * FROM marketingsc.transactions LIMIT 5;

SELECT DISTINCT refund_flag FROM marketingsc.transactions;

---- b. Nilai tidak valid
----- EVENTS -> tidak memiliki nilai tidak valid
SELECT * FROM marketingsc.events LIMIT 5;

SELECT 
	MIN(timestamp) AS tanggal_min,
	MAX(timestamp) AS tanggal_max
FROM marketingsc.events;

SELECT
	MIN(session_duration_sec) AS nilai_min,
	MAX(session_duration_sec) AS nilai_max
FROM marketingsc.events;

----- CAMPAIGNS -> tidak memiliki nilai tidak valid
SELECT * FROM marketingsc.campaigns LIMIT 5;

SELECT 
	MIN(start_date) AS tanggal_min,
	MAX(start_date) AS tanggal_max
FROM marketingsc.campaigns;

SELECT 
	MIN(end_date) AS tanggal_min,
	MAX(end_date) AS tanggal_max
FROM marketingsc.campaigns;

SELECT 
	MIN(expected_uplift) AS nilai_min,
	MAX(expected_uplift) AS nilai_max
FROM marketingsc.campaigns;

----- CUSTOMERS -> tidak memiliki nilai tidak valid
SELECT * FROM marketingsc.customers LIMIT 5;

SELECT 
	MIN(signup_date) AS tanggal_min,
	MAX(signup_date) AS tanggal_max
FROM marketingsc.customers;

SELECT 
	MIN(age) AS nilai_min,
	MAX(age) AS niai_max
FROM marketingsc.customers;

----- PRODUCTS -> tidak memiliki nilai tidak valid
SELECT * FROM marketingsc.products LIMIT 5;

SELECT 
	MIN(base_price) AS nilai_min,
	MAX(base_price) AS niai_max
FROM marketingsc.products;

SELECT 
	MIN(launch_date) AS tanggal_min,
	MAX(launch_date) AS tanggal_max
FROM marketingsc.products;

----- TRANSACTIONS -> tidak memiliki nilai tidak valid
SELECT * FROM marketingsc.transactions LIMIT 5;

SELECT 
	MIN(timestamp) AS tanggal_min,
	MAX(timestamp) AS tanggal_max
FROM marketingsc.transactions;

SELECT 
	MIN(quantity) AS nilai_min,
	MAX(quantity) AS niai_max
FROM marketingsc.transactions;

SELECT 
	MIN(discount_applied) AS nilai_min,
	MAX(discount_applied) AS niai_max
FROM marketingsc.transactions;

SELECT 
	MIN(gross_revenue) AS nilai_min,
	MAX(gross_revenue) AS niai_max
FROM marketingsc.transactions;
--> gross_revenue memiliki nilai negatif untuk transaksi refund
--* menampilkan nilai gross_revenue<0
SELECT * FROM marketingsc.transactions
WHERE gross_revenue<0;

SELECT*FROM marketingsc.transactions_clean LIMIT 5;
SELECT *
FROM marketingsc.transactions
WHERE product_id IS NULL AND gross_revenue IS NULL;


---- c. Duplicate data
----- EVENTS -> tidak memiliki data duplikat
SELECT * FROM marketingsc.events;

SELECT event_id, COUNT(*) AS jumlah
FROM marketingsc.events
GROUP BY event_id
HAVING COUNT(*)>1;

----- CAMPAIGNS -> tidak memiliki data duplikat
SELECT * FROM marketingsc.campaigns;

SELECT campaign_id, COUNT(*) AS jumlah 
FROM marketingsc.campaigns
GROUP BY campaign_id
HAVING COUNT(*)>1;

----- CUSTOMERS -> tidak memiliki data duplikat
SELECT * FROM marketingsc.customers;

SELECT customer_id, COUNT(*) AS jumlah
FROM marketingsc.customers
GROUP BY customer_id
HAVING COUNT(*)>1;

----- PRODUCTS -> tidak memiliki data duplikat
SELECT * FROM marketingsc.products;

SELECT product_id, COUNT(*) AS jumlah
FROM marketingsc.products
GROUP BY product_id
HAVING COUNT(*)>1;

----- CAMPAIGNS -> tidak memiliki data duplikat
SELECT * FROM marketingsc.transactions;

SELECT transaction_id, COUNT(*) AS jumlah
FROM marketingsc.transactions
GROUP BY transaction_id
HAVING COUNT(*)>1;

---- d. Missing value
----- EVENTS -> terdapat missing value (product_id & device_type)
--> terdapat 200.371 missing value pada kolom product_id
--> terdapat 40.300 missing value pada kolom device_type
SELECT * FROM marketingsc.events;
SELECT
	COUNT(*) FILTER (WHERE event_id IS NULL) AS missing_event_id,
	COUNT(*) FILTER (WHERE timestamp IS NULL) AS missing_timestamp,
	COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
	COUNT(*) FILTER (WHERE session_id IS NULL) AS missing_session_id,
	COUNT(*) FILTER (WHERE event_type IS NULL) AS missing_event_type,
	COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
	COUNT(*) FILTER (WHERE device_type IS NULL) AS missing_device_type,
	COUNT(*) FILTER (WHERE traffic_source IS NULL) AS missing_traffic_source,
	COUNT(*) FILTER (WHERE campaign_id IS NULL) AS missing_campaign_id,
	COUNT(*) FILTER (WHERE page_category IS NULL) AS missing_page_category,
	COUNT(*) FILTER (WHERE session_duration_sec IS NULL) AS missing_session_duration_sec,
	COUNT(*) FILTER (WHERE experiment_group IS NULL) AS missing_experiment_group
FROM marketingsc.events;

--* menampilkan baris yang memiliki missing value
SELECT * FROM marketingsc.events
WHERE product_id IS NULL;

SELECT * FROM marketingsc.events
WHERE device_type IS NULL;

--* menampilkan product_id dari event_type = bounce
SELECT product_id, event_type FROM marketingsc.events
WHERE event_type='bounce';
--! semua event_type=bounce memiliki product_id bernilai NULL

----- CAMPAIGNS -> tidak memiliki missing value
SELECT * FROM marketingsc.campaigns;
SELECT
	COUNT(*) FILTER (WHERE campaign_id IS NULL) AS missing_campaign_id,
	COUNT(*) FILTER (WHERE channel IS NULL) AS missing_channel,
	COUNT(*) FILTER (WHERE objective IS NULL) AS missing_objective,
	COUNT(*) FILTER (WHERE start_date IS NULL) AS missing_start_date,
	COUNT(*) FILTER (WHERE end_date IS NULL) AS missing_end_date,
	COUNT(*) FILTER (WHERE target_segment IS NULL) AS missing_target_segment,
	COUNT(*) FILTER (WHERE expected_uplift IS NULL) AS missing_expected_uplift
FROM marketingsc.campaigns;

----- CUSTOMERS -> tidak memiliki missing value
SELECT * FROM marketingsc.customers;
SELECT
	COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
	COUNT(*) FILTER (WHERE signup_date IS NULL) AS missing_signup_date,
	COUNT(*) FILTER (WHERE country IS NULL) AS missing_country,
	COUNT(*) FILTER (WHERE age IS NULL) AS missing_age,
	COUNT(*) FILTER (WHERE gender IS NULL) AS missing_gender,
	COUNT(*) FILTER (WHERE loyalty_tier IS NULL) AS missing_loyalty_tier,
	COUNT(*) FILTER (WHERE acquisition_channel IS NULL) AS missing_acquisition_channel
FROM marketingsc.customers;

----- PRODUCTS -> tidak memiliki missing value
SELECT * FROM marketingsc.products;
SELECT
	COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
	COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
	COUNT(*) FILTER (WHERE brand IS NULL) AS missing_brand,
	COUNT(*) FILTER (WHERE base_price IS NULL) AS missing_base_price,
	COUNT(*) FILTER (WHERE launch_date IS NULL) AS missing_launch_date,
	COUNT(*) FILTER (WHERE is_premium IS NULL) AS missing_is_premium
FROM marketingsc.products;

----- CAMPAIGNS -> terdapat missing value (product_id & gross_revenue)
--> terdapat 10.449 missing value pada kolom product_id
--> terdapat 10.449 missing value pada kolom gross_revenue
SELECT * FROM marketingsc.transactions;
SELECT
	COUNT(*) FILTER (WHERE transaction_id IS NULL) AS missing_transaction_id,
	COUNT(*) FILTER (WHERE timestamp IS NULL) AS missing_timestamp,
	COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
	COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
	COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
	COUNT(*) FILTER (WHERE discount_applied IS NULL) AS missing_discount_applied,
	COUNT(*) FILTER (WHERE gross_revenue IS NULL) AS missing_gross_revenue,
	COUNT(*) FILTER (WHERE campaign_id IS NULL) AS missing_campaign_id,
	COUNT(*) FILTER (WHERE refund_flag IS NULL) AS missing_refund_flag
FROM marketingsc.transactions;

--* menampilkan baris yang memiliki missing value
SELECT * FROM marketingsc.transactions
WHERE product_id IS NULL;

-- DATA CLEANING
--* membuat table clean (yang sudah dibersihkan)
CREATE TABLE marketingsc.events_clean AS SELECT * FROM marketingsc.events;
CREATE TABLE marketingsc.transactions_clean AS SELECT * FROM marketingsc.transactions;

--- a. Mengatasi nilai tidak konsisten pada table events (kolom traffic_source)
--! 59.870 rows affected
UPDATE marketingsc.events_clean
SET traffic_source = INITCAP(traffic_source);

--- b. Mengatasi missing value
--* mengganti missing value pada kolom event_type dengan 'unknown' (table event)
--! 40.300 rows affected
UPDATE marketingsc.events_clean
SET device_type='unknown'
WHERE device_type IS NULL;

--* menghapus baris yang mengandung missing value pada kolom product_id dan gross_revenue (table transactions)
--! 10.449 rows affected
DELETE FROM marketingsc.transactions_clean
WHERE gross_revenue IS NULL;
