/* TO SEE THE ENTIRE TABLE*/
SELECT * FROM `indian_census-project`.`population demographics`;
SELECT * FROM `indian_census-project`.`location details`;

/* COUNT TOTAL NO OF ENTRIES*/
SELECT COUNT(District) 
FROM `indian_census-project`.`population demographics`;

SELECT COUNT(District) 
FROM `indian_census-project`.`location details`;

/* TO FIND THE TOTAL CURRENT POPULATION OF INDIA  */
SELECT SUM(Population) AS population_of_India
FROM `indian_census-project`.`location details`;

/* TO FIND THE TOTAL AREA OF INDIA */
SELECT SUM(Area_km2) AS tot_area_of_India
FROM `indian_census-project`.`location details`;

/* TO EXTRACT DATA FOR JHARKHAND,BIHAR AND DELHI*/
SELECT *
FROM `indian_census-project`.`population demographics`
WHERE
State IN ("Jharkhand","Bihar","Delhi")
ORDER BY State DESC;

SELECT *
FROM `indian_census-project`.`location details`
WHERE
State IN ("Jharkhand","Bihar","Delhi")
ORDER BY State DESC;

/* TO FIND THE AREA DISTRIBUTION PER PERSON OF INDIA */
SELECT SUM(Area_km2) AS tot_area_of_India, SUM(Population) AS population_of_India, SUM(Area_km2)/SUM(Population) AS area_per_person
FROM `indian_census-project`.`location details`;

/* TO FIND THE AVERAGE GROWRTH RATE OF INDIA */
SELECT round(Avg(Growth),2) AS avg_growth_of_India
FROM `indian_census-project`.`population demographics`;

/* TO FIND THE AVERAGE LITERACY RATE OF INDIA */
SELECT round(Avg(Literacy),2) AS avg_literacy_of_India
FROM `indian_census-project`.`population demographics`;

/* TO FIND THE AVERAGE GROWTH RATE STAE WISE */
SELECT State, round(Avg(Growth),2) AS avg_growth
FROM `indian_census-project`.`population demographics` 
GROUP BY state
ORDER BY 
avg_growth DESC;

/* TO FIND THE AVERAGE SEX RATIO STATE WISE */
SELECT State, round(Avg(Sex_Ratio),2) AS avg_Sex_Ratio_state
FROM `indian_census-project`.`population demographics` 
GROUP BY state
ORDER BY 
avg_Sex_Ratio_state DESC;

/* TO FIND THE AVERAGE LITERACY RATE STATE WISE */
SELECT State, round(Avg(literacy),2) AS avg_literacy_state
FROM `indian_census-project`.`population demographics` 
GROUP BY state,

/* TO FIND THE AVG AREA PER PERSON STATE WISE */
SELECT a.state,a.area_per_person
FROM
(SELECT district, state, Area_km2/Population AS area_per_person
FROM `indian_census-project`.`location details`) AS a
GROUP BY
a.state;

/* TO FIND THE STATE ABOVE 85% LITERACY RATE*/
SELECT State, round(Avg(literacy),2) AS avg_literacy_state
FROM `indian_census-project`.`population demographics` 
GROUP BY state
HAVING
avg_literacy_state > 85
ORDER BY
avg_literacy_state DESC;

/*TO FIND BOTTOM 5 STATE FOR LITERACY */
SELECT state,growth,sex_ratio, round(AVG(Literacy),2) AS avg_literacy_state
FROM `indian_census-project`.`population demographics`
GROUP BY state
ORDER BY 
Literacy ASC
LIMIT 5;

-- TO FIND THE TOP 3 STATES WITH HIGHEST POPULATION GROWTH RATE
SELECT  state, round(Avg(growth),2) AS avg_growth_state
FROM `indian_census-project`.`population demographics`
GROUP BY state
ORDER BY 
avg_growth_state DESC
LIMIT 3;

-- TO FIND THE MALE AND FEMALES POPULATION STATE WISE
/* sex_ratio= female/male 
   female= Sex_ratio*male So, female= Sex_ratio*(population/(sex_ratio+1))
   population= female+male 
   population=Sex_ratio*male+male
   population= male(sex_ratio+1) So, male= population/(sex_ratio+1) */
   
