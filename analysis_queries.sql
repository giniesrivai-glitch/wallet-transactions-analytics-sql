-- analysis_queries.sql
-- Practical queries you can demo and discuss

-- 1) Monthly transaction counts and GMV
SELECT
  DATE_TRUNC('month', txn_date) AS month,
  COUNT(*) AS txn_count,
  ROUND(SUM(amount), 2) AS gmv
FROM transactions
GROUP BY 1
ORDER BY 1;

-- 2) Top 5 states by GMV
SELECT u.state, ROUND(SUM(t.amount),2) AS total_gmv
FROM transactions t
JOIN users u ON u.id = t.user_id
GROUP BY u.state
ORDER BY total_gmv DESC
LIMIT 5;

-- 3) AOV by payment method
SELECT payment_method, ROUND(AVG(amount), 2) AS avg_order_value
FROM transactions
GROUP BY payment_method
ORDER BY avg_order_value DESC;

-- 4) Repeat customer rate
WITH counts AS (
  SELECT user_id, COUNT(*) AS n FROM transactions GROUP BY user_id
)
SELECT
  ROUND( 100.0 * SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_customer_pct
FROM counts;

-- 5) Merchant category revenue ranking
SELECT m.category, ROUND(SUM(t.amount),2) AS revenue
FROM transactions t
JOIN merchants m ON m.id = t.merchant_id
GROUP BY m.category
ORDER BY revenue DESC;

-- 6) MoM growth on txn counts
WITH m AS (
  SELECT DATE_TRUNC('month', txn_date) AS month, COUNT(*) AS txns
  FROM transactions
  GROUP BY 1
)
SELECT
  month, txns,
  LAG(txns) OVER (ORDER BY month) AS prev_txns,
  ROUND(100.0 * (txns - LAG(txns) OVER (ORDER BY month)) / NULLIF(LAG(txns) OVER (ORDER BY month),0), 2) AS pct_growth
FROM m
ORDER BY month;

-- 7) RFM-like recency and monetary bands per user
WITH last_txn AS (
  SELECT user_id, MAX(txn_date) AS last_txn_date, SUM(amount) AS monetary
  FROM transactions
  GROUP BY user_id
)
SELECT
  u.id AS user_id,
  CASE
    WHEN CURRENT_DATE - last_txn.last_txn_date <= 30 THEN 'Active'
    WHEN CURRENT_DATE - last_txn.last_txn_date <= 60 THEN 'Warm'
    ELSE 'Churn Risk'
  END AS recency_band,
  CASE
    WHEN monetary >= 10000 THEN 'High'
    WHEN monetary >= 4000 THEN 'Medium'
    ELSE 'Low'
  END AS monetary_band
FROM users u
JOIN last_txn ON last_txn.user_id = u.id
ORDER BY user_id;

-- 8) Category preference per state (share of GMV)
WITH gmv AS (
  SELECT u.state, m.category, SUM(t.amount) AS gmv
  FROM transactions t
  JOIN users u ON u.id = t.user_id
  JOIN merchants m ON m.id = t.merchant_id
  GROUP BY u.state, m.category
),
tot AS (
  SELECT state, SUM(gmv) AS total FROM gmv GROUP BY state
)
SELECT g.state, g.category,
       ROUND(100.0 * g.gmv / t.total, 2) AS share_pct
FROM gmv g
JOIN tot t USING (state)
ORDER BY g.state, share_pct DESC;