--sqlite3
--extract data
.open trend.db
.import --csv --schema temp data\cps_00001.csv demography
.import --csv --schema temp data\Ecommerce_data.csv ecommerce
.import --csv --schema temp data\US_youtube_trending_data.csv youtobe

.headers on

