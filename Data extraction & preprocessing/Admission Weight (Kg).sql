SELECT * from mimic_icu.chartevents chart
WHERE chart.itemid=226512
AND chart.hadm_id  IN (
SELECT DISTINCT hadm_id FROM mimic_hosp.diagnoses_icd diagnoses
WHERE 
(diagnoses.icd_version = '9' AND
 (	diagnoses.icd_code LIKE '14_%'
	OR diagnoses.icd_code LIKE '15_%'
	OR diagnoses.icd_code LIKE '16_%'
	OR diagnoses.icd_code LIKE '17_%'
	OR diagnoses.icd_code LIKE '18_%'
	OR diagnoses.icd_code LIKE '19_%'
	OR diagnoses.icd_code LIKE '20_%'
	OR diagnoses.icd_code LIKE '21_%'
	OR diagnoses.icd_code LIKE '22_%'
	OR diagnoses.icd_code LIKE '23_%'))
OR (diagnoses.icd_version = '10'
AND diagnoses.icd_code LIKE 'C%')
EXCEPT
SELECT DISTINCT hadm_id FROM mimic_hosp.diagnoses_icd diagnoses
WHERE 
(diagnoses.icd_version = '9' AND diagnoses.icd_code LIKE '428%')
OR (diagnoses.icd_version = '10' AND diagnoses.icd_code LIKE 'I50%'))