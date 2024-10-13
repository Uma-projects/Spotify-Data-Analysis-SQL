--SQL project SPOTIFY

-- Create table
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM public.spotify
LIMIT 100;

--EDA (Exploratory Data Analysis)

SELECT COUNT(*) FROM spotify;--20594
SELECT COUNT(DISTINCT(artist)) FROM spotify;--2074
SELECT DISTINCT(album_type) FROM spotify;
SELECT MAX(duration_min) FROM spotify;--77.9343
SELECT MIN(duration_min) FROM spotify;--0
SELECT * FROM spotify WHERE duration_min=0;
DELETE FROM spotify WHERE duration_min=0;
SELECT COUNT(*) FROM spotify;--20592

/*
-- ---------------------------
--Data Analysis Easy Category
-- ---------------------------
1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.
*/

--Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track FROM spotify WHERE stream>1000000000;

--List all albums along with their respective artists.
SELECT DISTINCT(album), artist FROM spotify;

--Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) FROM spotify WHERE licensed = 'true';

--Find all tracks that belong to the album type single.
SELECT track FROM spotify WHERE album_type='single';

--Count the total number of tracks by each artist.
SELECT COUNT(track) AS total_no_track ,artist FROM spotify GROUP BY artist;

/*
-- ----------------------------
--Data Analysis Medium Category
-- ----------------------------
6. Calculate the average danceability of tracks in each album.
7. Find the top 5 tracks with the highest energy values.
8. List all tracks along with their views and likes where official_video = TRUE.
9. For each album, calculate the total views of all associated tracks.
10. Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) AS avg_danceability FROM spotify GROUP BY album;

--Find the top 5 tracks with the highest energy values.
SELECT track,energy FROM spotify ORDER BY energy DESC limit 5;

--List all tracks along with their views and likes where official_video = TRUE.
SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes FROM spotify WHERE official_video='true' GROUP BY track;

--For each album, calculate the total views of all associated tracks.
SELECT album, SUM(views) FROM spotify GROUP BY album ORDER BY 2 DESC;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM (SELECT track, COALESCE (SUM(CASE WHEN most_played_on ='Youtube' THEN stream END),0) AS streamed_on_youtube,
COALESCE (SUM(CASE WHEN most_played_on ='Spotify' THEN stream END),0) AS streamed_on_spotify
FROM spotify
GROUP BY 1) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0;

/*
-- -----------------------------
--Data Analysis Advance Category
-- -----------------------------
11. Write a query to find tracks where the liveness score is above the average.
12. Find tracks where the energy-to-liveness ratio is greater than 1.2.
13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
*/

--Write a query to find tracks where the liveness score is above the average.
SELECT track,liveness FROM spotify WHERE liveness> (SELECT AVG(liveness) FROM spotify);

--Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT track,energy/liveness AS energy_to_liveness_ratio FROM spotify WHERE energy/liveness > 1.2;

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC;