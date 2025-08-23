--sqlite3
--extract data
.open trend.db
.import --csv --schema temp data\cps_00001.csv demography
.import --csv --schema temp data\Ecommerce_data.csv ecommerce
.import --csv --schema temp data\US_youtube_trending_data.csv youtobe

.headers on

-- values of REGION,METRO,SEX,RACE,MARST,CITIZEN,EMPSTAT,EDUC are numbers
SELECT name, group_concat(value,',') 'values'
FROM (
    SELECT DISTINCT 'REGION' name, REGION value FROM demography
    UNION ALL
    SELECT DISTINCT 'METRO' name, METRO value FROM demography
    UNION ALL
    SELECT DISTINCT 'SEX' name, SEX value FROM demography
    UNION ALL
    SELECT DISTINCT 'RACE' name, RACE value FROM demography
    UNION ALL
    SELECT DISTINCT 'MARST' name, MARST value FROM demography
    UNION ALL
    SELECT DISTINCT 'CITIZEN' name, CITIZEN value FROM demography
    UNION ALL
    SELECT DISTINCT 'EMPSTAT' name, EMPSTAT value FROM demography
    UNION ALL
    SELECT DISTINCT 'EDUC' name, EDUC value FROM demography
    ORDER BY name,value
    )
GROUP BY name;

SELECT DISTINCT categoryId FROM youtobe;