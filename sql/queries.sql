-- Q1: Restaurants, rated count and average rating per city
SELECT city,
       COUNT(*) AS restaurants,
       SUM(is_rated) AS rated,
       ROUND(AVG(CASE WHEN is_rated = 1 THEN aggregate_rating END), 2) AS avg_rating
FROM restaurants
GROUP BY city
ORDER BY restaurants DESC;

-- Q2: Average rating by cost band
SELECT CASE WHEN average_cost_for_two < 300 THEN '1. Under 300'
            WHEN average_cost_for_two < 600 THEN '2. 300-599'
            WHEN average_cost_for_two < 1000 THEN '3. 600-999'
            ELSE '4. 1000+' END AS cost_band,
       COUNT(*) AS restaurants,
       ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM restaurants
WHERE is_rated = 1
GROUP BY cost_band
ORDER BY cost_band;

-- Q3: Chain vs independent restaurants
SELECT CASE WHEN is_chain = 1 THEN 'Chain' ELSE 'Independent' END AS type,
       COUNT(*) AS restaurants,
       ROUND(AVG(aggregate_rating), 2) AS avg_rating,
       ROUND(AVG(average_cost_for_two), 0) AS avg_cost,
       ROUND(AVG(votes), 0) AS avg_votes
FROM restaurants
WHERE is_rated = 1
GROUP BY is_chain;

-- Q4: Top 3 localities per city (min 20 rated restaurants) using RANK
WITH loc AS (
    SELECT city, locality, COUNT(*) AS n,
           ROUND(AVG(aggregate_rating), 2) AS avg_rating
    FROM restaurants
    WHERE is_rated = 1
    GROUP BY city, locality
    HAVING COUNT(*) >= 20
)
SELECT * FROM (
    SELECT city, locality, n, avg_rating,
           RANK() OVER (PARTITION BY city ORDER BY avg_rating DESC) AS rank_in_city
    FROM loc
)
WHERE rank_in_city <= 3
ORDER BY city, rank_in_city;

-- Q5: Localities rated well above the NCR average (CTE with cross join)
WITH overall AS (
    SELECT AVG(aggregate_rating) AS ncr_avg
    FROM restaurants WHERE is_rated = 1
),
loc AS (
    SELECT city, locality, COUNT(*) AS n, AVG(aggregate_rating) AS avg_rating
    FROM restaurants
    WHERE is_rated = 1
    GROUP BY city, locality
    HAVING COUNT(*) >= 20
)
SELECT city, locality, n,
       ROUND(avg_rating, 2) AS avg_rating,
       ROUND(avg_rating - ncr_avg, 2) AS above_ncr
FROM loc, overall
WHERE avg_rating > ncr_avg + 0.4
ORDER BY above_ncr DESC
LIMIT 8;

-- Q6: Table booking share and rating by price range (shows confounding)
SELECT price_range,
       SUM(CASE WHEN has_table_booking = 'Yes' THEN 1 ELSE 0 END) AS with_booking,
       COUNT(*) AS total,
       ROUND(100.0 * SUM(CASE WHEN has_table_booking = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_with_booking,
       ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM restaurants
WHERE is_rated = 1
GROUP BY price_range
ORDER BY price_range;

-- Q7: Best-rated chains with at least 10 outlets
SELECT restaurant_name,
       COUNT(*) AS outlets,
       ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM restaurants
WHERE is_rated = 1 AND is_chain = 1
GROUP BY restaurant_name
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC
LIMIT 8;

-- Q8: High-rated localities with the least competition (opportunity candidates)
SELECT city, locality,
       COUNT(*) AS n,
       ROUND(AVG(aggregate_rating), 2) AS avg_rating,
       ROUND(AVG(average_cost_for_two), 0) AS avg_cost,
       SUM(votes) AS total_votes
FROM restaurants
WHERE is_rated = 1
GROUP BY city, locality
HAVING COUNT(*) >= 20 AND AVG(aggregate_rating) >= 3.5
ORDER BY n ASC
LIMIT 8;