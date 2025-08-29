-- RQ1: Do demographic characteristics drive differences in e-commerce consumption patterns?
-- Ecom aggregation: State x Year x Month x category
DROP VIEW IF EXISTS ecom_agg;

CREATE VIEW ecom_agg AS
SELECT 
    customer_state AS state_name,
    CAST(strftime('%Y', order_date) AS INT) AS year,
    CAST(strftime('%m', order_date) AS INT) AS month,
    category_name as category,
    SUM(sales_per_order)   AS total_sales,
    SUM(profit_per_order)  AS total_profit,
    SUM(order_quantity)    AS total_quantity
FROM ecommerce
GROUP BY state_name, year, month, category;

-- Demo aggregation:  State x Year x Month
DROP VIEW IF EXISTS demo_agg;

CREATE VIEW demo_agg AS
SELECT
    CAST(YEAR AS INT)  AS year,
    CAST(MONTH AS INT) AS month,
    state_name,

    -- Total_weight
    SUM(HWTFINL) AS total_weight,

    -- Average ages
    SUM(HWTFINL * AGE) * 1.0 / SUM(HWTFINL) AS avg_age,

    -- Eduction
    SUM(CASE WHEN EDUC IN ('Undergraduate','Graduate and above') THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_undergraduate_plus,
    SUM(CASE WHEN EDUC = 'Undergraduate' THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_undergraduate,
    SUM(CASE WHEN EDUC = 'Graduate and above' THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_graduate_plus,

    -- Employment
    SUM(CASE WHEN EMPSTAT = 'At work' THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_employed,
    SUM(CASE WHEN EMPSTAT = 'Unemployed' THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_unemployed,

    -- Gender
    SUM(CASE WHEN SEX = 'Male' THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_male,

    -- Citizen
    SUM(CASE WHEN CITIZEN IN ('Born in U.S','Born in U.S. outlying','Born abroad of American parents','Naturalized citizen') 
             THEN HWTFINL ELSE 0 END) * 1.0 / SUM(HWTFINL) AS share_citizen
FROM demography
GROUP BY year, month, state_name;

-- Panel Data with Differences (for RQ1)
DROP VIEW IF EXISTS panel_rq1;

CREATE VIEW panel_rq1 AS
SELECT
    e.year,
    e.month,
    e.state_name,
    e.total_sales,
    e.total_profit,
    e.total_quantity,
	e.category,
    d.avg_age,
    d.share_undergraduate_plus,
    d.share_undergraduate,
    d.share_graduate_plus,
    d.share_employed,
    d.share_unemployed,
    d.share_male,
    d.share_citizen
FROM ecom_agg e
LEFT JOIN demo_agg d
  ON e.year = d.year
 AND e.month = d.month
 AND e.state_name = d.state_name;
 
-- Analytics RQ1_1: Raw correlation by category
DROP VIEW IF EXISTS rq1_corr_by_category;
CREATE VIEW rq1_corr_by_category AS
WITH base AS (
  SELECT category, total_sales,
         avg_age, share_undergraduate_plus, share_employed, share_unemployed, share_male, share_citizen
  FROM panel_rq1
  WHERE total_sales IS NOT NULL
)
SELECT
  category,
  -- Pearson correlation coefficient, calculated manually based on the covariance formula
  'avg_age'                AS var, (COUNT(*)*SUM(avg_age*total_sales)-SUM(avg_age)*SUM(total_sales)) * 1.0 /
                                   (SQRT((COUNT(*)*SUM(avg_age*avg_age)-SUM(avg_age)*SUM(avg_age)) *
                                         (COUNT(*)*SUM(total_sales*total_sales)-SUM(total_sales)*SUM(total_sales)))) AS r
FROM base
GROUP BY category
UNION ALL
SELECT category,'share_undergraduate_plus',
       (COUNT(*)*SUM(share_undergraduate_plus*total_sales)-SUM(share_undergraduate_plus)*SUM(total_sales)) * 1.0 /
       (SQRT((COUNT(*)*SUM(share_undergraduate_plus*share_undergraduate_plus)-SUM(share_undergraduate_plus)*SUM(share_undergraduate_plus)) *
             (COUNT(*)*SUM(total_sales*total_sales)-SUM(total_sales)*SUM(total_sales)))) AS r
FROM base GROUP BY category
UNION ALL
SELECT category,'share_employed',
       (COUNT(*)*SUM(share_employed*total_sales)-SUM(share_employed)*SUM(total_sales)) * 1.0 /
       (SQRT((COUNT(*)*SUM(share_employed*share_employed)-SUM(share_employed)*SUM(share_employed)) *
             (COUNT(*)*SUM(total_sales*total_sales)-SUM(total_sales)*SUM(total_sales)))) AS r
FROM base GROUP BY category
UNION ALL
SELECT category,'share_unemployed',
       (COUNT(*)*SUM(share_unemployed*total_sales)-SUM(share_unemployed)*SUM(total_sales)) * 1.0 /
       (SQRT((COUNT(*)*SUM(share_unemployed*share_unemployed)-SUM(share_unemployed)*SUM(share_unemployed)) *
             (COUNT(*)*SUM(total_sales*total_sales)-SUM(total_sales)*SUM(total_sales)))) AS r
FROM base GROUP BY category
UNION ALL
SELECT category,'share_male',
       (COUNT(*)*SUM(share_male*total_sales)-SUM(share_male)*SUM(total_sales)) * 1.0 /
       (SQRT((COUNT(*)*SUM(share_male*share_male)-SUM(share_male)*SUM(share_male)) *
             (COUNT(*)*SUM(total_sales*total_sales)-SUM(total_sales)*SUM(total_sales)))) AS r
FROM base GROUP BY category
UNION ALL
SELECT category,'share_citizen',
       (COUNT(*)*SUM(share_citizen*total_sales)-SUM(share_citizen)*SUM(total_sales)) * 1.0 /
       (SQRT((COUNT(*)*SUM(share_citizen*share_citizen)-SUM(share_citizen)*SUM(share_citizen)) *
             (COUNT(*)*SUM(total_sales*total_sales)-SUM(total_sales)*SUM(total_sales)))) AS r
FROM base GROUP BY category
ORDER BY category, var;

-- Analytics RQ1_2: TWFE-adjusted correlation (controlling for state and month fixed effects)
DROP VIEW IF EXISTS rq1_twfe_corr;
CREATE VIEW rq1_twfe_corr AS
WITH b AS (
  SELECT * FROM panel_rq1 WHERE total_sales IS NOT NULL
),
by_state AS (
  SELECT state_name, AVG(total_sales) AS s_mean FROM b GROUP BY state_name
),
by_time AS (
  SELECT year, month, AVG(total_sales) AS t_mean FROM b GROUP BY year, month
),
demean AS (
  SELECT
    b.category, b.state_name, b.year, b.month,
    (b.total_sales - s.s_mean - t.t_mean + (SELECT AVG(total_sales) FROM b)) AS y_dm,
    (b.avg_age - AVG(b.avg_age) OVER (PARTITION BY b.state_name) - AVG(b.avg_age) OVER (PARTITION BY b.year,b.month)
      + AVG(b.avg_age) OVER ()) AS x_age_dm,
    (b.share_undergraduate_plus - AVG(b.share_undergraduate_plus) OVER (PARTITION BY b.state_name)
      - AVG(b.share_undergraduate_plus) OVER (PARTITION BY b.year,b.month) + AVG(b.share_undergraduate_plus) OVER ()) AS x_edu_dm
  FROM b b
  JOIN by_state s ON s.state_name=b.state_name
  JOIN by_time  t ON t.year=b.year AND t.month=b.month
)
SELECT
  category,
  'avg_age' AS var,
  (COUNT(*)*SUM(x_age_dm*y_dm)-SUM(x_age_dm)*SUM(y_dm)) * 1.0 /
  (SQRT((COUNT(*)*SUM(x_age_dm*x_age_dm)-SUM(x_age_dm)*SUM(x_age_dm)) *
        (COUNT(*)*SUM(y_dm*y_dm)-SUM(y_dm)*SUM(y_dm)))) AS r_dm
FROM demean
GROUP BY category
UNION ALL
SELECT
  category,
  'share_undergraduate_plus',
  (COUNT(*)*SUM(x_edu_dm*y_dm)-SUM(x_edu_dm)*SUM(y_dm)) * 1.0 /
  (SQRT((COUNT(*)*SUM(x_edu_dm*x_edu_dm)-SUM(x_edu_dm)*SUM(x_edu_dm)) *
        (COUNT(*)*SUM(y_dm*y_dm)-SUM(y_dm)*SUM(y_dm)))) AS r_dm
FROM demean
GROUP BY category
ORDER BY category, var;

-- RQ2: Is there a structural relationship between changes in educational attainment and consumption of high-value categories (Technology)?
-- 1). Education × Category Interactions & Category Dummy Variables
DROP VIEW IF EXISTS panel_rq2;

CREATE VIEW panel_rq2 AS
SELECT
  e.year,
  e.month,
  e.state_name,
  e.category,

  -- Dependent variables (choose the one need for analysis from ecom_agg)
  e.total_sales,
  e.total_profit,
  e.total_quantity,

  -- Education and control variables (from demo_agg)
  d.share_undergraduate_plus,
  d.share_undergraduate,
  d.share_graduate_plus,
  d.share_employed,
  d.share_unemployed,
  d.avg_age,
  d.share_male,
  d.share_citizen,

  -- Category dummy variables
  CASE WHEN e.category='Technology'      THEN 1 ELSE 0 END AS is_tech,
  CASE WHEN e.category='Furniture'       THEN 1 ELSE 0 END AS is_furniture,
  CASE WHEN e.category='Office Supplies' THEN 1 ELSE 0 END AS is_office,

  -- Interaction terms: Education (Undergraduate+) × Category
  CASE WHEN e.category='Technology'      THEN d.share_undergraduate_plus ELSE 0 END AS edu_up_x_tech,
  CASE WHEN e.category='Furniture'       THEN d.share_undergraduate_plus ELSE 0 END AS edu_up_x_furn,
  CASE WHEN e.category='Office Supplies' THEN d.share_undergraduate_plus ELSE 0 END AS edu_up_x_office

FROM ecom_agg e
LEFT JOIN demo_agg d
  ON d.year = e.year
 AND d.month = e.month
 AND d.state_name = e.state_name;
 
-- 2). First Differences: Sales & Education
DROP VIEW IF EXISTS panel_rq2_diff;

CREATE VIEW panel_rq2_diff AS
WITH base AS (
  SELECT
    e.year,
    e.month,
    e.state_name,
    e.category,
    e.total_sales,
    d.share_undergraduate_plus
  FROM ecom_agg e
  LEFT JOIN demo_agg d
    ON d.year = e.year AND d.month = e.month AND d.state_name = e.state_name
),
lagged AS (
  SELECT
    *,
    -- One-month lag of sales by state × category
    LAG(total_sales, 1) OVER (
      PARTITION BY state_name, category 
      ORDER BY year, month
    ) AS sales_lag1,

    -- One-month lag of education share by state
    LAG(share_undergraduate_plus, 1) OVER (
      PARTITION BY state_name 
      ORDER BY year, month
    ) AS edu_up_lag1
  FROM base
)
SELECT
  *,
  -- First difference of sales and education
  (total_sales - sales_lag1)               AS d_sales_m1,
  (share_undergraduate_plus - edu_up_lag1) AS d_edu_up_m1,

  -- Tech dummy for clustering or filtering
  CASE WHEN category='Technology' THEN 1 ELSE 0 END AS is_tech
FROM lagged;

-- 3). State-level Clustering Features: Technology Sales Share & Smoothing Metrics
DROP VIEW IF EXISTS state_cluster_rq2;

CREATE VIEW state_cluster_rq2 AS
WITH sales_mix AS (
  -- Technology sales share by state × month
  SELECT
    e.year, e.month, e.state_name,
    SUM(CASE WHEN e.category = 'Technology' THEN e.total_sales ELSE 0 END) * 1.0 /
    NULLIF(SUM(e.total_sales), 0) AS tech_sales_share
  FROM ecom_agg e
  GROUP BY e.year, e.month, e.state_name
),
sales_mix_lag AS (
  SELECT
    *,
    -- Lagged technology sales share
    LAG(tech_sales_share, 1) OVER (
      PARTITION BY state_name
      ORDER BY year, month
    ) AS tech_share_lag1
  FROM sales_mix
),
edu_series AS (
  SELECT year, month, state_name, share_undergraduate_plus
  FROM demo_agg
),
edu_lag AS (
  SELECT
    *,
    -- Lagged education share
    LAG(share_undergraduate_plus, 1) OVER (
      PARTITION BY state_name
      ORDER BY year, month
    ) AS edu_up_lag1
  FROM edu_series
)
SELECT
  s.state_name,
  -- Average level & month-to-month volatility of Tech share
  AVG(s.tech_sales_share)                          AS tech_share_mean,
  AVG(ABS(s.tech_sales_share - s.tech_share_lag1)) AS tech_share_mae,
  -- Education level and average first-difference
  AVG(e.share_undergraduate_plus)                  AS edu_up_mean,
  AVG(e.share_undergraduate_plus - e.edu_up_lag1)  AS edu_up_d1_mean
FROM sales_mix_lag s
JOIN edu_lag e
  ON e.state_name = s.state_name
 AND e.year       = s.year
 AND e.month      = s.month
GROUP BY s.state_name;

-- RQ3: Are nationwide demographic trends consistent with YouTube video preference trends?
-- 1). Nationwide demographic trends: month, weighted (from demo_agg)
-- national weighted monthly demographics
DROP VIEW IF EXISTS demo_trend;

CREATE VIEW demo_trend AS
SELECT
  CAST(year AS INT)  AS year,
  CAST(month AS INT) AS month,

  SUM(total_weight) AS us_total_weight,

  -- weighted avg
  SUM(total_weight * avg_age)                * 1.0 / NULLIF(SUM(total_weight),0) AS us_avg_age,
  SUM(total_weight * share_undergraduate_plus) * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_undergraduate_plus,
  SUM(total_weight * share_undergraduate)      * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_undergraduate,
  SUM(total_weight * share_graduate_plus)      * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_graduate_plus,
  SUM(total_weight * share_employed)           * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_employed,
  SUM(total_weight * share_unemployed)         * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_unemployed,
  SUM(total_weight * share_male)               * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_male,
  SUM(total_weight * share_citizen)            * 1.0 / NULLIF(SUM(total_weight),0) AS us_share_citizen
FROM demo_agg
GROUP BY year, month
ORDER BY year, month;

-- 2). Map YouTube categories into 3 groups
DROP VIEW IF EXISTS youtube_mapped;

CREATE VIEW youtube_mapped AS
SELECT
  CAST(strftime('%Y', trending_date) AS INT)  AS year,
  CAST(strftime('%m', trending_date) AS INT)  AS month,
  CASE
    WHEN categoryId IN ('Entertainment','Film & Animation','People & Blogs','Comedy','Movies') THEN 'Entertainment'
    WHEN categoryId IN ('Gaming') THEN 'Gaming'
    WHEN categoryId IN ('Science & Technology','Technology') THEN 'Technology'
    ELSE 'Other'
  END AS std_category,
  COALESCE(view_count,0)    AS views,
  COALESCE(likes,0)         AS likes,
  COALESCE(comment_count,0) AS comments,
  1 AS videos,  --count every row as 1
  (COALESCE(view_count,0) + COALESCE(likes,0) + COALESCE(comment_count,0)) AS engagement
FROM youtube;

-- 3). Monthly aggregation by category
DROP VIEW IF EXISTS youtube_monthly;

