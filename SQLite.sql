--1.1 What boroughs of New York see the most collisions 
SELECT EXTRACT(YEAR FROM timestamp) as Year, borough, COUNT(UNIQUE_KEY) as collision_amount
FROM phonic-chariot-414917.collision_data_team_6.collision_data_team6
WHERE borough is not null
GROUP BY Year, borough
ORDER BY Year, collision_amount;

--1.2 Are there any areas of the city or intersections with a high number of collisions BETTER WITH HEAT MAP
SELECT cross_street_name, COUNT(UNIQUE_KEY) as collision_amount
FROM phonic-chariot-414917.collision_data_team_6.collision_data_team6
where cross_street_name is not null
GROUP BY cross_street_name
ORDER BY collision_amount DESC;

--2.1 What were the biggest primary and secondary contributing factors for motor vehicle collisions 
SELECT contributing_factor_vehicle_1, COUNT(UNIQUE_KEY) AS collision_amount
FROM phonic-chariot-414917.collision_data_team_6.collision_data_team6
WHERE contributing_factor_vehicle_1  'Unspecified'
GROUP BY contributing_factor_vehicle_1
ORDER BY collision_amount DESC;

--2.2 Does the type of vehicles involved in collisions have an impact on the rate of injurydeath
SELECT  n_vehicle_types, SUM(number_of_cyclist_injured+number_of_motorist_injured + number_of_pedestrians_injured) as injured_num,
SUM(number_of_cyclist_killed+number_of_motorist_killed +number_of_pedestrians_killed) as killed_num
FROM phonic-chariot-414917.collision_data_team_6.collision_data_team6
GROUP BY n_vehicle_types
ORDER BY injured_num desc;

--3 Does the type of vehicles combination involved in collisions have an impact on the rate of injurydeath
SELECT  CASE 
  WHEN n_vehicle_typesn_vehicle_types2 THEN CONCAT(n_vehicle_types,&,n_vehicle_types2)
  ELSE  CONCAT(n_vehicle_types2,&,n_vehicle_types)
END AS combination_type, SUM(number_of_cyclist_injured+number_of_motorist_injured +number_of_pedestrians_injured) as injured_num,
SUM(number_of_cyclist_killed+number_of_motorist_killed +number_of_pedestrians_killed) as killed_num,
FROM phonic-chariot-414917.collision_data_team_6.collision_data_team6
GROUP BY combination_type
ORDER BY injured_num desc;

--4 Are injuries and deaths declining as expected by Vision Zero Are there any seasonal, weekly, or daily patterns to the number of collisions

SELECT EXTRACT(YEAR FROM timestamp) as Year, COUNT(UNIQUE_KEY) AS collision_amount,sum(number_of_persons_injured) as injured_num,
sum(number_of_persons_killed) as killed_num
FROM phonic-chariot-414917.collision_data_team_6.collision_data_team6
GROUP BY Year
ORDER BY Year, injured_num desc;

--5. How do injuries and death rates differ between pedestrians, motorists and cyclists 
--cyclist death rate
WITH CYC AS 
  (select EXTRACT(YEAR FROM timestamp) as Year,
    SUM(number_of_cyclist_injured)count(unique_key)as cyclist_injured_rate,
    SUM(number_of_cyclist_killed)count(unique_key)1000 as cyclist_killed_rate
  from phonic-chariot-414917.collision_data_team_6.collision_data_team6
  WHERE n_vehicle_types = 'Bike' or n_vehicle_types2 = 'Bike'
  GROUP BY Year),
 MOT AS 
  (select EXTRACT(YEAR FROM timestamp) as Year,
    SUM(number_of_motorist_injured)count(unique_key)as motorist_injured_rate,
    SUM(number_of_motorist_killed)count(unique_key)1000 as motorist_killed_rate
  from phonic-chariot-414917.collision_data_team_6.collision_data_team6
  WHERE n_vehicle_types = 'Motorcycle' or n_vehicle_types2 = 'Motorcycle'
  GROUP BY Year), 
 PED AS 
  (select EXTRACT(YEAR FROM timestamp) as Year,
    SUM(number_of_pedestrians_injured)count(unique_key)as pedestrians_injured_rate,
    SUM(number_of_pedestrians_killed)count(unique_key)1000 as pedestrians_killed_rate
  from phonic-chariot-414917.collision_data_team_6.collision_data_team6
  WHERE n_vehicle_types IS NOT NULL AND n_vehicle_types2 IS NULL
  GROUP BY Year)
SELECT CYC.YEAR,cyclist_injured_rate,cyclist_killed_rate,motorist_injured_rate,motorist_killed_rate,pedestrians_injured_rate,pedestrians_killed_rate   FROM CYC
LEFT JOIN MOT ON CYC.YEAR = MOT.YEAR
LEFT JOIN PED ON MOT.YEAR= PED.YEAR

