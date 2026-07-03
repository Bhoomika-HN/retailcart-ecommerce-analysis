/* ============================================================
   RetailCart E-Commerce — Sales & Profitability Analysis
   Database  : PostgreSQL
   Dataset   : 1,000 orders | Nov 2024 – Apr 2025
   Author    : Bhoomika
   ============================================================

   BUSINESS PROBLEM
   ----------------
   Analyse RetailCart's sales performance across product
   categories, marketing channels, and geographic regions to
   identify revenue drivers, profitability challenges, and
   actionable opportunities to improve overall margins.

   SECTIONS
   --------
   A. Data Profiling
   B. Revenue & Profit Drivers
   C. Margin & Efficiency Analysis
   D. Discount Impact Analysis
   E. Concentration Risk (Revenue & Profit Share)
   F. Loss & Risk Analysis
   G. Category Deep Dive — Electronics
   H. Category Deep Dive — Books
   I. Channel Deep Dive — Paid Ads
   J. Regional Deep Dive
   K. Time Trend Analysis
   ============================================================ */


/* ============================================================
   A. DATA PROFILING
   Goal: Understand the dataset's scope before any analysis.
   ============================================================ */

-- Total row count
SELECT COUNT(*) AS total_orders FROM orders;
-- Result: 1000

-- Date range of the dataset
SELECT
    MIN(order_date)                        AS first_order,
    MAX(order_date)                        AS last_order,
    MAX(order_date) - MIN(order_date)      AS duration_days
FROM orders;
-- Result: 2024-11-01 to 2025-04-30 | 180 days (~6 months)

-- Order count per category (to confirm even distribution)
SELECT
    category,
    COUNT(*) AS order_count
FROM orders
GROUP BY category
ORDER BY order_count DESC;
/*
Beauty          154
Electronics     145
Toys            145
Books           143
Fashion         142
Sports          138
Home & Kitchen  133

Finding: Order counts are remarkably even across all seven
categories (133–154), confirming that revenue differences
are driven entirely by price (AOV), not by sales volume.
*/


/* ============================================================
   B. REVENUE & PROFIT DRIVERS
   Goal: Identify which category, region, and channel
         generates the most revenue and profit in absolute ₹.
   ============================================================ */

-- Overall business totals
SELECT
    SUM(revenue) AS total_revenue,
    SUM(profit)  AS total_profit
FROM orders;
-- Result: Revenue ₹35,44,282 | Profit ₹11,28,316

-- Highest revenue category
WITH ranked_revenue AS (
    SELECT
        category,
        SUM(revenue)                                    AS total_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC)        AS rnk
    FROM orders
    GROUP BY category
)
SELECT category, total_revenue FROM ranked_revenue WHERE rnk = 1;
-- Result: Electronics ₹17,79,316

-- Highest profit category
WITH ranked_profit AS (
    SELECT
        category,
        SUM(profit)                                     AS total_profit,
        RANK() OVER (ORDER BY SUM(profit) DESC)         AS rnk
    FROM orders
    GROUP BY category
)
SELECT category, total_profit FROM ranked_profit WHERE rnk = 1;
-- Result: Electronics ₹4,72,444

-- Highest revenue region
WITH ranked_revenue AS (
    SELECT
        region,
        SUM(revenue)                                    AS total_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC)        AS rnk
    FROM orders
    GROUP BY region
)
SELECT region, total_revenue FROM ranked_revenue WHERE rnk = 1;
-- Result: Central ₹8,42,722

-- Highest profit region
WITH ranked_profit AS (
    SELECT
        region,
        SUM(profit)                                     AS total_profit,
        RANK() OVER (ORDER BY SUM(profit) DESC)         AS rnk
    FROM orders
    GROUP BY region
)
SELECT region, total_profit FROM ranked_profit WHERE rnk = 1;
-- Result: Central ₹2,56,896

-- Highest revenue channel
WITH ranked_revenue AS (
    SELECT
        channel,
        SUM(revenue)                                    AS total_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC)        AS rnk
    FROM orders
    GROUP BY channel
)
SELECT channel, total_revenue FROM ranked_revenue WHERE rnk = 1;
-- Result: Referral ₹8,14,761

