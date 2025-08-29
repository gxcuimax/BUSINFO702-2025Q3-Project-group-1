# BUSINFO702-2025Q3-Project-group-1
Aligning YouTube Interests, Demographics, and E-Commerce: Multi-Source Analysis of U.S. Consumer Trends

# Data preparation

## Star Schema Design

To facilitate multifaceted analysis of e-commerce transactions, demographic profiles, and YouTube trending data, a dimensional data model was architected utilizing the star schema paradigm. This design was selected for its inherent simplicity and high query performance, which are optimal for business intelligence and online analytical processing (OLAP). The resultant schema (@fig-star-schema) is composed of a central fact table linked to four descriptive dimension tables as follow:

![ER diagram of star schema](ERD/star%20schema.svg){#fig-star-schema fig-cap="ER diagram of star schema"}

- **Fact Table**: The centre of the data warehouse is the `Trend` fact table, engineered to capture quantitative performance metrics from the e-commerce and YouTube source systems. The level of this table is set at a daily and state-wide level, meaning each individual row summarizes all measured activities (like total sales and total video views) that occurred in a single state on a single day. Each record represents daily top three products and video trend in YouTube in a perticular US state, assuming that every state has the same video trend as national one. The table is linked to the dimension tables through unique keys representing time, location, video trends, and the top three products.

- **Dimension Tables**:

    1. Time Dimension: This dimension table is derived from the date fields present in the source datasets. It provides the temporal context for the facts, enabling time-series analysis. It incorporates a natural chronological hierarchy with levels for Year, Quarter, Month, Day, and Day of Week. This structure permits analysts to examine trends at a daily granularity, aggregate the data to observe monthly, quarterly, or annual patterns, and also analyze trends based on the day of the week.

    2. Location Dimension: This dimension provides the geographical context for the facts, containing descriptive demographic attributes for each location. It features a primary geographical hierarchy with levels for Region and State. Furthermore, it supports analytical roll-ups of its demographic distribution attributes, such as the top three categories for race, marital status, citizenship, employment, and education. This allows for the aggregation of detailed state-level demographic profiles to create summarized, region-level insights.

    3. Product Dimension: This dimension provides detailed, descriptive information about each unique product. Attributes include the product's name and its assigned category, allowing for analysis of sales performance by individual items or by product groups.

    4. YouTubeVideoTrend Dimension: This dimension is derived from the YouTube dataset. It captures daily cultural trends by storing qualitative and quantitative data about the highest-performing videos and categories for each day a video was trending. Due to large amount of videos trending daily, this dimension stores key information for only the top three performing videos to represent the day's trend. The ranking is determined by a calculated engagement score, where $engagement = views + likes - dislikes + comments$.

## Data Warehouse Construction

An Extract-Load-Transform (ELT) architecture was implemented exclusively within the SQLite database engine, utilizing a single SQL script (`trend_dw.sql`). This methodology leverages the database's native processing power for all data manipulation, resulting in a self-contained and reproducible workflow.

### Extract

The Extract phase consists of accessing the raw data from the three disparate source systems. In this project, the datasets were provided as Comma-Separated Values (CSV) files. The extraction process is therefore the initial read operation of these files from the local file system.

### Load

The Load phase involves the ingestion of the raw, untransformed data directly into the SQLite database. The `.import` command-line utility was employed to create and populate three temporary tables: `demography`, `ecommerce`, and `youtube`. This procedure collocates the source data within the database environment, where it can be transformed efficiently using SQL.

```{sqlite3}
#| label: lst-load
#| code-cap: "sqlite3 command of loading data"
# loading data through sqlite3 cmd
.import --csv --schema temp data\cps_00001.csv demography
.import --csv --schema temp data\Ecommerce_data.csv ecommerce
.import --csv --schema temp data\US_youtube_trending_data.csv youtube
```

### Transform

The Transform phase constitutes the most complex stage of the ELT pipeline. It commences with an initial cleaning of the staged data, followed by a series of SQL transformations that populate the dimension tables first, and finally the central fact table to construct the star schema.

1. Data Cleaning

Before populating the dimensional model, the raw data within the demography, ecommerce, and youtube staging tables is cleaned and standardized. This involves using `UPDATE` statements with `CASE` expressions to transform ID numbers into human-readable text (e.g., converting `STATEFIP` codes to state names, `RACE` codes to race descriptions) and to standardize date formats across tables. This preparatory step ensures data consistency and quality before the main transformation logic is applied. (see Appendix or `trend_dw.sql`)

2. Schema Creation

Following the cleaning process, the logical structure of the data warehouse was built based on star schema. `DROP TABLE IF EXISTS` statement was run before creating tables in case of re-run. Subsequently, `CREATE TABLE` statements define the schema for the central Trend fact table and the four dimension tables, establishing primary keys, foreign keys, and data types, which is shown in Appendix and `trend_dw.sql` script. This creates the empty framework of the star schema, ready for data population.

3. Filling Dimension Tables

With the clean data and defined schema in place, each dimension table is populated through a dedicated `INSERT INTO ... SELECT` statement that transforms and aggregates data from the staging tables.

- `Time` Dimension: This table is populated by creating a complete daily calendar for the period of analysis. Although the `ecommerce` data defines the overall start and end dates for the analysis, it lacks entries for many days within that range. To create a continuous timeline, the dimension is built using the more consistent daily dates from the `youtube` dataset. These dates are filtered to fall strictly within the minimum and maximum order dates from the ecommerce data, ensuring a complete and relevant time dimension. Subsequently, the `strftime` function is used to parse each date into its constituent components.

```{sql}
#| label: lst-time
#| code-cap: "statement of fill Time table"
INSERT INTO Time (year, month, quarter, day, dayofweek)
WITH distinct_dates AS (
    SELECT DISTINCT strftime('%Y-%m-%d', trending_date) AS trenddate
    FROM youtube
    WHERE JULIANDAY(trending_date) BETWEEN
    (SELECT JULIANDAY(MIN(order_date)) FROM ecommerce)
    AND (SELECT JULIANDAY(MAX(order_date)) FROM ecommerce)
)
SELECT 
    CAST(STRFTIME('%Y', trenddate) AS integer),
    CAST(STRFTIME('%m', trenddate) AS integer),
    (CAST(STRFTIME('%m', trenddate) AS integer)-1)/4+1,
    CAST(STRFTIME('%d', trenddate) AS integer),
    CASE CAST(STRFTIME('%w', trenddate) AS integer)
        WHEN 0 THEN 'Sunday'
                    WHEN 1 THEN 'Monday'
                    WHEN 2 THEN 'Tuesday'
                    WHEN 3 THEN 'Wednesday'
                    WHEN 4 THEN 'Thursday'
                    WHEN 5 THEN 'Friday'
                    WHEN 6 THEN 'Saturday'
                END
FROM distinct_dates;
```

- `Product` Dimension: This table is populated by grouping the `ecommerce` data by product. The query pivots the data based on the three distinct values in the `customer_segment` column (Corporate, Consumer, Home Office) to create specific columns for sales, quantity, and profit metrics for each segment.

```{sql}
#| label: lst-product
#| code-cap: "statement of filling Product table"
INSERT INTO Product
    (product, category, 
     orders_Corporate, sales_Corporate, quantity_Corporate, profit_Corporate, avg_discount_Corporate,
     orders_Consumer, sales_Consumer, quantity_Consumer, profit_Consumer, avg_discount_Consumer,
     orders_Home_Office, sales_Home_Office, quantity_Home_Office, profit_Home_Office, avg_discount_Home_Office)
SELECT product_name, category_name, 
       SUM(CASE WHEN customer_segment = 'Corporate' THEN 1 ELSE 0 END) AS orders_Corporate,
       SUM(CASE WHEN customer_segment = 'Corporate' THEN sales_per_order ELSE 0 END) AS sales_Corporate,
       SUM(CASE WHEN customer_segment = 'Corporate' THEN order_quantity ELSE 0 END) AS quantity_Corporate,
       SUM(CASE WHEN customer_segment = 'Corporate' THEN profit_per_order ELSE 0 END) AS profit_Corporate,
       AVG(CASE WHEN customer_segment = 'Corporate' THEN order_item_discount ELSE NULL END) AS avg_discount_Corporate,
       SUM(CASE WHEN customer_segment = 'Consumer' THEN 1 ELSE 0 END) AS orders_Consumer,
       SUM(CASE WHEN customer_segment = 'Consumer' THEN sales_per_order ELSE 0 END) AS sales_Consumer,
       SUM(CASE WHEN customer_segment = 'Consumer' THEN order_quantity ELSE 0 END) AS quantity_Consumer,
       SUM(CASE WHEN customer_segment = 'Consumer' THEN profit_per_order ELSE 0 END) AS profit_Consumer,
       AVG(CASE WHEN customer_segment = 'Consumer' THEN order_item_discount ELSE NULL END) AS avg_discount_Consumer,
       SUM(CASE WHEN customer_segment = 'Home Office' THEN 1 ELSE 0 END) AS orders_Home_Office,
       SUM(CASE WHEN customer_segment = 'Home Office' THEN sales_per_order ELSE 0 END) AS sales_Home_Office,
       SUM(CASE WHEN customer_segment = 'Home Office' THEN order_quantity ELSE 0 END) AS quantity_Home_Office,
       SUM(CASE WHEN customer_segment = 'Home Office' THEN profit_per_order ELSE 0 END) AS profit_Home_Office,
       AVG(CASE WHEN customer_segment = 'Home Office' THEN order_item_discount ELSE NULL END) AS avg_discount_Home_Office
FROM ecommerce
GROUP BY product_name, category_name;
```

- `Location` Dimension: This table is populated by grouping the cleaned `demography` data by state (`STATEFIP`). During this process, key demographic metrics like population are calculated. For distributional attributes, an analysis of the source data identified the most prevalent categories. Consequently, the transformation logic creates textual summaries by aggregating percentages for these primary groups: race (Black, White, Asian or Pacific Islander), marital status (Married, Single, Divorced), citizenship (Native-born, Naturalized, Non-Citizen), employment status (At work, Army, NILF - Not in Labor Force), and education level (Less than High School, High School, Bachelor or Higher). This method provides a concise yet representative demographic profile for each state.

```{sql}
#| label: lst-location
#| code-cap: "statement of filling Location table"
INSERT INTO Location
    (state, region, population, metro_statu, avg_household, avg_age, male_rate, 
    employment_distribution, race_distribution, marital_distribution, citizenship_distribution, education_distribution)
SELECT 
    STATEFIP,
    REGION,
    count(*) AS population,
    METRO,
    round(AVG(PERNUM),2) AS avg_household,
    round(AVG(AGE),2),
    round(COUNT(CASE WHEN SEX = 'Male' THEN 1 END)*1.0/COUNT(*),4) AS male_rate,
    'At work:' ||ROUND(SUM(CASE WHEN EMPSTAT = 'At work' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'Army:' ||ROUND(SUM(CASE WHEN EMPSTAT = 'Army' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'NILF:' ||ROUND(SUM(CASE WHEN EMPSTAT = 'NILF' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%',
    'Black:' || ROUND(SUM(CASE WHEN LOWER(RACE) LIKE '%black%' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'White:' || ROUND(SUM(CASE WHEN LOWER(RACE) LIKE '%white%' AND LOWER(RACE) NOT LIKE '%black%' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, ' ||
        'Asian|Pacific Islander:' || ROUND(SUM(CASE WHEN (LOWER(RACE) LIKE '%asian%' OR LOWER(RACE) LIKE '%pacific islander%') 
        AND LOWER(RACE) NOT LIKE '%black%' AND LOWER(RACE) NOT LIKE '%white%' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%',
    'Married:' || ROUND(SUM(CASE WHEN MARST LIKE '%Married%' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'Single:' || ROUND(SUM(CASE WHEN MARST LIKE '%single%' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'Divorced:' || ROUND(SUM(CASE WHEN MARST IN ('Separated', 'Divorced', 'Widowed', 'Widowed or Divorced') THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%',
    'Native-born:' || ROUND(SUM(CASE WHEN CITIZEN NOT LIKE '%citizen' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'Naturalized:'|| ROUND(SUM(CASE WHEN CITIZEN = 'Naturalized citizen' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'Non-Citizen:'|| ROUND(SUM(CASE WHEN CITIZEN = 'Not a citizen' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%',
    'Less than High School:' || ROUND(SUM(CASE WHEN EDUC IN ('No schooling/Preschool', 'Primary school', 'Middle school') THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'High School:'|| ROUND(SUM(CASE WHEN EDUC = 'High school' THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%, '||
        'Bachelor or Higher:'|| ROUND(SUM(CASE WHEN EDUC IN ('Undergraduate', 'Graduate and above') THEN 1.0 ELSE 0 END)*100/ COUNT(*),2)||'%'
FROM demography
GROUP BY STATEFIP;
```

- `YouTubeVideoTrend` Dimension: Populating this table is a multi-step process. First, a temporary table is created to calculate a composite engagement score for each video and rank them on a daily basis, as well as storing relationship between date and `YouTubeVideoTrend` (@lst-temp). 

```{sql}
#| label: lst-temp
#| code-cap: "statement of create temporary table"
-- calculate total engagement = views + likes - dislikes + comments
DROP TABLE IF EXISTS video_date;
CREATE TEMP TABLE video_date AS
WITH video_engagement AS (
    SELECT
        video_id,title,description,trending_date,categoryId,tags,
        (IFNULL(view_count,0) + IFNULL(likes,0) - IFNULL(dislikes, 0) + IFNULL(comment_count,0)) AS engagement
    FROM youtube),
-- add order PS: window function works in sqlite3 above 3.25.0
video_rank AS (
    SELECT 
        trending_date,title,description,engagement,
        ROW_NUMBER() OVER (PARTITION BY trending_date ORDER BY engagement DESC) AS rn
    FROM video_engagement),
-- calculate top 3 categories
top_cat AS (SELECT trending_date, GROUP_CONCAT(categoryId,'|') AS top_categories
    FROM (SELECT trending_date, categoryId, ROW_NUMBER() OVER (PARTITION BY trending_date ORDER BY SUM(engagement) DESC) AS rn
        FROM video_engagement GROUP BY trending_date, categoryId) t
    WHERE rn <= 3
    GROUP BY trending_date)
SELECT 
    c.top_categories, v.rn, v.title,v.description,v.engagement, t.trending_date
FROM 
    (SELECT DISTINCT trending_date FROM youtube) t
    LEFT JOIN video_rank v USING(trending_date)
    LEFT JOIN top_cat c USING(trending_date);
```

Subsequently, this temporary table is queried, and the data is pivoted to create a single row for each day, containing the top three trending videos and their engagement scores.

```{sql}
#| label: lst-video
#| code-cap: "statement of filling YouTubeVideoTrend table"
INSERT INTO YoutubeVideoTrend
    (vtrend_id, top_categories,
    video_1st, description_1st, engagement_1st, 
    video_2nd, description_2nd, engagement_2nd, 
    video_3rd, description_3rd, engagement_3rd)
SELECT 
    MIN(ROWID),
    top_categories,
    MAX(CASE WHEN rn=1 THEN title END) AS video_1st,
    MAX(CASE WHEN rn=1 THEN description END) AS description_1st,
    MAX(CASE WHEN rn=1 THEN engagement END) AS engagement_1st,
    MAX(CASE WHEN rn=2 THEN title END) AS video_2nd,
    MAX(CASE WHEN rn=2 THEN description END) AS description_2nd,
    MAX(CASE WHEN rn=2 THEN engagement END) AS engagement_2nd,
    MAX(CASE WHEN rn=3 THEN title END) AS video_3rd,
    MAX(CASE WHEN rn=3 THEN description END) AS description_3rd,
    MAX(CASE WHEN rn=3 THEN engagement END) AS engagement_3rd
FROM video_date
GROUP BY trending_date;
```

4. Populating the Fact Table
As the final step in the transformation process, the central `Trend` fact table is populated. This is accomplished SELECT statement that as @lst-trend:

- Joins all the previously populated dimension tables with aggregated data from the staging tables.

- Calculates all quantitative measures by applying aggregate functions like `SUM` and `AVG`.

- Groups the results by `date_id` and `location_id` to ensure the data conforms to the defined granularity of the fact table.

```{sql}
#| label: lst-trend
#| code-cap: "statement of filling Trend table"
INSERT INTO Trend
    (date_id, location_id, product_1st, product_2nd, product_3rd,
     total_sales, total_quantity, total_profit, total_orders, avg_discount,
     vtrend_id, total_views, total_likes, total_dislikes, total_comments)
WITH product_summary AS (
    SELECT 
        e.order_date,
        e.customer_state,
        e.product_name,
        SUM(e.sales_per_order) AS total_sales,
        SUM(e.order_quantity) AS total_quantity,
        SUM(e.profit_per_order) AS total_profit,
        COUNT(*) AS total_orders,
        AVG(e.order_item_discount) AS avg_discount
    FROM ecommerce e
    GROUP BY e.order_date, e.customer_state, e.product_name
),
product_rank AS (
    SELECT 
        ps.*,
        ROW_NUMBER() OVER (
            PARTITION BY ps.order_date, ps.customer_state
            ORDER BY ps.total_sales DESC
        ) AS rn
    FROM product_summary ps
)
SELECT 
    tv.date_id,
    l.location_id,
    MAX(CASE WHEN pr.rn=1 THEN p.product_id END) AS product_1st,
    MAX(CASE WHEN pr.rn=2 THEN p.product_id END) AS product_2nd,
    MAX(CASE WHEN pr.rn=3 THEN p.product_id END) AS product_3rd,
    SUM(pr.total_sales) AS total_sales,
    SUM(pr.total_quantity) AS total_quantity,
    SUM(pr.total_profit) AS total_profit,
    SUM(pr.total_orders) AS total_orders,
    AVG(pr.avg_discount) AS avg_discount,
    tv.vtrend_id,
    tv.views,
    tv.likes,
    tv.dislikes,
    tv.comments
FROM (
    SELECT 
        SUM(y.view_count) AS views,
        SUM(y.likes) AS likes,
        SUM(y.dislikes) AS dislikes,
        SUM(y.comment_count) AS comments,
        y.trending_date,
        t.date_id,
        vtrend_id
    FROM Time t JOIN youtube y ON y.trending_date = DATE(printf('%04d-%02d-%02d', t.year, t.month, t.day))
        JOIN (SELECT MIN(ROWID) AS vtrend_id,trending_date FROM video_date GROUP BY trending_date) USING(trending_date)
    GROUP BY t.date_id
    ) tv
CROSS JOIN Location l
JOIN product_rank pr 
    ON pr.order_date = tv.trending_date
   AND pr.customer_state = l.state
JOIN Product p ON p.product = pr.product_name
GROUP BY tv.date_id, l.location_id;
```