CREATE VIEW youtube_monthly AS
SELECT
  year, month, std_category,
  SUM(views)      AS views,
  SUM(likes)      AS likes,
  SUM(comments)   AS comments,
  COUNT(videos)   AS videos,
  SUM(engagement) AS eng
FROM youtube_mapped
GROUP BY year, month, std_category;

-- 4). Restrict to 3 target categories and compute shares
DROP VIEW IF EXISTS youtube_trend;

CREATE VIEW youtube_trend AS
WITH three AS (
  SELECT year, month,
         SUM(CASE WHEN std_category='Entertainment' THEN eng ELSE 0 END) AS eng_entertainment,
         SUM(CASE WHEN std_category='Gaming'       THEN eng ELSE 0 END) AS eng_gaming,
         SUM(CASE WHEN std_category='Technology'   THEN eng ELSE 0 END) AS eng_technology,
         SUM(CASE WHEN std_category='Entertainment' THEN views ELSE 0 END) AS views_entertainment,
         SUM(CASE WHEN std_category='Gaming'       THEN views ELSE 0 END) AS views_gaming,
         SUM(CASE WHEN std_category='Technology'   THEN views ELSE 0 END) AS views_technology,
         SUM(CASE WHEN std_category='Entertainment' THEN likes ELSE 0 END) AS likes_entertainment,
         SUM(CASE WHEN std_category='Gaming'       THEN likes ELSE 0 END) AS likes_gaming,
         SUM(CASE WHEN std_category='Technology'   THEN likes ELSE 0 END) AS likes_technology,
         SUM(CASE WHEN std_category='Entertainment' THEN comments ELSE 0 END) AS comments_entertainment,
         SUM(CASE WHEN std_category='Gaming'       THEN comments ELSE 0 END) AS comments_gaming,
         SUM(CASE WHEN std_category='Technology'   THEN comments ELSE 0 END) AS comments_technology,
         SUM(CASE WHEN std_category='Entertainment' THEN videos ELSE 0 END) AS videos_entertainment,
         SUM(CASE WHEN std_category='Gaming'       THEN videos ELSE 0 END) AS videos_gaming,
         SUM(CASE WHEN std_category='Technology'   THEN videos ELSE 0 END) AS videos_technology
  FROM youtube_monthly
  WHERE std_category IN ('Entertainment','Gaming','Technology')
  GROUP BY year, month
)
SELECT
  year, month,
  eng_entertainment, eng_gaming, eng_technology,
  eng_entertainment * 1.0 / NULLIF(eng_entertainment + eng_gaming + eng_technology, 0) AS us_share_entertainment,
  eng_gaming       * 1.0 / NULLIF(eng_entertainment + eng_gaming + eng_technology, 0) AS us_share_gaming,
  eng_technology   * 1.0 / NULLIF(eng_entertainment + eng_gaming + eng_technology, 0) AS us_share_technology,
  views_entertainment, views_gaming, views_technology,
  likes_entertainment, likes_gaming, likes_technology,
  comments_entertainment, comments_gaming, comments_technology,
  videos_entertainment,   videos_gaming,   videos_technology
FROM three
ORDER BY year, month;

-- 5). Final panel for RQ3
DROP VIEW IF EXISTS panel_rq3;

CREATE VIEW panel_rq3 AS
SELECT
  d.year, d.month,
  d.us_total_weight, d.us_avg_age,
  d.us_share_undergraduate_plus, d.us_share_employed, d.us_share_male,
  y.us_share_entertainment, y.us_share_gaming, y.us_share_technology,
  y.eng_entertainment, y.eng_gaming, y.eng_technology
FROM demo_trend d
JOIN youtube_trend y
  ON y.year  = d.year
 AND y.month = d.month
ORDER BY d.year, d.month;

--RQ4: Can YouTube trending videos predict e-commerce consumption trends?
-- 1). Base panel (monthly national): YT shares + E-com sales (pivoted)
DROP VIEW IF EXISTS panel_rq4;

CREATE VIEW panel_rq4 AS
SELECT
  y.year,
  y.month,

  -- YouTube category shares (relative among tracked cats)
  y.us_share_entertainment,
  y.us_share_gaming,
  y.us_share_technology,

  -- Absolute engagement (optional controls)
  y.eng_entertainment,
  y.eng_gaming,
  y.eng_technology,

  -- E-commerce sales by headline categories (pivoted)
  e.ec_technology,
  e.ec_furniture,
  e.ec_office