-- Highest profit channel
WITH ranked_profit AS (
    SELECT
        channel,
        SUM(profit)                                     AS total_profit,
        RANK() OVER (ORDER BY SUM(profit) DESC)         AS rnk
    FROM orders
    GROUP BY channel
)
SELECT channel, total_profit FROM ranked_profit WHERE rnk = 1;
-- Result: Referral ₹3,01,712

-- Highest COGS category
WITH ranked_cogs AS (
    SELECT
        category,
        SUM(cogs)                                       AS total_cogs,
        RANK() OVER (ORDER BY SUM(cogs) DESC)           AS rnk
    FROM orders
    GROUP BY category
)
SELECT category, total_cogs FROM ranked_cogs WHERE rnk = 1;
-- Result: Electronics ₹12,82,873


/* ============================================================
   C. MARGIN & EFFICIENCY ANALYSIS
   Goal: Understand profitability as a percentage of revenue
         rather than absolute ₹, to reveal true efficiency.
   Note: Margin = profit / revenue. A category with high
         profit ₹ but low margin is less efficient per rupee
         of revenue than one with lower profit but higher margin.
   ============================================================ */

-- Overall business profit margin
SELECT
    ROUND(100.0 * SUM(profit) / SUM(revenue), 2) AS profit_margin_pct
FROM orders;
-- Result: 31.83%

-- Profit margin by category
SELECT
    category,
    ROUND(100.0 * SUM(profit) / SUM(revenue), 2) AS profit_margin_pct
FROM orders
GROUP BY category
ORDER BY profit_margin_pct DESC;
/*
Fashion         43.10%   ← highest margin
Home & Kitchen  40.04%
Sports          36.03%
Beauty          35.46%
Toys            30.27%
Books           29.28%
Electronics     26.55%   ← lowest margin despite highest revenue
*/

-- Profit margin by region
SELECT
    region,
    ROUND(100.0 * SUM(profit) / SUM(revenue), 2) AS profit_margin_pct
FROM orders
GROUP BY region
ORDER BY profit_margin_pct DESC;
/*
West    33.54%   ← highest margin
South   33.45%
North   31.30%
East    31.07%
Central 30.48%   ← lowest margin despite highest revenue
*/

-- Profit margin by channel
SELECT
    channel,
    ROUND(100.0 * SUM(profit) / SUM(revenue), 2) AS profit_margin_pct
FROM orders
GROUP BY channel
ORDER BY profit_margin_pct DESC;
/*
Referral        37.03%   ← highest margin
Organic Search  36.30%
Social Media    31.69%
Email           28.68%
Paid Ads        23.74%   ← lowest margin
*/

-- Average Order Value (AOV) by category
-- Reveals why Electronics dominates revenue despite similar order counts
SELECT
    category,
    ROUND(SUM(revenue)::NUMERIC / COUNT(*), 0) AS aov
FROM orders
GROUP BY category
ORDER BY aov DESC;
/*
Electronics     ₹12,271   ← 20x higher than Books
Home & Kitchen   ₹3,982
Sports           ₹3,119
Fashion          ₹1,956
Toys             ₹1,650
Beauty           ₹1,295
Books              ₹617
*/

-- AOV by channel
SELECT
    channel,
    ROUND(SUM(revenue)::NUMERIC / COUNT(*), 0) AS aov
FROM orders
GROUP BY channel
ORDER BY aov DESC;
/*
Referral        ₹3,825
Social Media    ₹3,645
Organic Search  ₹3,617
Paid Ads        ₹3,329
Email           ₹3,262
*/


/* ============================================================
   D. DISCOUNT IMPACT ANALYSIS
   Goal: Quantify how heavily each segment discounts, and
         whether higher discounts actually hurt profit margins.
   ============================================================ */

-- Discount % by category
SELECT
    category,
    ROUND(100.0 * SUM(discount) / SUM(revenue), 2) AS discount_pct
