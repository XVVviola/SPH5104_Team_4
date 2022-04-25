SELECT * FROM mimic_icu.icustays icu
INNER JOIN mimic_hosp.labevents labevents
ON (icu.subject_id =labevents.subject_id and icu.hadm_id=labevents.hadm_id)
WHERE icu.hadm_id IN (
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
OR (diagnoses.icd_version = '10' AND icd_code LIKE 'I50%')
)
AND labevents.itemid in (51002,52642,51003,50963,51921)
