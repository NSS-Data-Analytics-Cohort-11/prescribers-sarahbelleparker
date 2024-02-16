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


--5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(cbsa)
FROM cbsa
	INNER JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty
WHERE state = 'TN';

--answer: There are 42 CBSAs in Tennessee.


--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population)
FROM cbsa
	INNER JOIN population ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) DESC;

--answer: Nashville-Davidson-Murfreesboro-Franklin, TN is the largest CBSA with a total population of 1830410, and Morristown, TN is the smallest CBSA with a total population of 116352.


--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, SUM(population)
FROM fips_county
	INNER JOIN population ON fips_county.fipscounty = population.fipscounty
	LEFT JOIN cbsa ON population.fipscounty = cbsa.fipscounty
WHERE cbsa IS NULL
GROUP BY county
ORDER BY SUM(population) DESC
LIMIT 1;

--answer: Sevier county has the largest population and is not in a CBSA


--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 2999;


--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT prescription.drug_name, total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' ELSE 'other' END
FROM prescription
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE total_claim_count > 2999;


--6c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescription.drug_name, total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' ELSE 'other' END, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
	INNER JOIN prescriber ON prescription.npi = prescriber.npi
WHERE total_claim_count > 2999
ORDER BY total_claim_count DESC;


--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) 
--in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). 
--**Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT npi, drug_name
FROM prescriber
	FULL JOIN drug ON 1 = 1
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y';
	

--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
--You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT prescriber.npi, drug.drug_name, SUM(total_claim_count)
FROM prescriber
	FULL JOIN drug ON 1 = 1
	LEFT JOIN prescription ON prescription.npi = prescriber.npi AND drug.drug_name = prescription.drug_name
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name;


--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug.drug_name, 
	COALESCE(SUM(total_claim_count), 0)
FROM prescriber
	FULL JOIN drug ON 1 = 1
	LEFT JOIN prescription ON prescription.npi = prescriber.npi AND drug.drug_name = prescription.drug_name
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
ORDER BY COALESCE(SUM(total_claim_count), 0) DESC;