FROM orders
GROUP BY category
ORDER BY discount_pct DESC;
/*
Sports          17.64%
Electronics     16.29%
Home & Kitchen  16.27%
Beauty          15.60%
Fashion         15.43%
Books           15.35%
Toys            15.17%

Finding: Discount rates are closely clustered across categories
(15–18%) — discounting is not what differentiates Electronics'
margin from Fashion's. That gap is explained by COGS (Section G).
*/

-- Discount % by region
SELECT
    region,
    ROUND(100.0 * SUM(discount) / SUM(revenue), 2) AS discount_pct
FROM orders
GROUP BY region
ORDER BY discount_pct DESC;
/*
Central 17.65%   ← highest discount rate among regions
North   16.12%
South   16.09%
East    15.61%
West    15.31%
*/

-- Discount % by channel
SELECT
    channel,
    ROUND(100.0 * SUM(discount) / SUM(revenue), 2) AS discount_pct
FROM orders
GROUP BY channel
ORDER BY discount_pct DESC;
/*
Paid Ads        29.28%   ← nearly 5x Referral's rate
Email           22.26%
Social Media    17.49%
Organic Search   8.72%
Referral         6.58%
*/

-- Does higher discount correlate with lower profit margin?
-- Bucket every order into Low/Medium/High discount and compare avg margin
WITH order_metrics AS (
    SELECT
        ROUND(100.0 * discount / revenue, 2)    AS disc_pct,
        ROUND(100.0 * profit::NUMERIC / revenue, 2) AS margin_pct
    FROM orders
),
bucketed AS (
    SELECT *,
        CASE
            WHEN disc_pct < 10              THEN 'Low Discount (<10%)'
            WHEN disc_pct BETWEEN 10 AND 20 THEN 'Medium Discount (10–20%)'
            ELSE                                 'High Discount (>20%)'
        END AS discount_level
    FROM order_metrics
)
SELECT
    discount_level,
    COUNT(*)                        AS order_count,
    ROUND(AVG(disc_pct), 2)         AS avg_discount_pct,
    ROUND(AVG(margin_pct), 2)       AS avg_profit_margin_pct
FROM bucketed
GROUP BY discount_level
ORDER BY avg_discount_pct;
/*
Low Discount (<10%)       344 orders   avg disc  6.78%   avg margin 35.67%
Medium Discount (10–20%)  303 orders   avg disc 14.69%   avg margin 33.16%
High Discount (>20%)      353 orders   avg disc 28.07%   avg margin 23.78%

Finding: Clear inverse relationship — as discount increases,
profit margin falls. High-discount orders earn 11.89 fewer
margin points than low-discount orders (35.67% vs 23.78%).
*/


/* ============================================================
   E. CONCENTRATION RISK — REVENUE & PROFIT SHARE
   Goal: Identify whether the business is over-reliant on
         any single category, region, or channel.
   ============================================================ */

-- Revenue and profit share by category (side by side)
SELECT
    category,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(100.0 * SUM(profit)  / SUM(SUM(profit))  OVER (), 2) AS profit_share_pct
FROM orders
GROUP BY category
ORDER BY revenue_share_pct DESC;
/*
Category        Rev Share   Profit Share   Gap (profit - revenue)
Electronics      50.20%       41.87%        -8.33  ← earns less profit than its revenue share suggests
Home & Kitchen   14.94%       18.79%        +3.85  ← punches above its weight
Sports           12.15%       13.75%        +1.60
Fashion           7.84%       10.61%        +2.77  ← most efficient category
Toys              6.75%        6.42%        -0.33
Beauty            5.63%        6.27%        +0.64
Books             2.49%        2.29%        -0.20
*/

-- Revenue and profit share by region
SELECT
    region,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(100.0 * SUM(profit)  / SUM(SUM(profit))  OVER (), 2) AS profit_share_pct
FROM orders
GROUP BY region
ORDER BY revenue_share_pct DESC;
/*
Region    Rev Share   Profit Share
Central    23.78%       22.77%   ← profit share trails revenue share
North      23.01%       22.63%
East       18.13%       17.69%
South      17.68%       18.58%
West       17.40%       18.33%
*/

