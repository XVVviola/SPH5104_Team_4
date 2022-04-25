/*
Try to find the gsn codes for all the relevent statins. 

SELECT DISTINCT rx.drug,rx.gsn FROM mimic_hosp.prescriptions rx
WHERE rx.drug LIKE '%statin'
ORDER BY rx.drug
 */

/* 
Find prescriptions for all relevant statins by searchign for the identified gsn code 


SELECT * FROM mimic_hosp.prescriptions rx
WHERE rx.gsn IN (
	'029967','029968','029969','045772',
	'021694','046757',
	'006460','006461','016310',
	'066349','066350',
	'016367','016366','020741','049758',
	'051785','052944','051784','051786',
	'016577','016579','040238','016576','016578'
)*/


/* 
Merge ICU cancer patients without HF data with statin prescription information.
Note that the ICU data here has not been filtered by lab events
*/

SELECT * FROM mimic_core.admissions admissions LEFT OUTER JOIN (
SELECT * FROM mimic_hosp.prescriptions rx
WHERE rx.gsn IN ('029967','029968','029969','045772','021694','046757','006460','006461','016310','066349','066350','016367',
				 '016366','020741','049758','051785','052944','051784','051786','016577','016579','040238','016576','016578')) 
AS statin
ON admissions.subject_id = statin.subject_id AND admissions.hadm_id = statin.hadm_id
WHERE admissions.hadm_id IN (
SELECT DISTINCT diagnoses.hadm_id FROM mimic_hosp.diagnoses_icd diagnoses
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
SELECT DISTINCT diagnoses.hadm_id FROM mimic_hosp.diagnoses_icd diagnoses
WHERE 
(diagnoses.icd_version = '9' AND diagnoses.icd_code LIKE '428%')
OR (diagnoses.icd_version = '10' AND diagnoses.icd_code LIKE 'I50%')
)