SELECT r.state, r.Male AS tot_male_popu, r.Female AS lot_female_popu
FROM
(SELECT p.District,p.State,p.Sex_Ratio/1000 AS Ratio ,l.Population,ROUND((l.population/((p.sex_ratio/1000)+1)),0) AS Male, ROUND((p.Sex_ratio/1000)*(l.population/((p.sex_ratio/1000)+1)),0)AS Female
FROM `indian_census-project`.`population demographics`AS p
Join `indian_census-project`.`location details` AS l
ON  p.District= l.District) as r

-- TO FIND THE MALE AND FEMALES POPULATION OF INDIA
SELECT SUM(t.state_male) AS tot_male_popu, SUM(t.state_female) AS tot_female_popu
FROM
(SELECT s.state, s. male_popu AS state_male ,s.female_popu AS state_female
FROM
(SELECT r.state, r.Male AS male_popu, r.Female AS female_popu
FROM
(SELECT p.District,p.State,p.Sex_Ratio/1000 AS Ratio ,l.Population,ROUND((l.population/((p.sex_ratio/1000)+1)),0) AS Male, ROUND((p.Sex_ratio/1000)*(l.population/((p.sex_ratio/1000)+1)),0)AS Female
FROM `indian_census-project`.`population demographics`AS p
Join `indian_census-project`.`location details` AS l
ON  p.District= l.District) as r) AS s
GROUP BY 
s.state) AS t;




-- TO FIND THE LITERATE AND ILLITERATE STATE WISE
/* Literacy ratio= literate/Population  So, Literate=Literacy ratio*population
Illiterate = population- literate
		   =Population-(literacy ratio*population)
So, Illiterate = Population(1-Literacy ratio) */

SELECT s.state, s.Literate AS tot_literate ,s.illiterate AS tot_illiterate
FROM
(SELECT r.district,r.State, ROUND(r.population*r.literacy_ratio,0) AS Literate, ROUND(r.population*(1-r.literacy_ratio),0) AS Illiterate
FROM 
(SELECT p.District,p.State ,l.Population, p.literacy/100 AS literacy_ratio
FROM `indian_census-project`.`population demographics`AS p
Join `indian_census-project`.`location details` AS l
ON  p.District= l.District) AS r) AS s
GROUP BY
s.state;

-- TO FIND LITERATE AND IILITERATE POPULATION OF INDIA
SELECT SUM(t.tot_literate) AS Literate_in_India, SUM(t.tot_illiterate) AS Illiterate_in_India , 
ROUND(SUM(t.tot_literate)/SUM(t.tot_illiterate),2) AS literacy_ratio
FROM
(SELECT s.state, s.Literate AS tot_literate ,s.illiterate AS tot_illiterate
FROM
(SELECT r.district,r.State, ROUND(r.population*r.literacy_ratio,0) AS Literate, ROUND(r.population*(1-r.literacy_ratio),0) AS Illiterate
FROM 
(SELECT p.District,p.State ,l.Population, p.literacy/100 AS literacy_ratio
FROM `indian_census-project`.`population demographics`AS p
Join `indian_census-project`.`location details` AS l
ON  p.District= l.District) AS r) AS s
GROUP BY
s.state) AS t;

-- TO FIND THE PREVIOUS YEAR POPULATION STATE WISE
/* current population= Previous population+ previous population* growth rate 
   current population= previous population(1+growth rate)
So, previous yr population= current yr population/(1+growth rate)*/

SELECT s.state, s.Previous_popu, s.current_popu
FROM
(SELECT r.district, r.state, r.population AS current_popu, ROUND((r.Population/(1+r.growth_rate))*100,0) AS previous_popu
FROM
(SELECT p.District,p.State ,l.Population, p.growth AS growth_rate
FROM `indian_census-project`.`population demographics`AS p
Join `indian_census-project`.`location details` AS l
ON  p.District= l.District) AS r)AS s
GROUP BY
s.state;

/*TOTAL CURRENT POPULATION AND PREVIOUS POPULATION OF INDIA*/
SELECT SUM(t.Previous_popu) AS India_Previous_population, SUM(t.current_popu) AS India_Current_population
FROM
(SELECT s.state, s.Previous_popu, s.current_popu
FROM
(SELECT r.district, r.state, r.population AS current_popu, ROUND((r.Population/(1+r.growth_rate))*100,0) AS previous_popu
FROM
(SELECT p.District,p.State ,l.Population, p.growth AS growth_rate
FROM `indian_census-project`.`population demographics`AS p
Join `indian_census-project`.`location details` AS l
ON  p.District= l.District) AS r)AS s
GROUP BY
s.state) AS t;