FROM youtube_trend y
JOIN (
  SELECT
    year, month,
    SUM(CASE WHEN category = 'Technology'       THEN total_sales ELSE 0 END) AS ec_technology,
    SUM(CASE WHEN category = 'Furniture'        THEN total_sales ELSE 0 END) AS ec_furniture,
    SUM(CASE WHEN category = 'Office Supplies'  THEN total_sales ELSE 0 END) AS ec_office
  FROM ecom_agg
  GROUP BY year, month
) e USING (year, month)
ORDER BY year, month;

-- 2). Add 1–3 month lags and first differences (Δ)
DROP VIEW IF EXISTS panel_rq4_diff;

CREATE VIEW panel_rq4_diff AS
WITH lagged AS (
  SELECT
    p.*,

    -- Lags of YouTube shares
    LAG(us_share_entertainment,1) OVER (ORDER BY year,month) AS ent_lag1,
    LAG(us_share_entertainment,2) OVER (ORDER BY year,month) AS ent_lag2,
    LAG(us_share_entertainment,3) OVER (ORDER BY year,month) AS ent_lag3,

    LAG(us_share_gaming,1) OVER (ORDER BY year,month) AS gam_lag1,
    LAG(us_share_gaming,2) OVER (ORDER BY year,month) AS gam_lag2,
    LAG(us_share_gaming,3) OVER (ORDER BY year,month) AS gam_lag3,

    LAG(us_share_technology,1) OVER (ORDER BY year,month) AS tech_lag1,
    LAG(us_share_technology,2) OVER (ORDER BY year,month) AS tech_lag2,
    LAG(us_share_technology,3) OVER (ORDER BY year,month) AS tech_lag3,

    -- Lags of E-com sales
    LAG(ec_technology,1) OVER (ORDER BY year,month) AS ec_tech_lag1,
    LAG(ec_furniture,1)  OVER (ORDER BY year,month) AS ec_furn_lag1,
    LAG(ec_office,1)     OVER (ORDER BY year,month) AS ec_office_lag1
  FROM panel_rq4 p
)
SELECT
  year, month,

  -- Δ E-com sales (t – t-1)
  (ec_technology - ec_tech_lag1)   AS d_ec_technology,
  (ec_furniture  - ec_furn_lag1)   AS d_ec_furniture,
  (ec_office     - ec_office_lag1) AS d_ec_office,

  -- Δ YT shares (t – t-1)
  (us_share_entertainment - ent_lag1) AS d_ent_share,
  (us_share_gaming        - gam_lag1) AS d_gam_share,
  (us_share_technology    - tech_lag1) AS d_tech_share,

  -- Keep lagged YT share diffs for lead–lag checks
  LAG((us_share_entertainment - ent_lag1),1) OVER (ORDER BY year,month) AS d_ent_lag1,
  LAG((us_share_gaming - gam_lag1),1) OVER (ORDER BY year,month) AS d_gam_lag1,
  LAG((us_share_technology - tech_lag1),1) OVER (ORDER BY year,month) AS d_tech_lag1,

  LAG((us_share_entertainment - ent_lag1),2) OVER (ORDER BY year,month) AS d_ent_lag2,
  LAG((us_share_gaming - gam_lag1),2) OVER (ORDER BY year,month) AS d_gam_lag2,
  LAG((us_share_technology - tech_lag1),2) OVER (ORDER BY year,month) AS d_tech_lag2,

  LAG((us_share_entertainment - ent_lag1),3) OVER (ORDER BY year,month) AS d_ent_lag3,
  LAG((us_share_gaming - gam_lag1),3) OVER (ORDER BY year,month) AS d_gam_lag3,
  LAG((us_share_technology - tech_lag1),3) OVER (ORDER BY year,month) AS d_tech_lag3
