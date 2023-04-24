DROP TABLE baby_names;

CREATE TABLE baby_names (
  year INT,
  first_name VARCHAR(64),
  sex VARCHAR(64),
  num INT
);

\copy baby_names FROM 'datasets/usa_baby_names.csv' DELIMITER ',' CSV HEADER;

1.	Classic American Name
%%sql    
-- Select first names and the total babies with that first_name
-- Group by first_name and filter for those names that appear in all 101 years
-- Order by the total number of babies with that first_name, descending

SELECT first_name, SUM(num)
FROM baby_names
GROUP BY first_name
HAVING COUNT(year) = 101
ORDER BY SUM(num) DESC;

2.	Timeless or Trendy?
Was the name classic and popular across many years or trendy, only popular for a few years?
%%sql
-- Classify first names as 'Classic', 'Semi-classic', 'Semi-trendy', or 'Trendy'
-- Alias this column as popularity_type
-- Select first_name, the sum of babies who have ever had that name, and popularity_type
-- Order the results alphabetically by first_name

SELECT first_name, SUM(num),
        CASE WHEN COUNT(*) > 80 THEN 'Classic'
        WHEN COUNT(*) > 50 THEN 'Semi-classic'
        WHEN COUNT(*) > 20 THEN 'Semi-Trendy'
    ELSE 'Trendy' END as popularity_type
FROM baby_names
GROUP BY first_name
ORDER BY first_name;

3.	Top-ranked female names since 1920
What are the top-ranked female names since 1920?
%%sql
-- RANK names by the sum of babies who have ever had that name (descending), aliasing as name_rank
-- Select name_rank, first_name, and the sum of babies who have ever had that name
-- Filter the data for results where sex equals 'F'
-- Limit to ten results

SELECT first_name,  SUM(num),
        ROW_NUMBER() OVER(ORDER BY SUM(num) desc) as name_rank
FROM baby_names
WHERE sex = 'F'
GROUP BY first_name
LIMIT 10;


4.	Picking a baby name
What was the most popular female name ending in 'A' since 2015?
%%sql
-- Select only the first_name column
-- Filter for results where sex is 'F', year is greater than 2015, and first_name ends in 'a'
-- Group by first_name and order by the total number of babies given that first_name

SELECT first_name
FROM baby_names
WHERE sex = 'F'
    AND year > 2015
    AND first_name LIKE '%a'
GROUP BY first_name
ORDER BY SUM(num) desc;

5.	The Olivia expansion
When did the most popular female name ending in 'A' since 2015 become so popular?
%%sql
-- Select year, first_name, num of Olivias in that year, and cumulative_olivias
-- Sum the cumulative babies who have been named Olivia up to that year; alias as cumulative_olivias
-- Filter so that only data for the name Olivia is returned.
-- Order by year from the earliest year to most recent

SELECT year, first_name, num,
    SUM(num) OVER( ORDER BY year ASC) as cumulative_olivias
FROM baby_names
WHERE first_name LIKE '%Olivia%'
Order by year;


6.	Many males with the same name:
What is the male name given to the highest number of babies in a year?
%%sql
-- Select year and maximum number of babies given any one male name in that year, aliased as max_num
-- Filter the data to include only results where sex equals 'M'
SELECT year, MAX(num) as max_num
    FROM baby_names
    WHERE sex = 'M'
    GROUP BY year asc; 


7.	Top male names over the years

%%sql
-- Select year, first_name given to the largest number of male babies, and num of babies given that name
-- Join baby_names to the code in the last task as a subquery
-- Order results by year descending

SELECT b.year, b.first_name, b.num
FROM baby_names AS b
INNER JOIN (
    SELECT year, MAX(num) as max_num
    FROM baby_names
    WHERE sex = 'M'
    GROUP BY year) AS m
ON m.year = b.year 
    AND m.max_num = b.num
ORDER BY year DESC;


8.	The most years at number one
Which name has been number one for the largest number of years?
%%sql
-- Select first_name and a count of years it was the top name in the last task; alias as count_top_name
-- Use the code from the previous task as a common table expression
-- Group by first_name and order by count_top_name descending

WITH a as (SELECT b.year, b.first_name, b.num
FROM baby_names AS b
INNER JOIN (
    SELECT year, MAX(num) as max_num
    FROM baby_names
    WHERE sex = 'M'
    GROUP BY year) AS m
    ON m.year = b.year 
    AND m.max_num = b.num
    ORDER BY year DESC)

SELECT first_name, COUNT(*) as count_top_name
FROM a
GROUP BY first_name
ORDER BY count_top_name desc;