-- Revenue and profit share by channel
SELECT
    channel,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(100.0 * SUM(profit)  / SUM(SUM(profit))  OVER (), 2) AS profit_share_pct,
    ROUND(100.0 * SUM(discount) / SUM(revenue), 2)             AS discount_pct
FROM orders
GROUP BY channel
ORDER BY revenue_share_pct DESC;
/*
Channel         Rev Share   Profit Share   Discount    Gap
Referral         22.99%       26.74%        6.58%     +3.75  ← most efficient
Social Media     20.67%       20.58%       17.49%     -0.09  ← neutral
Organic Search   20.52%       23.40%        8.72%     +2.88
Email            16.57%       14.92%       22.26%     -1.65
Paid Ads         19.26%       14.36%       29.28%     -4.90  ← least efficient
*/


/* ============================================================
   F. LOSS & RISK ANALYSIS
   Goal: Quantify loss-making orders and identify where
         they cluster — by category, region, and channel.
   ============================================================ */

-- Loss-making order count and % of total
SELECT
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)    AS loss_orders,
    COUNT(*)                                         AS total_orders,
    ROUND(100.0 * SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS loss_order_pct
FROM orders;
-- Result: 35 loss-making orders out of 1,000 (3.50%)

-- Total ₹ loss and as % of revenue
SELECT
    SUM(revenue)                                                                    AS total_revenue,
    ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END))                           AS total_loss_amt,
    ROUND(100.0 * ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END)) / SUM(revenue), 2) AS loss_pct_of_revenue
FROM orders;
-- Result: Loss ₹1,451 on ₹35,44,282 revenue = 0.04%
-- Finding: Total loss is negligible at the business level — not a systemic issue.

-- Loss by category (absolute ₹)
WITH category_loss AS (
    SELECT
        category,
        ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END)) AS total_loss,
        RANK() OVER (ORDER BY ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END)) DESC) AS rnk
    FROM orders
    GROUP BY category
)
SELECT category, total_loss FROM category_loss WHERE rnk = 1;
-- Result: Books ₹1,027 (largest absolute loss — but still minor given Books' total revenue)

-- Loss by region (absolute ₹ and % of that region's revenue)
WITH region_loss AS (
    SELECT
        region,
        ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END))                              AS total_loss,
        ROUND(100.0 * ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END)) / SUM(revenue), 2) AS loss_pct,
        RANK() OVER (ORDER BY ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END)) DESC)  AS rnk
    FROM orders
    GROUP BY region
)
SELECT region, total_loss, loss_pct FROM region_loss WHERE rnk = 1;
-- Result: East ₹533 | 0.08% of East's revenue

-- Loss by channel
SELECT
    channel,
    ABS(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END)) AS total_loss
FROM orders
GROUP BY channel
ORDER BY total_loss DESC;
/*
Paid Ads        ₹803   ← largest loss contributor
Email           ₹294
Referral        ₹259
Organic Search   ₹94
Social Media      ₹1
*/

-- Cross-tab: which category × region combinations produce losses?
SELECT
    category,
    region,
    COUNT(*)        AS loss_orders,
    SUM(profit)     AS total_loss
FROM orders
WHERE profit < 0
GROUP BY category, region
ORDER BY total_loss;
/*
Books  | East    8 orders  -₹461
Books  | North   5 orders  -₹288
Books  | South   4 orders  -₹152
Toys   | Central 3 orders  -₹132
Books  | Central 4 orders  -₹126
...
Finding: Books across all regions is the dominant loss driver.
*/

-- Cross-tab: which category × channel combinations produce losses?
SELECT
    category,
    channel,
    COUNT(*)        AS loss_orders,
    SUM(profit)     AS total_loss
FROM orders
WHERE profit < 0
GROUP BY category, channel
ORDER BY total_loss;
/*
Books | Paid Ads  11 orders  -₹591   ← single largest loss combination
Books | Referral   5 orders  -₹238
Beauty | Email     3 orders  -₹158
Toys  | Paid Ads   2 orders  -₹127
...
*/


