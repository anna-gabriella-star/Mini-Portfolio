use teamproject;

SELECT * 
FROM green_totalscores g
JOIN population_index p ON g.country_id = p.country;
#keys do not have to be the same name 


SELECT *
FROM carbon_emissions ce
join clean_innovation ci
on ce.country_id = ci.country_id;

SELECT *
FROM green_totalscores
ORDER BY green_index DESC;

SELECT *
FROM green_totalscores ge
join carbon_emissions em
on ge.country_id = em.country_id
GROUP BY ge.country_id;
#cannot group because there are no duplicates

SELECT ge.country_id,
       SUM(ge.total_emissions) AS TotalGreenEmissions,
       SUM(em.carbon_emissions) AS TotalCarbonEmissions,
       SUM(em.emissions_transport) AS TotalEmissionsTransport,
       SUM(em.emissions_industry) AS TotalEmissionsIndustry,
       SUM(em.emissions_agriculture) AS TotalEmissionsAgriculture
FROM green_totalscores ge
JOIN carbon_emissions em
ON ge.country_id = em.country_id
GROUP BY ge.country_id;

SELECT ge.country_id, 
       ge.total_emissions, 
       ge.total_energy_transition, 
       ge.total_green_society, 
       ge.total_clean_innovation, 
       ge.total_climate_policy, 
       ge.green_index, 
       em.carbon_emissions, 
       em.emissions_transport, 
       em.emissions_industry, 
       em.emissions_agriculture
FROM green_totalscores ge
JOIN carbon_emissions em
ON ge.country_id = em.country_id
ORDER BY em.carbon_emissions DESC;

SELECT (green_index - carbon_emissions) AS Differencegreenindexandcarbon
FROM green_totalscores ge
JOIN carbon_emissions em
ON ge.country_id = em.country_id;

SELECT ge.country_id, 
       ge.total_emissions, 
       ge.total_energy_transition, 
       ge.total_green_society, 
       ge.total_clean_innovation, 
       ge.total_climate_policy, 
       ge.green_index, 
       em.carbon_emissions, 
       em.emissions_transport, 
       em.emissions_industry, 
       em.emissions_agriculture,
       (ge.green_index - em.carbon_emissions) AS difference
FROM green_totalscores ge
JOIN carbon_emissions em
ON ge.country_id = em.country_id
ORDER BY difference ASC;

#if you are 10 you are doing well 
#greenindex-carbonemissions (the larger the carbon emission the better it is)

SELECT *
from population_index p
left join green_totalscores gt
ON p.country=gt.country_id;

SELECT *
FROM population_index p
LEFT JOIN green_totalscores gt
ON p.country= gt.country_id
ORDER BY p.population_rank ASC;
#no link between population and total emissions 


#do something with climate policy and green society
SELECT cp.country_id, cp.agriculture_strategy, gs.meat_diary_consume, gs.forestation_change
from climate_policy cp 
join green_society gs
on cp.country_id=gs.country_id
RANK() over(partition by country_id by agriculture_strategy DESC) AS agistrat;


SELECT cp.country_id, 
       cp.agriculture_strategy, 
       gs.meat_diary_consume, 
       gs.forestation_change,
       ROWNUMBER() OVER (PARTITION BY cp.country_id ORDER BY cp.agriculture_strategy DESC) AS agistrat
FROM climate_policy cp 
JOIN green_society gs
ON cp.country_id = gs.country_id;


SELECT cp.country_id, 
       cp.agriculture_strategy, 
       gs.meat_diary_consume, 
       gs.forestation_change,
       ROW_NUMBER() OVER (ORDER BY cp.agriculture_strategy DESC) AS agri_rank
FROM climate_policy cp 
JOIN green_society gs
ON cp.country_id = gs.country_id
ORDER BY agri_rank;
#this is agriculture strategy rank

SELECT  cp.country_id,
       cp.agriculture_strategy,
       gs.meat_diary_consume,
       gs.forestation_change,
       RANK() OVER (ORDER BY cp.agriculture_strategy DESC) AS agri_rank,
       RANK() OVER (ORDER BY gs.meat_diary_consume DESC) AS meat_rank,  
       RANK() OVER (ORDER BY gs.forestation_change DESC) AS forest_rank  
FROM climate_policy cp 
JOIN green_society gs
ON cp.country_id = gs.country_id
ORDER BY agri_rank;

#climate emissionas and climate policy

