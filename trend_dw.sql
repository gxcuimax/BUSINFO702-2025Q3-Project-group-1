-- usage: sqlite3 trend.db
--        .read trend_dw.sql
--extract data
SELECT 'Extracting data';
.import --csv --schema temp data\cps_00001.csv demography
.import --csv --schema temp data\Ecommerce_data.csv ecommerce
.import --csv --schema temp data\US_youtube_trending_data.csv youtube

SELECT 'Cleaning data';
-- Update all demographic information
UPDATE demography 
SET 
    -- State names based on STATEFIP codes
    STATEFIP = CASE STATEFIP
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
    WHEN 1 THEN 'AutCorporate & Vehicles'
    WHEN 2 THEN 'Music'
    WHEN 10 THEN 'Comedy'
    WHEN 15 THEN 'Science & Technology'
    WHEN 17 THEN 'Movies'
    WHEN 19 THEN 'Action/Adventure'
    WHEN 20 THEN 'Classics'
    WHEN 22 THEN 'Documentary'
    WHEN 23 THEN 'Drama'
    WHEN 24 THEN 'Family'
    WHEN 25 THEN 'Foreign'
    WHEN 26 THEN 'Horror'
    WHEN 27 THEN 'Sci-Fi/Fantasy'
    WHEN 28 THEN 'Thriller'
    WHEN 29 THEN 'Shorts'
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
