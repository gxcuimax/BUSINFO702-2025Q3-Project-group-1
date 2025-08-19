--sqlite3
--extract data
.open trend.db
.import --csv --schema temp data\cps_00001.csv demograpy
.import --csv --schema temp data\Ecommerce_data.csv ecommerce
.import --csv --schema temp data\US_youtube_trending_data.csv youtobe

.header on

SELECT DISTINCT customer_segment FROM ecommerce;