SELECT ce.country_id,
       ce.agriculture_strategy,
       cp.meat_diary_consume,
       cp.forestation_change,
       RANK() OVER (ORDER BY ce.agriculture_strategy DESC) AS agri_rank,
       RANK() OVER (ORDER BY cp.meat_diary_consume DESC) AS meat_rank,  
       RANK() OVER (ORDER BY  cp.forestation_change DESC) AS forest_rank  
FROM climate_emissions ce 
JOIN climate_policy cp
ON cp.country_id = gs.country_id
ORDER BY agri_rank;

SELECT ce.country_id,
       ce.emissions_industry,
       ce.emissions_agriculture,
       cp.agriculture_strategy,
       cp.climate_action,
       RANK() OVER (ORDER BY ce.emissions_industry DESC) AS industryemission_rank,
       RANK() OVER (ORDER BY ce.emissions_agriculture DESC) AS agriemission_rank,  
       RANK() OVER (ORDER BY cp.agriculture_strategy DESC) AS overallagri_rank,
       RANK() OVER (ORDER BY cp.climate_action DESC) AS climate
FROM carbon_emissions ce 
JOIN climate_policy cp
ON ce.country_id = cp.country_id
ORDER BY agri_rank;

SELECT ce.country_id,
       ce.emissions_agriculture,
       cp.agriculture_strategy,
       RANK() OVER (ORDER BY ce.emissions_agriculture DESC) AS agriemission_rank,  
       RANK() OVER (ORDER BY cp.agriculture_strategy DESC) AS overallagri_rank
FROM carbon_emissions ce 
JOIN climate_policy cp
ON ce.country_id = cp.country_id
ORDER BY overallagri_rank;

#greentotalscores and energy transition
SELECT gt.country_id, gt.total_emissions, et.renewable_energy, et.renewable_contribution,
from green_totalscores gt
left join energy_transition et
on gt.country_id=et.country_id;


SELECT ci.country_id, ci.patents, gt.total_clean_innovation,
RANK() OVER (ORDER BY ci.patents DESC) as patent_rank
RANK() OVER (ORDER BY gt.total_clean_innovation) as cleaninnovation
from clean_innovation ci
left join green_totalscores gt
on ci.country_id = gt.country_id;


SELECT ci.country_id, 
       ci.patents, 
       gt.total_clean_innovation,
       RANK() OVER (ORDER BY ci.patents DESC) AS patent_rank,
       RANK() OVER (ORDER BY gt.total_clean_innovation DESC) AS cleaninnovation_rank
FROM clean_innovation ci
LEFT JOIN green_totalscores gt
ON ci.country_id = gt.country_id;

use team_project;

#Link between carbon pricing management and carbon emissions
SELECT cp.country_id AS Country_ID, RANK() OVER (ORDER BY cp.carbon_pricing DESC) AS Rank_carbon_pricing, RANK() OVER (ORDER BY ce.carbon_emissions DESC) AS Rank_carbon_emissions
FROM climate_policy cp
JOIN carbon_emissions ce
USING(country_id)
ORDER BY Rank_carbon_pricing ASC;

#Problèmes noms de continent
Select continent,gt.country_id, total_emissions,emissions_transport,emissions_industry,emissions_agriculture,
RANK() over(partition by continent order by total_emissions DESC) AS Total_Emission_Rank
from carbon_emissions
LEFT Join continent_list 
using(country_id)
Left join  green_totalscores gt
using(country_id);

#See wich countries manage the best their carbon emissions
Select gt.country_id, total_emissions,carbon_emissions, carbon_growth, emissions_transport,emissions_industry,emissions_agriculture,
RANK() over(order by total_emissions DESC) AS Total_Emission_Rank
from carbon_emissions
Left join  green_totalscores gt
using(country_id);
#used #10 is the winner good

#Link between population and green index scores
SELECT p.country, p.population_rank, RANK() OVER (ORDER BY gt.green_index DESC) AS Rank_GI
FROM population_index p
LEFT JOIN green_totalscores gt
ON p.country= gt.country_id
WHERE green_index IS NOT NULL
ORDER BY Rank_GI ASC;
#used


#Link between population and green index scores
SELECT p.country, p.population_rank, RANK() OVER (ORDER BY gt.green_index DESC) AS Rank_GI
FROM population_index p
LEFT JOIN green_totalscores gt
ON p.country= gt.country_id
WHERE green_index IS NOT NULL;

SELECT gt.country_id, gt.total_emissions, RANK () OVER(ORDER BY gt.total_emissions DESC) AS Rank_total_emissions,
et.renewable_energy, RANK () OVER(ORDER BY et.renewable_energy DESC) AS Rank_renewable_energy
from green_totalscores gt
left join energy_transition et
on gt.country_id=et.country_id
ORDER BY Rank_total_emissions;






