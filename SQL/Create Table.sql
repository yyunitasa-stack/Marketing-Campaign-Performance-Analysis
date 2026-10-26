-- membuat table & mengimpor file .csv events
CREATE TABLE marketingsc.events (
event_id VARCHAR(10),
"timestamp" TIMESTAMP,
customer_id VARCHAR(10),
session_id VARCHAR(10),
event_type VARCHAR(15),
product_id NUMERIC,
device_type VARCHAR(10),
traffic_source VARCHAR(15),
campaign_id VARCHAR(2),
page_category VARCHAR(10),
session_duration_sec FLOAT,
experiment_group VARCHAR(10)
);

-- membuat table & mengimpor file .csv products
CREATE TABLE marketingsc.products (
product_id INT,
category VARCHAR(15),
brand VARCHAR(15),
base_price FLOAT,
launch_date DATE,
is_premium BOOLEAN
);

-- membuat table & mengimpor file .csv transactions
CREATE TABLE marketingsc.transactions (
transaction_id VARCHAR(10),
"timestamp" TIMESTAMP,
customer_id VARCHAR(10),
product_id NUMERIC,
quantity INT,
discount_applied FLOAT,
gross_revenue FLOAT,
campaign_id VARCHAR(2),
refund_flag BOOLEAN
);

-- membuat table & mengimpor file .csv campaigns
CREATE TABLE marketingsc.campaigns (
campaign_id VARCHAR(2),
channel VARCHAR(15),
objective VARCHAR(15),
start_date DATE,
end_date DATE,
target_segment VARCHAR(15),
expected_uplift FLOAT
);

-- membuat table & mengimpor file .csv customers
CREATE TABLE marketingsc.customers (
customer_id VARCHAR(10),
signup_date DATE,
country VARCHAR(2),
age INT,
gender VARCHAR(10),
loyalty_tier VARCHAR(10),
acquisition_channel VARCHAR(15)
);