FROM lagged
WHERE ent_lag1 IS NOT NULL
  AND ec_tech_lag1 IS NOT NULL
  AND ec_furn_lag1 IS NOT NULL
  AND ec_office_lag1 IS NOT NULL;
  
-- 3). SQL-only lead–lag summary: correlate ΔEC with lagged ΔYT shares
DROP VIEW IF EXISTS state_cluster_rq4;

CREATE VIEW state_cluster_rq4 AS
WITH pairs AS (
  -- Map categories to likely YT drivers (edit if needed)
  SELECT 'Technology' AS cat, 1 AS lag, d_ec_technology AS y, d_tech_lag1 AS x FROM panel_rq4_diff
  UNION ALL SELECT 'Technology', 2, d_ec_technology, d_tech_lag2 FROM panel_rq4_diff
  UNION ALL SELECT 'Technology', 3, d_ec_technology, d_tech_lag3 FROM panel_rq4_diff

  UNION ALL SELECT 'Furniture',  1, d_ec_furniture,  d_ent_lag1 FROM panel_rq4_diff
  UNION ALL SELECT 'Furniture',  2, d_ec_furniture,  d_ent_lag2 FROM panel_rq4_diff
  UNION ALL SELECT 'Furniture',  3, d_ec_furniture,  d_ent_lag3 FROM panel_rq4_diff

  UNION ALL SELECT 'Office Supplies', 1, d_ec_office, d_gam_lag1 FROM panel_rq4_diff
  UNION ALL SELECT 'Office Supplies', 2, d_ec_office, d_gam_lag2 FROM panel_rq4_diff
  UNION ALL SELECT 'Office Supplies', 3, d_ec_office, d_gam_lag3 FROM panel_rq4_diff
),
clean AS (
  SELECT cat, lag, x, y FROM pairs WHERE x IS NOT NULL AND y IS NOT NULL
),
stats AS (
  SELECT
    cat, lag,
    COUNT(*) AS n,
    SUM(x)   AS sx,  SUM(y) AS sy,
    SUM(x*x) AS sxx, SUM(y*y) AS syy,
    SUM(x*y) AS sxy
  FROM clean
  GROUP BY cat, lag
)
SELECT
  cat,
  lag,
  n,
  -- Pearson r
  (n*sxy - sx*sy) * 1.0 /
  (SQRT( (n*sxx - sx*sx) * (n*syy - sy*sy) )) AS r,
  -- Approx significance flag (|t|≈≥2)
  CASE
    WHEN n > 2 THEN
      CASE WHEN ABS( ((n*sxy - sx*sy) * 1.0 /
                      (SQRT( (n*sxx - sx*sx) * (n*syy - sy*sy) ))) *
                     SQRT( (n-2) * 1.0 /
                           (1 - POWER( (n*sxy - sx*sy) * 1.0 /
                                       (SQRT( (n*sxx - sx*sx) * (n*syy - sy*sy) )), 2) ) )
                   ) >= 2
           THEN 1 ELSE 0 END
  END AS signif_approx
