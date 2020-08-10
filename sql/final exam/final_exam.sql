DROP PROCEDURE IF EXISTS insert_data;
DELIMITER $$
CREATE PROCEDURE insert_data(IN mpr_id INT)
BEGIN
	SELECT native_name, year_made, stage_name, role, screen_name 
	INTO @pro_name, @pro_year, @pro_stgn, @pro_role, @pro_scrn 
	FROM `mpr_test_data` 
	WHERE id= mpr_id;

	-- find the count of the movies based on the selected values
	SELECT COUNT(native_name), movie_id -- what if it doesn't exist: @pro_movid = NULL
	INTO @pro_movie_count, @pro_movid
	FROM `movies` 
	WHERE native_name = @pro_name AND 
		  year_made = @pro_year;

	-- find the count of the persons based on the selected values
	SELECT COUNT(stage_name), people_id
	INTO @pro_person_count, @pro_person_id
	FROM `people` 
	WHERE stage_name = @pro_stgn;

	-- find the count of the relation based on the selected values
	-- If there is data in movie and people:
	SELECT COUNT(movie_id) INTO @pro_relation_count
	FROM `movie_people`
	WHERE movie_id = @pro_movid AND people_id = @pro_person_id AND role = @pro_role;
	
	-- we now have @pro_movie_count and @pro_person_count
	-- based these counts, implement the corresponding test case 
	-- IGNORE / INSERT / UPDATE
	-- See the URL reference 4 given above
	
	SELECT
		CASE
			WHEN @pro_movie_count=1 AND @pro_person_count=1 AND @pro_relation_count>0 THEN 1
			WHEN @pro_movie_count=1 AND @pro_person_count=1 AND @pro_relation_count=0 THEN 3
			WHEN @pro_movie_count=0 AND @pro_person_count=0 THEN 2
			WHEN @pro_movie_count=1 AND @pro_person_count=0 THEN 4
			WHEN @pro_movie_count=0 AND @pro_person_count=1 THEN 5
			WHEN @pro_movie_count>1 THEN 7
			WHEN @pro_person_count>1 THEN 8
			ELSE 9
		END
	INTO @TestCaseNumber;
	-- Insert into `movies`:
	IF @TestCaseNumber = 2 THEN
		INSERT INTO `movies` (native_name, english_name, year_made) VALUES (@pro_name, @pro_name, @pro_year);
		-- get movie_id for adding data into `movie_people` later
		SELECT movie_id INTO @pro_movid FROM `movies` WHERE native_name = @pro_name AND year_made = @pro_year;
		
		INSERT INTO `people` (people_id, stage_name, first_name, middle_name, last_name, gender, image_name) VALUES (15, @pro_stgn, "", "", "", "", "image file name");
		-- get people_id for adding data into `movie_people` later
		SELECT people_id INTO @pro_person_id FROM `people` WHERE stage_name = @pro_stgn;
		
		INSERT INTO `movie_people` (movie_id, people_id, role, screen_name) VALUES (@pro_movid, @pro_person_id, @pro_role, @pro_scrn);
	
	ELSEIF @TestCaseNumber = 5 THEN
		INSERT INTO `movies` (native_name, english_name, year_made) VALUES (@pro_name, @pro_name, @pro_year);
		-- get movie_id for adding data into `movie_people` later
		SELECT movie_id INTO @pro_movid FROM `movies` WHERE native_name = @pro_name AND year_made = @pro_year;
		
		INSERT INTO `movie_people` (movie_id, people_id, role, screen_name) VALUES (@pro_movid, @pro_person_id, @pro_role, @pro_scrn);
		
	ELSEIF @TestCaseNumber = 4 THEN
		INSERT INTO `people` (stage_name, first_name, middle_name, last_name, gender, image_name) VALUES (@pro_stgn, "", "", "", "", "image file name");
		-- get people_id for adding data into `movie_people` later
		SELECT people_id INTO @pro_person_id FROM `people` WHERE stage_name = @pro_stgn;
		
		INSERT INTO `movie_people` (movie_id, people_id, role, screen_name) VALUES (@pro_movid, @pro_person_id, @pro_role, @pro_scrn);
		
	ELSEIF @TestCaseNumber = 3 THEN
		INSERT INTO `movie_people` (movie_id, people_id, role, screen_name) VALUES (@pro_movid, @pro_person_id, @pro_role, @pro_scrn);
		
	END IF;
	
	-- Insert values into `execution_status`:
	UPDATE `mpr_test_data` 
	SET `execution_status` = CASE @TestCaseNumber
								WHEN 1 THEN "M,P,R ignored; Data already exists"
								WHEN 2 THEN "M,P,R created"
								WHEN 3 THEN "M,P ignored; R created"
								WHEN 4 THEN "M ignored, P,R created"
								WHEN 5 THEN "P ignored, M, R created"
								WHEN 7 THEN "M,P,R ignored; Unique tuple can not be identified"
								WHEN 8 THEN "M,P,R ignored; Unique tuple can not be identified"
								ELSE "Error"
							 END
	WHERE id = mpr_id;
	
	
	
END; $$
DELIMITER ;