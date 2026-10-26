-- ? Revenue and refund rate analysis by marketing channel
SELECT*FROM marketingsc.transactions_clean;
SELECT*FROM marketingsc.campaigns;
SELECT
	c.channel,
	COUNT(transaction_id) AS total_transaksi,
	ROUND(SUM(gross_revenue)::NUMERIC,2) AS total_revenue,
	COUNT(refund_flag)
		FILTER(WHERE refund_flag = 'true') AS total_refund,
	ROUND(100.0*COUNT(refund_flag)
		FILTER(WHERE refund_flag = 'true')/COUNT(transaction_id),2) AS pct_refund_rate
FROM marketingsc.transactions_clean AS t
JOIN marketingsc.campaigns AS c
	ON t.campaign_id = c.campaign_id
GROUP BY c.channel;
--> interpretasi: 

-- ? Campaign vs. non-campaign performance analysis
SELECT*FROM marketingsc.events_clean LIMIT 5;
SELECT*FROM marketingsc.campaigns LIMIT 5;
WITH campaign_metrics AS (
	SELECT
		c.objective,
		COUNT (DISTINCT e.session_id) AS total_transactions,
		COUNT (DISTINCT e.session_id)
			FILTER (WHERE e.event_type = 'purchase') AS total_purchases,
		AVG(c.expected_uplift) AS avg_expected_uplift
	FROM marketingsc.events_clean AS e
	JOIN marketingsc.campaigns AS c
		ON e.campaign_id = c.campaign_id
	WHERE e.campaign_id != '0'
	GROUP BY c.objective
),
no_campaign_metrics AS(
	SELECT
		COUNT (DISTINCT session_id) AS total_transactions,
		COUNT (DISTINCT session_id)
			FILTER (WHERE event_type = 'purchase') AS total_purchases
	FROM marketingsc.events_clean
	WHERE campaign_id = '0'
),
conversion_rate_metrics AS(
	SELECT
		c.objective,
		c.total_transactions,
		c.total_purchases,
		ROUND((100.0*c.total_purchases/NULLIF(c.total_transactions,0))::NUMERIC,2) AS pct_campaign_cr,
		ROUND((100.0*n.total_purchases/NULLIF(n.total_transactions,0))::NUMERIC,2) AS pct_no_campaign_cr,
		ROUND((100.0*c.avg_expected_uplift)::NUMERIC,2) AS pct_expected_uplift
	FROM campaign_metrics AS c
	CROSS JOIN no_campaign_metrics AS n
),
uplift_metrics AS(
	SELECT *,
	ROUND(100.0*(pct_campaign_cr - pct_no_campaign_cr)/NULLIF(pct_no_campaign_cr,0),2) AS pct_actual_uplift
	FROM conversion_rate_metrics
)
SELECT 
	*,
	CASE
		WHEN pct_actual_uplift>=pct_expected_uplift
			THEN 'Target achieved'
		ELSE 'Target not achieved'
	END AS target_status
FROM uplift_metrics
ORDER BY pct_campaign_cr;

-- ? Conversion funnel drop-off analysis by device type
SELECT*FROM marketingsc.events_clean LIMIT 5;
SELECT event_type 
FROM marketingsc.events_clean
GROUP BY event_type;

WITH funnel_counts AS (
	SELECT
		CASE
            WHEN campaign_id = '0' THEN 'Non-Campaign'
            ELSE 'Campaign'
        END AS campaign_type,
		COUNT(DISTINCT session_id) AS total_sessions,
		COUNT(DISTINCT session_id)
			FILTER (WHERE event_type = 'view') AS product_views,
		COUNT(DISTINCT session_id)
			FILTER (WHERE event_type = 'add_to_cart') AS add_to_carts,
		COUNT(DISTINCT session_id)
			FILTER (WHERE event_type = 'purchase') AS purchases
	FROM marketingsc.events_clean
	GROUP BY 
		CASE
            WHEN campaign_id = '0' THEN 'Non-Campaign'
            ELSE 'Campaign'
        END
),

funnel_table AS (
	-- 1. session start
	SELECT
		campaign_type,
		1 AS stage_order,
		'Session start' AS funnel_stage,
		total_sessions AS current_sessions,
		total_sessions AS previous_sessions,
		total_sessions AS base_sessions
	FROM funnel_counts
	UNION ALL
	-- 2. product view
	SELECT
		campaign_type, 2, 'Product view', product_views, total_sessions, total_sessions
	FROM funnel_counts
	UNION ALL
	-- 3. add to cart
	SELECT
		campaign_type, 3, 'Add to cart', add_to_carts, product_views, total_sessions
	FROM funnel_counts
	UNION ALL
	-- 4. purchase
	SELECT
		campaign_type, 4, 'Purchase', purchases, add_to_carts, total_sessions
	FROM funnel_counts
)
SELECT
	campaign_type AS "Campaign Type",
	funnel_stage AS "Funnel Stage",
	current_sessions AS "Total Sessions",
	ROUND(100.0*current_sessions/previous_sessions,2) AS "stage-to-stage CR (%)",
	ROUND(100.0*(previous_sessions - current_sessions)/previous_sessions,2) AS "drop off rate (%)",
	ROUND(100.0*current_sessions/base_sessions,2) AS "cumulative CR (%)"
FROM funnel_table
ORDER BY campaign_type, stage_order;

-- ? Discount impact on purchase volume and refund rate on campaign session
SELECT*FROM marketingsc.transactions_clean;
SELECT*FROM marketingsc.products;

SELECT
	CASE
		WHEN campaign_id = '0' THEN 'Non-Campaign'
		ELSE 'Campaign'
	END AS campaign_type,
	ROUND((100*discount_applied)::NUMERIC) AS "discount (%)",
	COUNT(transaction_id) AS total_transactions,
	COUNT(transaction_id)
		FILTER (WHERE refund_flag = 'false') AS total_purchases,
	COUNT(transaction_id)
		FILTER (WHERE refund_flag = 'true') AS total_refund,
	ROUND(100.0*COUNT(transaction_id) FILTER (WHERE refund_flag = 'true')/COUNT(transaction_id),2) AS "refund_rate (%)"
FROM marketingsc.transactions_clean
GROUP BY 
	CASE
		WHEN campaign_id = '0' THEN 'Non-Campaign'
		ELSE 'Campaign' 
	END,
	"discount (%)"
ORDER BY campaign_type, "refund_rate (%)" DESC;

-- ? Customer segment revenue and promotion responsiveness analysis
SELECT*FROM marketingsc.transactions_clean LIMIT 5;
SELECT*FROM marketingsc.customers LIMIT 5;
SELECT*FROM marketingsc.campaigns LIMIT 5;

SELECT
	c.loyalty_tier,
	COUNT(t.transaction_id)
		FILTER (WHERE t.campaign_id != '0')AS transaction_campaign,
	COUNT(t.transaction_id)
		FILTER (WHERE t.campaign_id = '0') AS transaction_no_campaign,
	SUM(t.gross_revenue) 
		FILTER (WHERE t.campaign_id != '0') AS revenue_campaign,
	SUM(t.gross_revenue)
		FILTER (WHERE t.campaign_id = '0') AS revenue_no_campaign
FROM marketingsc.transactions_clean AS t
JOIN marketingsc.customers AS c
	ON t.customer_id = c.customer_id
GROUP BY c.loyalty_tier
ORDER BY revenue_campaign DESC;