FROM stats
ORDER BY cat, lag;

-- RQ5:Does the demographic sensitivity of consumption behavior differ significantly across product categories?
-- 1). Panel: state × month × category + demographics
DROP VIEW IF EXISTS panel_rq5;

CREATE VIEW panel_rq5 AS
SELECT
  e.year,
  e.month,
  e.state_name,
  e.category,

  -- Outcomes
  e.total_sales,
  e.total_profit,
  e.total_quantity,

  -- Demographics (shares in 0–1)
  d.avg_age,
  d.share_undergraduate_plus,
  d.share_employed,
  d.share_unemployed,
  d.share_male,
  d.share_citizen
FROM ecom_agg e
LEFT JOIN demo_agg d
  ON d.year  = e.year
 AND d.month = e.month
 AND d.state_name = e.state_name;
 
 
-- 2). Log transforms for elasticity-style analysis
DROP VIEW IF EXISTS panel_rq5_log;

CREATE VIEW panel_rq5_log AS
SELECT
  *,
  ln(total_sales + 1.0) AS ln_sales,
  ln(total_quantity + 1.0) AS ln_qty,
  ln(NULLIF(avg_age,0)) AS ln_age,
  ln(NULLIF(share_undergraduate_plus,0) + 1e-6) AS ln_edu_up,
  ln(NULLIF(share_employed,0) + 1e-6) AS ln_emp,
  ln(NULLIF(share_unemployed,0) + 1e-6) AS ln_unemp,
  ln(COALESCE(share_male,0.5)) AS ln_male,
  ln(COALESCE(share_citizen,0.9)) AS ln_citizen
