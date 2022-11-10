SELECT * FROM PortfolioProject_1..data1

SELECT * FROM PortfolioProject_1..data2

--Number of rows in Dataset

SELECT COUNT(*) FROM PortfolioProject_1..data1

SELECT COUNT(*) FROM PortfolioProject_1..data2

--dataset for states named Jharkhand and Bihar

SELECT * 
FROM PortfolioProject_1..data1
WHERE State in ('Jharkhand','Bihar')

--total population of India

SELECT SUM(Population) as total_population
FROM PortfolioProject_1..data2

--average growth 

SELECT State, AVG(Growth)*100 AS average_growth
FROM PortfolioProject_1..data1 
GROUP BY State

--average sex_ratio

SELECT State, ROUND(AVG(Sex_Ratio),0) AS average_sex_ratio
FROM PortfolioProject_1..data1 
GROUP BY State
ORDER BY average_sex_ratio DESC

--average literacy rate

SELECT State, ROUND(AVG(Literacy),0) AS average_literacy
FROM PortfolioProject_1..data1 
GROUP BY State
HAVING ROUND(AVG(Literacy),0)>90
ORDER BY average_literacy DESC

--top 3 states showing highest growth ratio


SELECT TOP 3 State, AVG(Growth)*100 AS average_growth
FROM PortfolioProject_1..data1 
GROUP BY State
ORDER BY average_growth DESC

--bottom 3 states showing lowest sex_ratio


SELECT TOP 3 State, ROUND(AVG(Sex_Ratio),0) AS average_sex_ratio
FROM PortfolioProject_1..data1 
GROUP BY State
ORDER BY average_sex_ratio 

--top and bottom 3 states in literacy rate

DROP TABLE IF EXISTS #top_states
CREATE TABLE #top_states(
state NVARCHAR(255),
topstates FLOAT
)
INSERT INTO #top_states
SELECT State, ROUND(AVG(literacy),0) AS average_literacy_ratio
FROM PortfolioProject_1..data1
GROUP BY State
ORDER BY average_literacy_ratio DESC;

SELECT TOP 3 * FROM #top_states ORDER BY #top_states.topstates desc;



DROP TABLE IF EXISTS #bottom_states
CREATE TABLE #bottom_states(
state NVARCHAR(255),
topstates FLOAT
)
INSERT INTO #bottom_states
SELECT TOP 3 State, ROUND(AVG(literacy),0) AS average_literacy_ratio
FROM PortfolioProject_1..data1
GROUP BY State
ORDER BY average_literacy_ratio;

SELECT * FROM #bottom_states


--union operator
SELECT * FROM (
SELECT TOP 3 * FROM #top_states ORDER BY #top_states.topstates desc) a
union
SELECT * FROM #bottom_states


--states starting with letter "K" or "M"

SELECT DISTINCT(State) FROM PortfolioProject_1..data1
WHERE State LIKE 'K%' OR State LIKE 'M%'


SELECT DISTINCT(State) 
FROM PortfolioProject_1..data1
WHERE LOWER(State) LIKE 'k%' AND lower(State) LIKE '%A'


--joining both table

--total males and females
SELECT d.State, SUM(d.males) AS total_males, SUM(d.females) AS total_females FROM 
(SELECT c.District, c.State, ROUND(c.Population/(c.Sex_ratio+1),0) AS males, ROUND((c.population*c.Sex_ratio)/(c.Sex_ratio+1),0) AS females FROM
(SELECT a.District, a.State, a.Sex_ratio/1000 Sex_ratio, b.Population 
FROM PortfolioProject_1..data1 a 
INNER JOIN PortfolioProject_1..data2 b 
ON a.district=b.district)
c)
d
GROUP BY d.State


--total literacy rate

SELECT c.State, SUM(literate_people) AS total_literate,SUM(illiterate_people) AS total_illiterate
FROM
(SELECT d.District, d.State, ROUND(d.literacy_ratio*d.Population,0) AS literate_people, ROUND((1-d.literacy_ratio)*d.Population,0) AS illiterate_people
FROM 
(SELECT a.District, a.State, a.literacy/100 AS literacy_ratio, b.Population 
FROM PortfolioProject_1..data1 a
INNER JOIN PortfolioProject_1..data2 b
ON a.District=b.District)
d)
c
GROUP BY c.State


--Population in previous census