/* ============================================================
   G. CATEGORY DEEP DIVE — ELECTRONICS
   Goal: Diagnose why Electronics has the lowest margin
         despite generating the highest revenue and profit ₹.
   ============================================================ */

-- Electronics vs all other categories: margin gap
WITH category_margin AS (
    SELECT
        category,
        ROUND(100.0 * SUM(profit) / SUM(revenue), 2) AS profit_margin
    FROM orders
    GROUP BY category
),
electronics AS (
    SELECT profit_margin FROM category_margin WHERE category = 'Electronics'
),
others_avg AS (
    SELECT ROUND(AVG(profit_margin), 2) AS avg_margin_excl_electronics
    FROM category_margin
    WHERE category != 'Electronics'
)
SELECT
    e.profit_margin             AS electronics_margin,
    o.avg_margin_excl_electronics,
    ROUND(e.profit_margin - o.avg_margin_excl_electronics, 2) AS gap
FROM electronics e, others_avg o;
-- Result: Electronics 26.55% vs others avg 35.70% → gap of -9.15 percentage points

-- Root cause: is the margin gap driven by discount, COGS, or delivery cost?
SELECT
    category,
    ROUND(100.0 * SUM(discount)      / SUM(revenue), 2) AS discount_pct,
    ROUND(100.0 * SUM(cogs)          / SUM(revenue), 2) AS cogs_pct,
    ROUND(100.0 * SUM(delivery_cost) / SUM(revenue), 2) AS delivery_pct
FROM orders
GROUP BY category
ORDER BY cogs_pct DESC;
/*
Category        Discount%   COGS%    Delivery%
Electronics      16.29%     72.10%    1.35%   ← COGS is the outlier, not discount
Sports           17.64%     58.82%    5.16%
Toys             15.17%     59.89%    9.85%
Home & Kitchen   16.27%     55.81%    4.15%
Beauty           15.60%     52.02%   12.52%
Fashion          15.43%     48.48%    8.43%
Books            15.35%     43.83%   26.89%

Finding: Electronics' COGS is 72.1% of revenue — 12+ percentage
points above the next-highest category (Toys 59.9%). Discount
and delivery costs are actually FAVOURABLE for Electronics
(lowest delivery % of any category). The margin gap is entirely
a sourcing cost problem, not a pricing or discounting problem.
*/


/* ============================================================
   H. CATEGORY DEEP DIVE — BOOKS
   Goal: Diagnose why Books appears in loss-making orders
         more than any other category.
   ============================================================ */

-- AOV and average delivery cost per order by category
SELECT
    category,
    ROUND(SUM(revenue)::NUMERIC       / COUNT(*), 0) AS aov,
    ROUND(SUM(delivery_cost)::NUMERIC / COUNT(*), 0) AS avg_delivery_cost_per_order
FROM orders
GROUP BY category
ORDER BY aov;
/*
Category        AOV      Avg Delivery Cost
Books           ₹617          ₹165
Beauty         ₹1,295         ₹162
Toys           ₹1,650         ₹162
Fashion        ₹1,956         ₹164
Sports         ₹3,119         ₹160
Home & Kitchen ₹3,982         ₹165
Electronics   ₹12,271         ₹165

Finding: Delivery cost per order is virtually IDENTICAL across
all categories (~₹160–165). It is a flat, fixed operational cost
unrelated to product type or value. For Books (AOV ₹617), this
fixed cost represents 26.7% of order value. For Electronics
(AOV ₹12,271), the same ₹165 is only 1.3%. Books' loss
concentration is a structural AOV problem, not a logistics problem.
*/

-- Books loss rate by channel — does channel compound the problem?
SELECT
    category,
    channel,
    COUNT(*)                                                              AS total_orders,
    COUNT(*) FILTER (WHERE profit < 0)                                   AS loss_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE profit < 0) / COUNT(*), 2)     AS loss_rate_pct
