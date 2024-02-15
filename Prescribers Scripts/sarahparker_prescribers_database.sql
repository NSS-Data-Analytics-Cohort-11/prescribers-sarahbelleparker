SELECT *
FROM cbsa;

SELECT *
FROM drug;

SELECT *
FROM fips_county;

SELECT *
FROM overdose_deaths;

SELECT *
FROM population;

SELECT *
FROM prescriber;

SELECT *
FROM prescription;

SELECT *
FROM zip_fips;


--


--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
SELECT prescriber.npi, SUM(total_claim_count)
FROM prescription
	INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;

--Answer: NPI is 1881634483 and the total number of claims is 99707


--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count)
FROM prescription
	INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;

--Answer: Bruce Pendley (first and last name), Family Practice (specialty), total number of claims is 99707


--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, SUM(total_claim_count)
FROM prescription
	INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;

--Answer: The specialty "Family Practice" had the most number of claims (9752347)


--2b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count)
FROM prescription
	INNER JOIN prescriber ON prescriber.npi = prescription.npi
	INNER JOIN drug ON drug.drug_name = prescription.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;

--Answer: The specialty "Nurse Practioner" had the most number of opioid claims


--2c. Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT specialty_description
FROM prescriber
	LEFT JOIN prescription ON prescriber.npi = prescription.npi
GROUP BY specialty_description
HAVING COUNT(prescription.npi) = 0;

--Answer: 


--3a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost)
FROM prescription
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC
LIMIT 1;

--Answer: "INSULIN GLARGINE,HUM.REC.ANLOG" has the highest total drug cost at 104264066.35


--3b. Which drug (generic_name) has the hightest total cost per day?
SELECT generic_name, SUM(total_drug_cost) / SUM(total_day_supply)
FROM prescription
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) / SUM(total_day_supply) DESC
LIMIT 1;

--Answer: "C1 ESTERASE INHIBITOR" has the highest total cost per day at 3495.2190186915887850


--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' 
--for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', 
--and says 'neither' for all other drugs. 
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END
FROM drug;


--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
SELECT SUM(total_drug_cost),
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END
FROM drug
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END;
	
--Answer: More was spent on opioids than antibiotics 