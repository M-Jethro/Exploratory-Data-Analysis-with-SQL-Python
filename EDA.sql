
---- list of paintings not currently exhibited in any museums.
SELECT * 
FROM paintings.work
WHERE museum_id is NULL;

--- identify museums in the dataset that lack paintings in their collections
SELECT pm.museum_id, pm.name
FROM paintings.museum pm
LEFT JOIN paintings.work pw
    ON pm.museum_id = pw.museum_id
WHERE pw.museum_id IS NULL; 

--- determining the number of paintings with an asking price that exceeds their regular price. 
SELECT * 
FROM paintings.product_size pps
WHERE pps.sale_price > pps.regular_price;

---  identify paintings with an asking price less than 50% of their regular price. 
SELECT * 
FROM paintings.product_size pps
WHERE pps.sale_price < (0.5 * pps.regular_price);

--- determine the canvas size that carries the highest cost. 
SELECT pcs.label, pcs.size_id, pps.sale_price 
FROM paintings.product_size pps
JOIN paintings.canvas_size pcs
	ON pps.size_id = pcs.size_id
ORDER BY pps.sale_price DESC
LIMIT 1;

--- identify the museums with invalid city information in the provided dataset
SELECT pm.name
FROM paintings.museum pm
WHERE (pm.city REGEXP '^[0-9]+$' OR pm.city IS NULL);

--- identify and remove the single invalid entry in the 'Museum_Hours' table. (the query below can not be successfully run until the safe mode has been deactivated)
DELETE 
FROM paintings.museum_hours pmh
WHERE pmh.open > pmh.close
	OR EXTRACT(HOUR FROM pmh.open) IS NULL  
	OR EXTRACT(HOUR FROM pmh.close) IS NULL  
	OR EXTRACT(MINUTE FROM pmh.close) IS NULL
	OR pmh.open IS NULL
	OR pmh.close IS NULL;
 
--- retrieve the top 10 most famous painting subjects from the dataset
SELECT ps.subject, count(pw.work_id) as "Number of paintings"
FROM paintings.work pw
JOIN paintings.subject ps
	ON pw.work_id = ps.work_id
GROUP BY ps.subject
ORDER BY 2 DESC
LIMIT 10;

--- Identify Museums Open on Sunday and Monday: Display Museum Name and City
SELECT pm.name, pm.city
FROM paintings.museum_hours pmh
JOIN paintings.museum pm
    ON pmh.museum_id = pm.museum_id
WHERE pmh.day IN ("Sunday", "Monday");  

--- Count of Museums Open Every Single Day
SELECT COUNT(DISTINCT pmh.museum_id)
FROM paintings.museum_hours pmh
WHERE pmh.museum_id IN (
    SELECT museum_id
    FROM paintings.museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7
);

--- Top 5 Most Popular Museums by Number of Paintings
SELECT pm.name, count(pm.museum_id) 
FROM paintings.work pw
JOIN paintings.museum pm
	ON pw.museum_id = pm.museum_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--- Top 5 Most Popular Artists by Number of Paintings
SELECT pa.full_name, count(pw.artist_id) 
FROM paintings.work pw
JOIN paintings.artist pa
	ON pw.artist_id = pa.artist_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--- Three Least Popular Canvas Sizes
SELECT label, ranking, no_of_paintings
FROM (
    SELECT cs.size_id, cs.label, COUNT(*) AS no_of_paintings,
           DENSE_RANK() OVER (ORDER BY COUNT(*) ASC) AS ranking
    FROM paintings.work w
    JOIN paintings.product_size ps ON ps.work_id = w.work_id
    JOIN paintings.canvas_size cs ON cs.size_id = ps.size_id
    GROUP BY cs.size_id, cs.label
) AS x
WHERE x.ranking <= 3;


--- Museum with Longest Opening Hours: Displaying Museum Name, State, Hours Open, and Day
SELECT mh.museum_id, m.name, m.state,
  SUM(TIME_TO_SEC(CAST(close AS TIME) - CAST(open AS TIME))) AS total_open_hours,
  GROUP_CONCAT(CONCAT(day, ': ', open, '-', close) SEPARATOR ', ') AS days_and_hours
FROM paintings.museum_hours mh
JOIN paintings.museum m ON mh.museum_id = m.museum_id
GROUP BY mh.museum_id, m.name, m.state
ORDER BY total_open_hours DESC
LIMIT 1;