FROM orders
WHERE category = 'Books'
GROUP BY category, channel
ORDER BY loss_rate_pct DESC;
/*
Books | Paid Ads        28 orders   11 losses   39.29%  ← 2 in 5 orders lose money
Books | Referral        30 orders    5 losses   16.67%
Books | Email           21 orders    2 losses    9.52%
Books | Organic Search  32 orders    2 losses    6.25%
Books | Social Media    32 orders    1 loss      3.13%

Finding: Books sold via Paid Ads loses money on 39.3% of orders —
more than double the next-highest channel. Paid Ads applies a
~29% discount on an already low-AOV product, leaving insufficient
revenue to cover the fixed ₹165 delivery cost. This is the single
most actionable loss-reduction opportunity in the dataset.
*/


/* ============================================================
   I. CHANNEL DEEP DIVE — PAID ADS
   Goal: Confirm whether Paid Ads is genuinely inefficient
         and quantify the cost of its discount strategy.
   ============================================================ */

-- Paid Ads: potential profit gain if discount rate reduced to 15%
WITH paid_ads_metrics AS (
    SELECT
        channel,
        SUM(revenue)                                            AS total_revenue,
        SUM(discount)                                           AS total_discount,
        ROUND(100.0 * SUM(discount) / SUM(revenue), 2)         AS current_discount_pct,
        ROUND(SUM(revenue) * 0.15, 0)                          AS hypothetical_discount_at_15pct,
        ROUND(SUM(discount) - (SUM(revenue) * 0.15), 0)        AS potential_profit_gain
    FROM orders
    WHERE channel = 'Paid Ads'
    GROUP BY channel
)
SELECT * FROM paid_ads_metrics;
/*
channel    total_revenue   total_discount   current_discount_pct   hypothetical_at_15pct   potential_profit_gain
Paid Ads   ₹6,82,501       ₹1,99,846        29.28%                  ₹1,02,375               ₹97,471

Finding: Paid Ads currently spends ₹1,99,846 on discounts against
₹6,82,501 in revenue. If discount rate were reduced from 29.28% to
15% (in line with Social Media's rate), the business would save
₹97,471 in discount spend — equivalent to recovering ~8.6% of
current Paid Ads revenue as additional profit.

Note: This assumes order volume holds steady at a lower discount
rate — which cannot be confirmed from this dataset alone. A/B
testing on a subset of Paid Ads spend is recommended before any
broad rollout.
*/


/* ============================================================
   J. REGIONAL DEEP DIVE
   Goal: Compare regions by revenue rank vs margin rank —
         the highest-revenue region is not always the most
         efficient.
   ============================================================ */

-- Revenue rank vs margin rank by region
WITH region_metrics AS (
    SELECT
        region,
        SUM(revenue)                                                AS total_revenue,
        ROUND(100.0 * SUM(profit) / SUM(revenue), 2)               AS margin_pct,
        RANK() OVER (ORDER BY SUM(revenue) DESC)                    AS revenue_rank,
        RANK() OVER (ORDER BY ROUND(100.0*SUM(profit)/SUM(revenue),2) DESC) AS margin_rank
    FROM orders
    GROUP BY region
)
SELECT
    region,
    total_revenue,
    margin_pct,
    revenue_rank,
    margin_rank
FROM region_metrics
ORDER BY revenue_rank;
/*
Region    Revenue        Margin    Rev Rank   Margin Rank
Central   ₹8,42,722     30.48%       1           5  ← highest revenue, LOWEST margin
North     ₹8,15,669     31.30%       2           3
East      ₹6,42,506     31.07%       3           4
South     ₹6,26,109     33.45%       4           2
West      ₹6,17,298     33.54%       5           1  ← lowest revenue, HIGHEST margin

Finding: Central and West are direct opposites. Central generates
the most revenue but is the least efficient at converting it to
profit. West generates the least revenue but has the best margin.
Delivery cost does NOT explain this — Central's delivery cost is
mid-range, not the highest. Central's 17.65% discount rate (the
highest of any region) is the more likely driver.
*/

-- Delivery cost vs margin by region (to test/rule out logistics hypothesis)
SELECT
    region,
    SUM(delivery_cost)                                  AS total_delivery_cost,
    ROUND(100.0 * SUM(profit) / SUM(revenue), 2)        AS profit_margin_pct,
    ROUND(100.0 * SUM(discount) / SUM(revenue), 2)      AS discount_pct
