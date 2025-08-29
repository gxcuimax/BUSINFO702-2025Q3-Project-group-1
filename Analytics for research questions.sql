SELECT 'Cleaning data';
-- Update all demographic information
ALTER TABLE demography ADD COLUMN state_name TEXT;
UPDATE demography 
SET 
    -- State names based on STATEFIP codes
    state_name = CASE CAST(STATEFIP AS INT)
        WHEN 1  THEN 'Alabama'
        WHEN 2  THEN 'Alaska'
        WHEN 4  THEN 'Arizona'
        WHEN 5  THEN 'Arkansas'
        WHEN 6  THEN 'California'
        WHEN 8  THEN 'Colorado'
        WHEN 9  THEN 'Connecticut'
        WHEN 10 THEN 'Delaware'
        WHEN 11 THEN 'District of Columbia'
        WHEN 12 THEN 'Florida'
        WHEN 13 THEN 'Georgia'
        WHEN 15 THEN 'Hawaii'
        WHEN 16 THEN 'Idaho'
        WHEN 17 THEN 'Illinois'
        WHEN 18 THEN 'Indiana'
        WHEN 19 THEN 'Iowa'
        WHEN 20 THEN 'Kansas'
        WHEN 21 THEN 'Kentucky'
        WHEN 22 THEN 'Louisiana'
        WHEN 23 THEN 'Maine'
        WHEN 24 THEN 'Maryland'
        WHEN 25 THEN 'Massachusetts'
        WHEN 26 THEN 'Michigan'
        WHEN 27 THEN 'Minnesota'
        WHEN 28 THEN 'Mississippi'
        WHEN 29 THEN 'Missouri'
        WHEN 30 THEN 'Montana'
        WHEN 31 THEN 'Nebraska'
        WHEN 32 THEN 'Nevada'
        WHEN 33 THEN 'New Hampshire'
        WHEN 34 THEN 'New Jersey'
        WHEN 35 THEN 'New Mexico'
        WHEN 36 THEN 'New York'
        WHEN 37 THEN 'North Carolina'
        WHEN 38 THEN 'North Dakota'
        WHEN 39 THEN 'Ohio'
        WHEN 40 THEN 'Oklahoma'
        WHEN 41 THEN 'Oregon'
        WHEN 42 THEN 'Pennsylvania'
        WHEN 44 THEN 'Rhode Island'
        WHEN 45 THEN 'South Carolina'
        WHEN 46 THEN 'South Dakota'
        WHEN 47 THEN 'Tennessee'
        WHEN 48 THEN 'Texas'
        WHEN 49 THEN 'Utah'
        WHEN 50 THEN 'Vermont'
        WHEN 51 THEN 'Virginia'
        WHEN 53 THEN 'Washington'
        WHEN 54 THEN 'West Virginia'
        WHEN 55 THEN 'Wisconsin'
        WHEN 56 THEN 'Wyoming'
        WHEN 61 THEN 'Maine-New Hampshire-Vermont'
        WHEN 65 THEN 'Montana-Idaho-Wyoming'
        WHEN 68 THEN 'Alaska-Hawaii'
        WHEN 69 THEN 'Nebraska-North Dakota-South Dakota'
        WHEN 70 THEN 'ME-MA-NH-RI-VT'
        WHEN 71 THEN 'Michigan-Wisconsin'
        WHEN 72 THEN 'Minnesota-Iowa'
        WHEN 73 THEN 'NE-ND-SD-KS'
        WHEN 74 THEN 'Delaware-Virginia'
        WHEN 75 THEN 'North Carolina-South Carolina'
        WHEN 76 THEN 'Alabama-Mississippi'
        WHEN 77 THEN 'Arkansas-Oklahoma'
        WHEN 78 THEN 'Arizona-New Mexico-Colorado'
        WHEN 79 THEN 'ID-WY-UT-MT-NV'
        WHEN 80 THEN 'Alaska-Washington-Hawaii'
        WHEN 81 THEN 'NH-ME-VT-RI'
        WHEN 83 THEN 'South Carolina-Georgia'
        WHEN 84 THEN 'Kentucky-Tennessee'
        WHEN 85 THEN 'Arkansas-Louisiana-Oklahoma'
        WHEN 87 THEN 'IA-ND-SD-NE-KS-MN-MO'
        WHEN 88 THEN 'Washington-Oregon-Alaska-Hawaii'
        WHEN 89 THEN 'MT-WY-CO-NM-UT-NV-AZ'
        WHEN 90 THEN 'Delaware-Maryland-Virginia-West Virginia'
        WHEN 97 THEN 'State not identified'
        WHEN 99 THEN 'State not identified'
        ELSE 'Unknown'
    END,
    
    -- Region names based on REGION codes
    REGION = CASE REGION
        WHEN 11 THEN 'New England Division'
        WHEN 12 THEN 'Middle Atlantic Division'
        WHEN 21 THEN 'East North Central Division'
        WHEN 22 THEN 'West North Central Division'
        WHEN 31 THEN 'South Atlantic Division'
        WHEN 32 THEN 'East South Central Division'
        WHEN 33 THEN 'West South Central Division'
        WHEN 41 THEN 'Mountain Division'
        WHEN 42 THEN 'Pacific Division'
        WHEN 97 THEN 'State not identified'
        ELSE 'Unknown'
    END,
    
    -- Metro status based on METRO codes
    METRO = CASE METRO
        WHEN 0 THEN 'Not identified'
        WHEN 1 THEN 'Not in metropolitan area'
        WHEN 2 THEN 'In central/principal city'
        WHEN 3 THEN 'Not in central/principal city'
        WHEN 4 THEN 'Central/principal city not identified'
        WHEN 9 THEN 'Missing/unknown'
        ELSE 'Unknown'
    END,
    
    -- Gender information based on SEX codes
    SEX = CASE SEX
        WHEN 1 THEN 'Male'
        WHEN 2 THEN 'Female'
        WHEN 9 THEN 'NIU'
        ELSE 'Unknown'
    END,
    
    -- Race names based on RACE codes
    RACE = CASE RACE
        WHEN 100 THEN 'White'
        WHEN 200 THEN 'Black'
        WHEN 300 THEN 'American Indian/Aleut/Eskimo'
        WHEN 650 THEN 'Asian or Pacific Islander'
        WHEN 651 THEN 'Asian only'
        WHEN 652 THEN 'Hawaiian/Pacific Islander only'
        WHEN 700 THEN 'Other (single) race, n.e.c.'
        -- Two or more races
        WHEN 801 THEN 'White-Black'
        WHEN 802 THEN 'White-American Indian'
        WHEN 803 THEN 'White-Asian'
        WHEN 804 THEN 'White-Hawaiian/Pacific Islander'
        WHEN 805 THEN 'Black-American Indian'
        WHEN 806 THEN 'Black-Asian'
        WHEN 807 THEN 'Black-Hawaiian/Pacific Islander'
        WHEN 808 THEN 'American Indian-Asian'
        WHEN 809 THEN 'Asian-Hawaiian/Pacific Islander'
        WHEN 810 THEN 'White-Black-American Indian'
        WHEN 811 THEN 'White-Black-Asian'
        WHEN 812 THEN 'White-American Indian-Asian'
        WHEN 813 THEN 'White-Asian-Hawaiian/Pacific Islander'
        WHEN 814 THEN 'White-Black-American Indian-Asian'
        WHEN 815 THEN 'American Indian-Hawaiian/Pacific Islander'
        WHEN 816 THEN 'White-Black--Hawaiian/Pacific Islander'
        WHEN 817 THEN 'White-American Indian-Hawaiian/Pacific Islander'
        WHEN 818 THEN 'Black-American Indian-Asian'
        WHEN 819 THEN 'White-American Indian-Asian-Hawaiian/Pacific Islander'
        WHEN 820 THEN 'Two or three races, unspecified'
        WHEN 830 THEN 'Four or five races, unspecified'
        WHEN 999 THEN 'Blank'
        ELSE 'Unknown'
    END,
    
    -- Marital status based on MARST codes
    MARST = CASE MARST
        WHEN 1 THEN 'Married, spouse present'
        WHEN 2 THEN 'Married, spouse absent'
        WHEN 3 THEN 'Separated'
        WHEN 4 THEN 'Divorced'
        WHEN 5 THEN 'Widowed'
        WHEN 6 THEN 'Never married/single'
        WHEN 7 THEN 'Widowed or Divorced'
        WHEN 9 THEN 'NIU'
        ELSE 'Unknown'
    END,
    
    -- Citizenship status based on CITIZEN codes
    CITIZEN = CASE CITIZEN
        WHEN 1 THEN 'Born in U.S'
        WHEN 2 THEN 'Born in U.S. outlying'
        WHEN 3 THEN 'Born abroad of American parents'
        WHEN 4 THEN 'Naturalized citizen'
        WHEN 5 THEN 'Not a citizen'
        WHEN 9 THEN 'NIU'
        ELSE 'Unknown'
    END,
    
    -- Education groups based on EDUC codes
    EDUC = CASE 
        -- Primary school (Grades 1–6)
        WHEN EDUC IN (10,11,12,13,14,20,21,22) THEN 'Primary school'

        -- Middle school (Grades 7–9)
        WHEN EDUC IN (30,31,32,40) THEN 'Middle school'

        -- High school (Grades 10–12, including diploma cases)
        WHEN EDUC IN (50,60,70,71,72,73) THEN 'High school'

        -- Undergraduate (Some college, associate degree, 3–4 years college, bachelor's)
        WHEN EDUC IN (80,81,90,91,92,100,110,111) THEN 'Undergraduate'

        -- Graduate and above (Master's, professional, doctorate): Given this group of people was suppCorporateed to occupy a small part of the population, I segmented them together, and we could adjust the group at any time if necessary 
        WHEN EDUC IN (120,121,122,123,124,125) THEN 'Graduate and above'

        -- No schooling or preschool
        WHEN EDUC IN (0,1,2) THEN 'No schooling/Preschool'

        -- Missing or unknown
        WHEN EDUC = 999 THEN 'Unknown'
        ELSE 'Other'
    END,

    -- Employment groups based on EMPSTAT codes
    EMPSTAT = CASE 
        -- Army
        WHEN EMPSTAT = 1 THEN 'Army'

        -- At Work (employed group)
        WHEN EMPSTAT IN (10, 12) THEN 'At work'

        -- Unemployed (experienced + new worker)
        WHEN EMPSTAT IN (20, 21, 22) THEN 'Unemployed'

        -- Not in labor force (NILF: housework, unable, school, other, unpaid, retired)
        WHEN EMPSTAT IN (30, 31, 32, 33, 34, 35, 36) THEN 'NILF'

        ELSE 'Other'
    END;

-- clean youtube dataset
-- change categoryId to category_name
UPDATE youtube
SET categoryId = CASE CAST(categoryId AS INTEGER)
    WHEN 1 THEN 'Film & Animation'
    WHEN 2 THEN 'Autos & Vehicles'
    WHEN 10 THEN 'Music'
    WHEN 15 THEN 'Pets & Animals'
    WHEN 17 THEN 'Sports'
    WHEN 19 THEN 'Travel & Events'
    WHEN 20 THEN 'Gaming'
    WHEN 22 THEN 'People & Blogs'
    WHEN 23 THEN 'Comedy'
    WHEN 24 THEN 'Entertainment'
    WHEN 25 THEN 'News & Politics'
    WHEN 26 THEN 'Howto & Style'
    WHEN 27 THEN 'Education'
    WHEN 28 THEN 'Science & Technology'
    WHEN 29 THEN 'Nonprofits & Activism'
    ELSE categoryId
END,
trending_date = DATE(trending_date);

-- clean ecommerce dataset
-- format the order_date
WITH formatted_date AS (
    SELECT customer_id, 
           CASE 
               WHEN INSTR(order_date, '-') > 0 
                    THEN printf(
                                '%04d-%02d-%02d',
                                SUBSTR(order_date, -4, 4), --year
                                SUBSTR(order_date, 4, 2), --month
                                SUBSTR(order_date, 1, 2) --day
                                )
               WHEN INSTR(order_date, '/') > 0 
                    THEN printf(
                                '%04d-%02d-%02d',
                                SUBSTR(order_date, -4, 4), --year
                                SUBSTR(order_date, INSTR(order_date, '/') + 1, LENGTH(order_date)-INSTR(order_date, '/')-5), --month
                                SUBSTR(order_date, 1, INSTR(order_date, '/') - 1) --day
                                )
               ELSE NULL
           END AS formatted_order_date
    FROM ecommerce
)
UPDATE ecommerce
SET order_date = formatted_order_date
FROM formatted_date
WHERE ecommerce.customer_id = formatted_date.customer_id;

-- building a warehouse following the star schema
SELECT 'Building data warehouse';
-- drop table in case re-run
DROP TABLE IF EXISTS Time;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS YouTubeVideoTrend;
DROP TABLE IF EXISTS Trend;
-- create dim tables
CREATE TABLE Time (
    date_id integer PRIMARY KEY,
    year integer,
    month integer,
    quarter integer,
    day integer,
    dayofweek text
);
CREATE TABLE Location (
    location_id integer PRIMARY KEY,
    state text,
    region text,
    population integer,
    metro_statu text,
    avg_household real,
    avg_age real,
    male_rate real,
    race_distribution text,
    marital_distribution text,
    citizenship_distribution text,
    employment_distribution text,
    education_distribution text
);
CREATE TABLE Product (
    product_id integer PRIMARY KEY,
    product text,
    category text,
    orders_Corporate integer,
    sales_Corporate real,
    quantity_Corporate real,
    profit_Corporate real,
    avg_discount_Corporate real,
    orders_Consumer integer,
    sales_Consumer real,
    quantity_Consumer real,
    profit_Consumer real,
    avg_discount_Consumer real,
    orders_Home_Office integer,
    sales_Home_Office real,
    quantity_Home_Office real,
    profit_Home_Office real,
    avg_discount_Home_Office real
);
CREATE TABLE YouTubeVideoTrend (
    vtrend_id integer PRIMARY KEY,
    top_categories text,
    video_1st text,
    description_1st text,
    engagement_1st text,
    video_2nd text,
    description_2nd text,
    engagement_2nd text,
    video_3rd text,
    description_3rd text,
    engagement_3rd text
);
-- create fact table
CREATE TABLE Trend (
    trend_id integer PRIMARY KEY,
    date_id integer,
    location_id integer,
    product_1st integer,
    product_2nd integer,
    product_3rd integer,
    vtrend_id integer,
    total_sales real,
    total_quantity real,
    total_profit real,
    total_orders integer,
    avg_discount real,
    total_views real,
    total_likes real,
    total_dislikes real,
    total_comments real,
    FOREIGN KEY (date_id) REFERENCES Time (date_id),
    FOREIGN KEY (location_id) REFERENCES Location (location_id),
    FOREIGN KEY (product_1st) REFERENCES Product (product_id),
    FOREIGN KEY (product_2nd) REFERENCES Product (product_id),
    FOREIGN KEY (product_3rd) REFERENCES Product (product_id),
    FOREIGN KEY (vtrend_id) REFERENCES YouTubeVideoTrend (vtrend_id)
);
SELECT 'Loading data into data warehouse';
-- load to Time dim
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
SELECT 'Time done';
-- load to Product
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
SELECT 'Product done';
-- load to location
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
SELECT 'Location done';
-- load to YoutubeVideoTrend
-- calculate total engagement = views + likes - dislikes + comments
DROP TABLE if EXISTS video_date
CREATE TEMP TABLE video_date AS 
WITH video_engagement AS (
    SELECT
        video_id,
        title,
        description,
        trending_date,
        categoryId,
        tags,
        (IFNULL(view_count,0) + IFNULL(likes,0) - IFNULL(dislikes, 0) + IFNULL(comment_count,0)) AS engagement
    FROM youtube
),
-- add order
video_rank AS (
    SELECT 
        trending_date,
        title,
        description,
        engagement,
        ROW_NUMBER() OVER (PARTITION BY trending_date ORDER BY engagement DESC) AS rn
    FROM video_engagement
),
-- calculate top 3 categories
top_cat AS (
    SELECT trending_date, GROUP_CONCAT(categoryId,'|') AS top_categories
    FROM (
        SELECT trending_date, categoryId, ROW_NUMBER() OVER (PARTITION BY trending_date ORDER BY SUM(engagement) DESC) AS rn
        FROM video_engagement
        GROUP BY trending_date, categoryId
        ) t
    WHERE rn <= 3
    GROUP BY trending_date
)
SELECT 
    c.top_categories,
    v.rn,
    v.title,
    v.description,
    v.engagement,
    t.trending_date
FROM 
    (SELECT DISTINCT trending_date FROM youtube) t
    LEFT JOIN video_rank v USING(trending_date)
    LEFT JOIN top_cat c USING(trending_date)
;

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
SELECT 'Video done';
-- load to Trend
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
SELECT 'Trend done';

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

