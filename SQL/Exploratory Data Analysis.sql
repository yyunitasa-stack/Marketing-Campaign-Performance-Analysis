-- ? Overall Campaign vs Non-Campaign Effectiveness
SELECT*FROM marketingsc.campaigns LIMIT 5;
SELECT*FROM marketingsc.transactions_clean LIMIT 5;
SELECT
	CASE
		WHEN campaign_id = '0' THEN 'Non-campaign'
		ELSE 'Campaign'
	END AS "Campaign Status",
	SUM(gross_revenue) AS "Total Revenue",
	COUNT(*) AS "Total Transactions",
	COUNT(*)
		FILTER(WHERE refund_flag = '0') AS "Total Purchase",
	COUNT(*)
		FILTER(WHERE refund_flag = '1') AS "Tota Refund",
	ROUND(100.0*COUNT(*)
		FILTER(WHERE refund_flag = '1')/COUNT(*),2) AS "Refund Rate (%)"
FROM marketingsc.transactions_clean
GROUP BY
	CASE
		WHEN campaign_id = '0' THEN 'Non-campaign'
		ELSE 'Campaign'
	END;
--> interpretasi: 

-- ? Actual vs Expected Uplift by Campaign
WITH campaign_metrics AS (
	SELECT
		c.campaign_id,
		(c.end_date - c.start_date)+1 AS duration,
		c.expected_uplift,
		COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'view') AS campaign_users,
		COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'purchase') AS campaign_buyers,
		ROUND(100.0*COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'purchase')/COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'view'),2) AS campaign_cr
	FROM marketingsc.campaigns AS c
	LEFT JOIN marketingsc.events_clean AS e
		ON e.campaign_id = c.campaign_id
		AND e.timestamp::DATE BETWEEN c.start_date AND c.end_date
	GROUP BY c.campaign_id, c.start_date, c.end_date, c.expected_uplift
),
non_campaign_metrics AS (
	SELECT
		c.campaign_id,
		COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'view') AS non_campaign_users,
		COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'purchase') AS non_campaign_buyers,
		ROUND(100.0*COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'purchase')/COUNT (DISTINCT e.customer_id)
			FILTER (WHERE e.event_type = 'view'),2) AS non_campaign_cr
	FROM marketingsc.campaigns AS c
	LEFT JOIN marketingsc.events_clean AS e
		ON e.campaign_id = '0'
		AND e.timestamp::DATE BETWEEN c.start_date AND c.end_date
	GROUP BY c.campaign_id
)
SELECT
	c.campaign_id AS "Campaign ID",
	c.duration AS "Duration",
	c.campaign_cr AS "Campaign CR (%)",
	n.non_campaign_cr AS "Non-Campaign CR (%)",
	ROUND((100.0*c.expected_uplift)::NUMERIC,2) AS "Expected Uplift (%)",
	campaign_cr - non_campaign_cr AS "Actual Uplift (%)",
	CASE 
		WHEN campaign_cr - non_campaign_cr >= ROUND((100.0*c.expected_uplift)::NUMERIC,2)
			THEN 'Target achieved'
		ELSE 'Target not achieved'
	END AS "Uplift Status"
FROM campaign_metrics AS c
JOIN non_campaign_metrics AS n
	ON c.campaign_id = n.campaign_id
ORDER BY "Actual Uplift (%)" DESC;
--> interpretasi:

-- ? Revenue and Refund Rate by Marketing Channel
SELECT*FROM marketingsc.transactions_clean;
SELECT*FROM marketingsc.campaigns;

SELECT
	c.channel,
	COUNT(t.transaction_id) AS total_transaction,
	ROUND(SUM(t.gross_revenue)::NUMERIC,2) AS total_revenue,
	COUNT(t.refund_flag)
		FILTER(WHERE t.refund_flag = 'true') AS total_refund,
	ROUND(100.0*COUNT(t.refund_flag)
		FILTER(WHERE t.refund_flag = 'true')/COUNT(t.transaction_id),2) AS "refund_rate (%)"
FROM marketingsc.transactions_clean AS t
JOIN marketingsc.campaigns AS c
	ON t.campaign_id = c.campaign_id
GROUP BY c.channel
ORDER BY total_revenue DESC;
--> interpretasi: channel affiliate menghasilkan revenue tertinggi sebesar 1.608.144,17 dan refund rate terendah (2,79%), dengan total refund sebanyak 494 dari 17.676 transaksi pembelian
--> interpretasi: diikuti oleh channel paid seacrh dengan total revenue sebesar 1.533.909,64 namun memiliki refund rate tertinggi (3,12%), dengan total refund sebanyak 528 dari 16.949 transaksi

-- ? Customer Conversion & Loyalty Tier
SELECT*FROM marketingsc.customers LIMIT 5;
SELECT*FROM marketingsc.events_clean LIMIT 5;

SELECT
	c.loyalty_tier AS "Loyalty Tier",
	COUNT(DISTINCT e.customer_id) AS "Total Customers",
	COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id != '0' AND e.event_type = 'purchase') AS "Campaign Buyers",
	COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id != '0' AND e.event_type = 'view') AS "Campaign Viewers",
	COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id = '0' AND e.event_type = 'purchase') AS "Non-Campaign Buyers",
	COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id = '0' AND e.event_type = 'view') AS "Non-Campain Viewers",
	ROUND((100.0*COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id != '0' AND e.event_type = 'purchase')/
		COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id != '0' AND e.event_type = 'view'))::NUMERIC,2) AS "Campaign CR (%)",
	ROUND((100.0*COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id = '0' AND e.event_type = 'purchase')/
		COUNT(DISTINCT e.customer_id)
		FILTER (WHERE e.campaign_id = '0' AND e.event_type = 'view'))::NUMERIC,2) AS "Non-Campaign CR (%)"
FROM marketingsc.customers AS c
JOIN marketingsc.events_clean AS e
	ON  e.customer_id = c.customer_id
GROUP BY c.loyalty_tier;
--> interpretasi: loyalty tier Platinum memiliki campain conversion rate tertinggi (63,06%) dengan non campain conversion rate juga tertinggi dibandingkan loyalty tier lain (30,87%), namun total customers yang dihasilkan paling sedikit (3.018)
--> interpretasi: 