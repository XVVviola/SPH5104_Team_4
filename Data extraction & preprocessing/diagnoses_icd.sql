SELECT * FROM mimic_hosp.diagnoses_icd diagnoses 
WHERE diagnoses.hadm_id  IN (
SELECT DISTINCT hadm_id FROM mimic_hosp.diagnoses_icd diagnoses
WHERE 
(diagnoses.icd_version = '9' AND
 (	icd_code LIKE '14_%'
	OR icd_code LIKE '15_%'
	OR icd_code LIKE '16_%'
	OR icd_code LIKE '17_%'
	OR icd_code LIKE '18_%'
	OR icd_code LIKE '19_%'
	OR icd_code LIKE '20_%'
	OR icd_code LIKE '21_%'
	OR icd_code LIKE '22_%'
	OR icd_code LIKE '23_%'))
OR (diagnoses.icd_version = '10'
AND diagnoses.icd_code LIKE 'C%')
EXCEPT
SELECT DISTINCT hadm_id FROM mimic_hosp.diagnoses_icd diagnoses
WHERE 
(diagnoses.icd_version = '9' AND icd_code LIKE '428%')
OR (diagnoses.icd_version = '10' AND icd_code LIKE 'I50%'))