FROM panel_rq5;

-- 3). Category-level elasticities: ln_sales ~ ln_edu_up and ln_sales ~ ln_emp (per category)
-- A) Elasticity wrt Education (Undergraduate+)
DROP VIEW IF EXISTS rq5_elasticity_edu;

CREATE VIEW rq5_elasticity_edu AS
WITH base AS (
  SELECT category, ln_sales AS y, ln_edu_up AS x
  FROM panel_rq5_log
  WHERE ln_sales IS NOT NULL AND ln_edu_up IS NOT NULL
),
grp AS (
  SELECT
    category,
    COUNT(*) AS n,
    SUM(x) AS sx, SUM(y) AS sy,
    SUM(x*x) AS sxx, SUM(y*y) AS syy,
    SUM(x*y) AS sxy
  FROM base
  GROUP BY category
),
rstat AS (
  SELECT
    category, n, sx, sy, sxx, syy, sxy,
    (n*sxy - sx*sy) * 1.0 /
    (SQRT( (n*sxx - sx*sx) * (n*syy - sy*sy) )) AS r
  FROM grp
)
SELECT
  category,
  n,
  r,
  -- slope (elasticity) = r * (sd_y / sd_x)
  r * ( SQRT( (n*syy - sy*sy)*1.0 ) / SQRT(n) ) /
      ( SQRT( (n*sxx - sx*sx)*1.0 ) / SQRT(n) ) AS elasticity,
  -- approx t-stat for r (df=n-2)
  CASE WHEN n>2 THEN r * SQRT( (n-2) * 1.0 / (1 - r*r) ) END AS t_stat,
  CASE WHEN n>2 AND ABS(r * SQRT( (n-2) * 1.0 / (1 - r*r) )) >= 2 THEN 1 ELSE 0 END AS signif_approx