FROM orders
GROUP BY region
ORDER BY profit_margin_pct DESC;
/*
West    ₹27,331   33.54%   15.31%
South   ₹26,549   33.45%   16.09%
North   ₹35,477   31.30%   16.12%
East    ₹39,779   31.07%   15.61%
Central ₹34,728   30.48%   17.65%

Finding: East has the highest delivery cost but is not the worst
margin region. Central has the worst margin despite mid-range
delivery costs — confirmed to be driven by its highest discount
rate (17.65%) rather than logistics.
*/


/* ============================================================
   K. TIME TREND ANALYSIS
   Goal: Identify month-over-month patterns in revenue,
         order volume, AOV, and margin.
   ============================================================ */

-- Monthly trend: orders, revenue, profit, margin
SELECT
    DATE_TRUNC('month', order_date)                     AS month,
    COUNT(*)                                            AS order_count,
    SUM(revenue)                                        AS total_revenue,
    SUM(profit)                                         AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(revenue), 2)        AS margin_pct
FROM orders
GROUP BY month
ORDER BY month;
/*
Nov 2024   166 orders   ₹6,28,679   ₹2,01,941   32.12%
Dec 2024   159 orders   ₹4,89,788   ₹1,62,412   33.16%  ← revenue drop, highest margin
Jan 2025   173 orders   ₹6,29,880   ₹1,95,303   31.01%
Feb 2025   154 orders   ₹5,62,429   ₹1,75,142   31.14%  ← lowest order count
Mar 2025   167 orders   ₹6,21,774   ₹2,00,711   32.28%
Apr 2025   181 orders   ₹6,11,732   ₹1,92,807   31.52%
*/

-- Monthly AOV trend — to diagnose December's revenue drop
SELECT
    DATE_TRUNC('month', order_date)                     AS month,
    COUNT(*)                                            AS order_count,
    SUM(revenue)                                        AS total_revenue,
    ROUND(SUM(revenue)::NUMERIC / COUNT(*), 2)          AS aov
FROM orders
GROUP BY month
ORDER BY month;
/*
Nov 2024   166   ₹6,28,679   ₹3,787
Dec 2024   159   ₹4,89,788   ₹3,080  ← lowest AOV of any month
Jan 2025   173   ₹6,29,880   ₹3,641
Feb 2025   154   ₹5,62,429   ₹3,652
Mar 2025   167   ₹6,21,774   ₹3,723
Apr 2025   181   ₹6,11,732   ₹3,380

Finding: December's revenue drop is not explained by fewer orders
alone (159 vs normal ~165–173) — AOV also fell to ₹3,080, well
below the typical ₹3,600–3,800 range. Category mix explains this.
*/

-- December category breakdown — to explain the AOV and margin anomaly
SELECT
    category,
    COUNT(*)                                                AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)     AS pct_of_dec_orders,
    SUM(revenue)                                            AS revenue
FROM orders
WHERE DATE_TRUNC('month', order_date) = '2024-12-01'
GROUP BY category
ORDER BY revenue DESC;
/*
Category        Orders   % of Dec   Revenue
Electronics       18      11.32%   ₹2,04,255  ← below typical ~14.5% share
Home & Kitchen    23      14.47%     ₹85,852
Sports            24      15.09%     ₹73,709
Toys              29      18.24%     ₹48,415  ← above typical ~14.5% share
Fashion           21      13.21%     ₹39,302
Beauty            17      10.69%     ₹23,227
Books             27      16.98%     ₹15,028  ← above typical ~14.3% share

Finding: In December, Electronics' share of orders fell from its
typical 14.5% to 11.3%, while Toys (18.2%) and Books (17.0%)
rose above their normal shares. Since Electronics has the highest
AOV (₹12,271) and Toys/Books have the lowest AOVs (₹1,650/₹617),
this category mix shift simultaneously pulled blended AOV down
(fewer expensive items) and pushed margin up (fewer low-margin
Electronics orders). Whether this reflects seasonal gift-buying
behavior cannot be confirmed from 6 months of data alone.
*/