--- Museum with Most Paintings in the Most Popular Painting Style
WITH pop_style AS (
    SELECT style,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM paintings.work
    GROUP BY style
),
cte AS (
    SELECT w.museum_id, m.name AS museum_name, ps.style, COUNT(*) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM paintings.work w
    JOIN paintings.museum m ON m.museum_id = w.museum_id
    JOIN pop_style ps ON ps.style = w.style
    WHERE w.museum_id IS NOT NULL AND ps.rnk = 1
    GROUP BY w.museum_id, m.name, ps.style
)
SELECT museum_name, style, no_of_paintings
FROM cte
WHERE rnk = 1;

--- Identify the artists whose paintings are displayed in multiple countries
SELECT pa.full_name, COUNT(DISTINCT pw.work_id)
FROM paintings.museum pm
	JOIN paintings.work pw ON pw.museum_id = pm.museum_id
	JOIN paintings.artist pa ON pw.artist_id = pa.artist_id
GROUP BY pa.full_name
HAVING COUNT(DISTINCT pm.country) > 1;


--- Display City and Country with the Highest Number of Museums:
SELECT pm.city, pm.country, count(pm.museum_id) AS museum_count
FROM paintings.museum pm
GROUP BY 1, 2
ORDER BY museum_count DESC
LIMIT 1;

--- Identify Artist and Museum for Most and Least Expensive Paintings (Display artist name, sale_price, painting name, museum name, museum city, and canvas label)
--- most expensive 
SELECT pa.full_name, pm.name, pps.sale_price, pw.name, pm.city, pcs.label
FROM paintings.work pw
JOIN paintings.product_size pps 
		ON pw.work_id = pps.work_id
JOIN paintings.artist pa
		ON pw.artist_id = pa.artist_id
JOIN paintings.canvas_size pcs
		ON pcs.size_id = pps.size_id
JOIN paintings.museum pm
		ON pm.museum_id = pw.museum_id
ORDER BY pps.sale_price DESC
LIMIT 1;

--- least expensive
SELECT pa.full_name, pm.name, pps.sale_price, pw.name, pm.city, pcs.label
FROM paintings.work pw
JOIN paintings.product_size pps 
		ON pw.work_id = pps.work_id
JOIN paintings.artist pa 
		ON pw.artist_id = pa.artist_id
JOIN paintings.canvas_size pcs 
		ON pcs.size_id = pps.size_id
JOIN paintings.museum pm 
		ON pm.museum_id = pw.museum_id
ORDER BY pps.sale_price ASC
LIMIT 1;

--- joined for both
 SELECT pa.full_name AS artist,
       pm.name AS museum,
       pw.name AS painting,
       pm.city AS museum_city,
       pcs.label AS canvas_size,
       CASE WHEN pps.sale_price = MAX(pps.sale_price) THEN 'Most Expensive'
            WHEN pps.sale_price = MIN(pps.sale_price) THEN 'Least Expensive'
            ELSE 'Other'
       END AS price_rank,
       pps.sale_price AS sale_price
FROM paintings.work pw
	JOIN paintings.product_size pps 
			ON pw.work_id = pps.work_id
	JOIN paintings.artist pa 
			ON pw.artist_id = pa.artist_id
	JOIN paintings.canvas_size pcs 
			ON pcs.size_id = pps.size_id
	JOIN paintings.museum pm 
			ON pm.museum_id = pw.museum_id
ORDER BY price_rank, pps.sale_price DESC, artist, museum;


--- Country with the 5th Highest Number of Paintings:
SELECT country, painting_count, ranx
FROM (
    SELECT pm.country,
           COUNT(pw.work_id) AS painting_count,
           DENSE_RANK() OVER (ORDER BY COUNT(pw.work_id) DESC) AS ranx
    FROM paintings.museum pm
    JOIN paintings.work pw ON pw.museum_id = pm.museum_id
    GROUP BY pm.country
) AS subquery
WHERE ranx = 5;


--- Artist with Most Portraits Paintings Outside USA (Display artist name, number of paintings, and artist nationality)
SELECT x.artist_name, x.nationality, x.no_of_paintings
FROM (
    SELECT a.full_name AS artist_name, a.nationality,
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM paintings.work w
    JOIN paintings.artist a ON a.artist_id = w.artist_id
    JOIN paintings.subject s ON s.work_id = w.work_id
    JOIN paintings.museum m ON m.museum_id = w.museum_id
    WHERE s.subject = 'Portraits'
      AND m.country != 'USA'
    GROUP BY a.full_name, a.nationality
) x
WHERE x.rnk = 1;














