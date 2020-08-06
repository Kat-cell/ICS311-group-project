//Kathy Thao Iteration 10


[1] SELECT * 
FROM movies
	INNER JOIN movie_data ON (movies.movie_id = movie_data.movie_id)
WHERE movie_data.genre = "Animation";
[2] Before the optimization the movie_data table had to run through the whole table (2 rows) to find the movie genre I was looking for.
[3] To optimize my query I indexed the movies.movie_id and movie_data.genre. I also changed to query to only look at the movie_id and the movie_data genre 
SELECT movies.movie_id, movie_data.genre FROM movies INNER JOIN movie_data ON (movies.movie_id = movie_data.movie_id) WHERE movie_data.genre = "Animation"
[4] After the optimization it only returned 1 row. 1 row. 



//Quoc Bui's iteration 10:
[1] Unoptimnal query: "Get all the movies those were made from the year of 1956 and 2005."
SELECT *
FROM `movies`
WHERE year_made = "2005" OR year_made = "1956";
[2] the query took 0.0405 seconds. The rows number prior to the optimization is 18283 for SIMPLE type
[3] I indexed the attribute `year_made` in the table `movies` as well as convert the "OR" to "UNION ALL"
Optimal query:
(SELECT *
FROM `movies`
WHERE `year_made` = "2005")
UNION ALL
(SELECT *
FROM `movies`
WHERE `year_made` = "1956");
[4] The query took 0.0023 seconds. The rows number after to the optimization is 6 for PRIMARY type and 10 for UNION type.



# Kongmeng Lor
# ICS 311 Database Management System
# Iteration 10

# --------------------------------------------
# Part 1
# A query is selected for optimization (and it is not a duplicate of what others in your team selected)
#
# query # 7.40, Hassan ahmed
# --------------------------------------------

# Original Query:
SELECT *
FROM people
natural JOIN song_people
WHERE ( people.people_id = song_people.people_id )


# --------------------------------------------
# Add bulk data for test
# --------------------------------------------

# 1) Remove associating FKS if exist
IF EXISTS (
  SELECT * 
  FROM sys.foreign_keys 
  WHERE object_id = OBJECT_ID(N'dbo.fk_delete_cascade_people')
    AND parent_object_id = OBJECT_ID(N'dbo.people_trivia')
)
  ALTER TABLE people_trivia
    DROP FOREIGN KEY fk_delete_cascade_people;

# 2) alter people table to allow auto incrementation of primary keys
ALTER TABLE people 
  MODIFY people_id INT NOT NULL AUTO_INCREMENT;

# 3) insert existing data
INSERT INTO people (stage_name, first_name, middle_name, last_name, gender, image_name) 
  SELECT stage_name, first_name, middle_name, last_name, gender, image_name 
  FROM people;

INSERT INTO song_people (song_id, people_id, role) 
  SELECT '1001', p.people_id, 'Composer'
  FROM people p LEFT JOIN song_people s ON s.people_id = p.people_id
  WHERE s.people_id IS NULL;

# 4) check data count
SELECT COUNT(*)
FROM people;

# RESULTS: 196,608 Record

# --------------------------------------------
# Part 2
# EXPLAIN numbers are captured before the query optimization
# --------------------------------------------
EXPLAIN
SELECT *
FROM people
natural JOIN song_people
WHERE ( people.people_id = song_people.people_id )

# 1 SIMPLE song_people index NULL PRIMARY 70 NULL 196188 Using index
# 196188 rows were evaluated

# (196608 total, Query took 0.0131 seconds.)

# --------------------------------------------
# Part 3
# Steps to optimize the query are described and these steps are implemented
# --------------------------------------------

SELECT 
  p.people_id,
  p.stage_name,
  p.first_name,
  p.middle_name,
  p.last_name,
  p.gender,
  p.image_name,
  s.song_id,
  s.role
FROM people p 
  INNER JOIN song_people s USING (people_id);

ALTER TABLE people DROP INDEX idx1;
CREATE INDEX idx1 ON people(people_id);

ALTER TABLE song_people DROP INDEX idx1;
CREATE INDEX idx1 ON song_people(people_id);

# (196608 total, Query took 0.0117 seconds.)

# --------------------------------------------
# Part 4
# --------------------------------------------

# 1) Avoided Cartesian Product by switching the comparison from WHERE clause to use INNER JOIN
# 2) REMOVE * from SELECT clause and specify needed fields
# 3) Indexes on attributes that are used