FROM rstat
ORDER BY category;

-- B) Elasticity wrt Employment
DROP VIEW IF EXISTS rq5_elasticity_emp;

CREATE VIEW rq5_elasticity_emp AS
WITH base AS (
  SELECT category, ln_sales AS y, ln_emp AS x
  FROM panel_rq5_log
  WHERE ln_sales IS NOT NULL AND ln_emp IS NOT NULL
),
grp AS (
  SELECT
    category,
    COUNT(*) AS n,
    SUM(x) AS sx, SUM(y) AS sy,
    SUM(x*x) AS sxx, SUM(y*y) AS syy,
    SUM(x*y) AS sxy
  FROM base
  GROUP BY category
),
rstat AS (
  SELECT
    category, n, sx, sy, sxx, syy, sxy,
    (n*sxy - sx*sy) * 1.0 /
    (SQRT( (n*sxx - sx*sx) * (n*syy - sy*sy) )) AS r
  FROM grp
)
SELECT
  category,
  n,
  r,
  r * ( SQRT( (n*syy - sy*sy)*1.0 ) / SQRT(n) ) /
      ( SQRT( (n*sxx - sx*sx)*1.0 ) / SQRT(n) ) AS elasticity,
  CASE WHEN n>2 THEN r * SQRT( (n-2) * 1.0 / (1 - r*r) ) END AS t_stat,
  CASE WHEN n>2 AND ABS(r * SQRT( (n-2) * 1.0 / (1 - r*r) )) >= 2 THEN 1 ELSE 0 END AS signif_approx
FROM rstat
ORDER BY category;

