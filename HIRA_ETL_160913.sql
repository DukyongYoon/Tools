USE NHIS_ORIGINAL
--USE NHISS_CDM
--==================================================================================================================================================================
-- PERSON 테이블----------------------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE LOCATION 
    ( 
     location_id					VARCHAR(50)		NOT NULL, 
     address_1						VARCHAR(50)		NULL , 
     address_2						VARCHAR(50)		NULL , 
     city							VARCHAR(50)		NULL , 
     state							VARCHAR(50)		NULL , 
     zip							VARCHAR(50)		NULL , 
     county							VARCHAR(50)		NULL , 
     location_source_value			VARCHAR(50)		NULL
    ) 
;
--DROP TABLE LOCATION
--==================================================================================================================================================================

insert into LOCATION (location_id, address_1, address_2, city, [state], 
zip, county, location_source_value)
SELECT DISTINCT
	location_id = A.[시군구코드],
    ADDRESS_1 = A.[시도],
	ADDRESS_2 = A.[시군구],
	CITY = A.[시도],
	STATE = A.[시군구],
	ZIP = NULL,
	COUNTY = NULL,
	LOCATION_SOURCE_VALUE = A.[시군구코드]
	FROM [dbo].[OHDSI_CDM_LOCATION] A
	-- (317개 행이 영향을 받음) / 00:00:00

CREATE INDEX LOCATION_IDX ON LOCATION (LOCATION_ID)

--==================================================================================================================================================================
-- PERSON 테이블----------------------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE PERSON 
    (
     person_id						INTEGER		NOT NULL , 
     gender_concept_id				INTEGER		NOT NULL , 
     year_of_birth					INTEGER		NOT NULL , 
     month_of_birth					INTEGER		NULL, 
     day_of_birth					INTEGER		NULL, 
	 time_of_birth					VARCHAR(50)	NULL,
     race_concept_id				INTEGER		NOT NULL, 
     ethnicity_concept_id			INTEGER		NOT NULL, 
     location_id					VARCHAR(50)		NULL, 
     provider_id					INTEGER		NULL, 
     care_site_id					INTEGER		NULL, 
     person_source_value			VARCHAR(50) NULL, 
     gender_source_value			VARCHAR(50) NULL,
	 gender_source_concept_id		INTEGER		NULL, 
     race_source_value				VARCHAR(50) NULL, 
	 race_source_concept_id			INTEGER		NULL, 
     ethnicity_source_value			VARCHAR(50) NULL,
	 ethnicity_source_concept_id	INTEGER		NULL
    ) ;
--==================================================================================================================================================================
INSERT INTO PERSON (person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, time_of_birth, 
race_concept_id, ethnicity_concept_id, location_id, provider_id, care_site_id, person_source_value, gender_source_value, 
gender_source_concept_id, race_source_value, race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id)

SELECT [NO] AS PERSON_ID, 
      GENDER_CONCEPT_ID = CASE
                        WHEN [GEN] = '1' THEN 8507
                        WHEN [GEN] = '2' THEN 8532
                        END,
      LEFT([RECU_FR_DD],4)-CONVERT(float, [AGE]) AS YEAR_OF_BIRTH, 
      MONTH_OF_BIRTH = NULL, 
      DAY_OF_BIRTH = NULL, 
	  TIME_OF_BIRTH = NULL,
      RACE_CONCEPT_ID = 0,
      ETHNICITY_CONCEPT_ID = 0, 
      LOCATION_ID = NULL, 
      PROVIDER_ID = NULL, 
      CARE_SITE_ID = NULL, 
      [NO] AS PERSON_SOURCE_VALUE,
      [GEN] AS GENDER_SOURCE_VALUE, 
	  GENDER_SOURCE_CONCEPT_ID = NULL,
      RACE_SOURCE_VALUE = NULL,
	  RACE_SOURCE_CONCEPT_ID = NULL,
      ETHNICITY_SOURCE_VALUE = NULL,
	  ETHNICITY_SOURCE_CONCEPT_ID = NULL
FROM [TBL_20]
--==================================================================================================================================================================
-- VISIT_OCCURRENCE 테이블------------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE VISIT_OCCURRENCE 
    ( 
     visit_occurrence_id			VARCHAR(50)		NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     visit_concept_id				INTEGER			NOT NULL , 
	 visit_start_date				DATE			NOT NULL , 
	 visit_start_time				VARCHAR(20)		NULL ,
     visit_end_date					DATE			NOT NULL ,
	 visit_end_time					VARCHAR(20)		NULL , 
	 visit_type_concept_id			INTEGER			NOT NULL ,
	 provider_id					INTEGER			NULL,
     care_site_id					INTEGER			NULL, 
     visit_source_value				VARCHAR(50)		NULL,
	 visit_source_concept_id		INTEGER			NULL
    ) 
;
--==================================================================================================================================================================
insert into VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_time, visit_end_date, 
visit_end_time, visit_type_concept_id, provider_id, care_site_id, visit_source_value, visit_source_concept_id)	
		 
SELECT [KEYCODE] AS VISIT_OCCURRENCE_ID,
	[NO] AS PERSON_ID, 
	VISIT_CONCEPT_ID=CASE
		WHEN [FORM_CD] IN (2,4,6,7,10,12) THEN 9201
		WHEN [FORM_CD] IN (3,5,8,11,13,99) THEN 9202
		ELSE 0
		END,
	CONVERT(VARCHAR, [RECU_FR_DD], 23) AS VISIT_START_DATE, 
	VISIT_START_TIME = NULL,
	CONVERT(VARCHAR, DATEADD(DAY, [RECN]-1, [RECU_FR_DD]),23) AS VISIT_END_DATE,
	VISIT_END_TIME = NULL,
	VISIT_TYPE_CONCEPT_ID= 44818517,
	PROVIDER_ID = NULL,
	[YNO] AS CARE_SITE_ID,
	[FORM_CD] AS VISIT_SOURCE_VALUE,
	VISIT_SOURCE_CONCEPT_ID = NULL 
	FROM [TBL_20]
--==================================================================================================================================================================
-- CONDITION OCCURRENCE 테이블  ------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE CONDITION_OCCURRENCE 
    ( 
     condition_occurrence_id		VARCHAR(50)		identity(1,1)		NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     condition_concept_id			INTEGER			NOT NULL , 
     condition_start_date			DATE			NOT NULL , 
     condition_end_date				DATE			NULL , 
     condition_type_concept_id		INTEGER			NOT NULL , 
     stop_reason					VARCHAR(20)		NULL , 
     provider_id					INTEGER			NULL , 
     visit_occurrence_id			VARCHAR(50)			NULL , 
     condition_source_value			VARCHAR(50)		NULL ,
	 condition_source_concept_id	INTEGER			NULL
    ) 
--==================================================================================================================================================================
INSERT INTO CONDITION_OCCURRENCE(person_id, condition_concept_id, condition_start_date, zzcondition_end_date,condition_type_concept_id, 
stop_reason, provider_id, visit_occurrence_id, condition_source_value, condition_source_concept_id)

  SELECT A.[NO] AS PERSON_ID, 
		CONDITION_CONCEPT_ID = B.[DMD_SICK_SYM],
		CONVERT(datetime, A.[RECU_FR_DD]) AS CONDITION_START_DATE, 
		CONDITION_END_DATE = CASE
								WHEN [DIF] = '1' THEN Dateadd(DAY, A.[RECU_FR_DD]-1, A.[RECN])
 								ELSE Dateadd(DAY, A.[RECU_FR_DD], A.[RECN])
								END,, 
        CONDITION_TYPE_CONCEPT_ID = CASE
								WHEN A.[FOM_CD] = '1' THEN 38000184
								ELSE 38000215
								END,
        STOP_REASON = NULL,
        PROVIDER_ID = NULL,
        VISIT_OCCURRENCE_ID = A.[KEYCODE], 
        CONDITION_SOURCE_VALUE = B.[DMD_SICK_SYM],
		CONDITION_SOURCE_CONCEPT_ID = 0
	FROM [TBL_20] AS A 
	JOIN [TBL_30] AS B
		ON A.[KEYCODE] = B.[KEYCODE]	
		
  
--==================================================================================================================================================================
-- DRUG EXPOSURE 테이블  -------------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE PROC drug_exposure
AS

 CREATE TABLE DRUG_EXPOSURE 
    ( 
     drug_exposure_id				VARCHAR(50)	 	NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     drug_concept_id				INTEGER			NOT NULL , 
     drug_exposure_start_date		DATE			NOT NULL , 
     drug_exposure_end_date			DATE			NULL , 
     drug_type_concept_id			INTEGER			NOT NULL , 
     stop_reason					VARCHAR(20)		NULL , 
     refills						INTEGER			NULL , 
     quantity						FLOAT			NULL , 
     days_supply					INTEGER			NULL , 
     sig							VARCHAR(MAX)	NULL , 
	 route_concept_id				INTEGER			NULL ,
	 effective_drug_dose			FLOAT			NULL ,
	 dose_unit_concept_id			INTEGER			NULL ,
	 lot_number						VARCHAR(50)		NULL ,
     provider_id					INTEGER			NULL , 
     visit_occurrence_id			VARCHAR(50)			NULL , 
     drug_source_value				VARCHAR(50)		NULL ,
	 drug_source_concept_id			INTEGER			NULL ,
	 route_source_value				VARCHAR(50)		NULL ,
	 dose_unit_source_value			VARCHAR(50)		NULL
    ) 
;
-- DROP TABLE DRUG_EXPOSURE
--==================================================================================================================================================================
insert into DRUG_EXPOSURE (drug_exposure_id,person_id,drug_concept_id,drug_exposure_start_date,drug_exposure_end_date,drug_type_concept_id,stop_reason,refills,
quantity,days_supply,sig,route_concept_id,effective_drug_dose,dose_unit_concept_id,lot_number,provider_id,
visit_occurrence_id,drug_source_value,drug_source_concept_id,route_source_value,dose_unit_source_value)

	SELECT A.CMN_KEY_30+''+A.MCARE_DESC_LN_NO AS DRUG_EXPOSURE_ID,
		A.INDI_DSCM_NO as PERSON_ID,
		DRUG_CONCEPT_ID = M.concept_id,
		DRUG_EXPOSURE_START_DATE = CONVERT(VARCHAR, A.MDCARE_STRT_DT, 23),
		DRUG_EXPOSURE_END_DATE= CONVERT(varchar, DATEADD(day, CAST(A.TOT_MCNT AS INTEGER)-1, convert(VARCHAR, A.MDCARE_STRT_DT ,23)),23),
		DRUG_TYPE_CONCEPT_ID = CASE 
					WHEN A.MCARE_TP_LCLAS_CD IN ('1','2') THEN 38000177
					WHEN A.MCARE_TP_LCLAS_CD = '3' THEN 38000175
					END,
		STOP_REASON = NULL,
		REFILLS = NULL,	
		QUANTITY = CAST(A.DD1_MQTY_FREQ AS FLOAT) * CAST(A.TOT_MCNT AS FLOAT) * CAST(A.TIME1_MDCT_CPCT AS FLOAT),
		DAYS_SUPPLY= CAST(A.TOT_MCNT AS INTEGER),
		SIG = NULL,
		ROUTE_CONCEPT_ID = NULL,
		EFFECTIVE_DRUG_DOSE = NULL, 
		DOSE_UNIT_CONCEPT_ID = NULL,
		LOT_NUMBER = NULL,
		PROVIDER_ID = NULL,
		VISIT_OCCURRENCE_ID = A.CMN_KEY_30,
		A.MCEXP_TYPE_CD AS DRUG_SOURCE_VALUE,
		DRUG_SOURCE_CONCEPT_ID = 0,
		ROUTE_SOURCE_VALUE = NULL, 
		DOSE_UNIT_SOURCE_VALUE = NULL 
	FROM [OHDSI_CDM_DRUG] A
	JOIN PERSON AS P
	ON A.INDI_DSCM_NO = P.PERSON_ID
	JOIN drug_edi_20160908 M
	ON A.MCARE_DIV_CD = M.source_code
	WHERE A.MCEXP_TYPE_CD = '3'
		-->(75528개 행이 영향을 받음) / 00:00:03
GO

--==================================================================================================================================================================
-- PROCEDURE_OCCURRENCE 테이블  ------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE PROCEDURE_OCCURRENCE 
    ( 
     procedure_occurrence_id		INTEGER			identity(1,1) NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     procedure_concept_id			INTEGER			NOT NULL , 
     procedure_date					DATE			NOT NULL , 
     procedure_type_concept_id		INTEGER			NOT NULL ,
	 modifier_concept_id			INTEGER			NULL ,
	 quantity						INTEGER			NULL , 
     provider_id					INTEGER			NULL , 
     visit_occurrence_id			VARCHAR(50)			NULL , 
     procedure_source_value			VARCHAR(50)		NULL ,
	 procedure_source_concept_id	INTEGER			NULL ,
	 qualifier_source_value			VARCHAR(50)		NULL
    )
;
--DROP TABLE PROCEDURE_OCCURRENCE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
SET IDENTITY_INSERT PROCEDURE_OCCURRENCE ON
insert into PROCEDURE_OCCURRENCE (procedure_occurrence_id, person_id, procedure_concept_id, procedure_date, procedure_type_concept_id, modifier_concept_id, quantity, provider_id,
visit_occurrence_id, procedure_source_value, procedure_source_concept_id, qualifier_source_value)
SELECT  A.CMN_KEY_30+''+A.MCARE_DESC_LN_NO AS PROCEDURE_OCCURRENCE_ID,
	A.INDI_DSCM_NO as PERSON_ID,
	A.MCARE_DIV_CD AS PROCEDURE_CONCEPT_ID, 
	PROCEDURE_DATE =  CONVERT(VARCHAR, A.MDCARE_STRT_DT ,23),
	PROCEDURE_TYPE_CONCEPT_ID='38000275',
	MODIFIER_CONCEPT_ID=NULL,
	QUANTITY= CAST(A.DD1_MQTY_FREQ AS FLOAT) * CAST(A.TOT_MCNT AS FLOAT) * CAST(A.TIME1_MDCT_CPCT AS FLOAT),
	PROVIDER_ID=NULL,
	VISIT_OCCURRENCE_ID=A.CMN_KEY_30,
	PROCEDURE_SOURCE_VALUE = A.MCARE_DIV_CD,
	PROCEDURE_SOURCE_CONCEPT_ID = NULL,
	QUALIFIER_SOURCE_VALUE = NULL
FROM [dbo].[OHDSI_CDM_PROCEDURE] A
	JOIN PERSON AS P
	ON A.INDI_DSCM_NO = P.PERSON_ID
WHERE A.MCEX_TYPE_CD IN ('1','2','5')
-- (#개 행이 영향을 받음) 
*/

--==================================================================================================================================================================
------- CARE_SITE 테이블  ------------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE CARE_SITE 
    ( 
     care_site_id						INTEGER	    	NOT NULL, 
	 care_site_name						VARCHAR(255)	NULL ,
     place_of_service_concept_id		INTEGER			NULL ,
     location_id						VARCHAR(50)			NULL , 
     care_site_source_value				VARCHAR(50)		NULL , 
     place_of_service_source_value		VARCHAR(50)		NULL
    ) 
;
-- DROP TABLE CARE_SITE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO CARE_SITE (care_site_id,care_site_name,place_of_service_concept_id,
location_id,care_site_source_value,place_of_service_source_value)
SELECT 
	care_site_id = YKIHO,
	care_site_name = MDCARE_ADMIN_NM,
	place_of_service_concept_id = YOYANG_CLSFC_CD,
	location_id = SI_DO_SI_GUN_GU_CD,
	care_site_source_value = YKIHO,
	place_of_service_source_value = YOYANG_CLSFC_CD
FROM [dbo].[OHDSI_CDM_CARE_SITE]
-- (188814개 행이 영향을 받음) / 00:00:46

--==================================================================================================================================================================
-------- MEASUREMENT 테이블  ---------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE PROC measurement
AS
CREATE TABLE MEASUREMENT 
    ( 
     measurement_id					VARCHAR(50)		NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     measurement_concept_id			INTEGER			NOT NULL , 
     measurement_date				DATE			NOT NULL , 
     measurement_time				VARCHAR(10)		NULL ,
	 measurement_type_concept_id	INTEGER			NOT NULL ,
	 operator_concept_id			INTEGER			NULL , 
     value_as_number				FLOAT			NULL , 
     value_as_concept_id			INTEGER			NULL , 
     unit_concept_id				INTEGER			NULL , 
     range_low						FLOAT			NULL , 
     range_high						FLOAT			NULL , 
     provider_id					INTEGER			NULL , 
     visit_occurrence_id			VARCHAR(50)			NULL ,  
     measurement_source_value		VARCHAR(50)		NULL , 
	 measurement_source_concept_id	INTEGER			NULL ,
     unit_source_value				VARCHAR(50)		NULL ,
	 value_source_value				VARCHAR(50)		NULL
    ) 
;
-- DROP TABLE MEASUREMENT

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO MEASUREMENT
(measurement_id, person_id, measurement_concept_id, measurement_date, measurement_time, measurement_type_concept_id, operator_concept_id, value_as_number, value_as_concept_id, 
 unit_concept_id, range_low, range_high, provider_id, visit_occurrence_id, measurement_source_value, measurement_source_concept_id, unit_source_value, value_source_value) 
 SELECT 
	A.EXMD_BZ_YYYY+''+A.EXMDM_NO+''+A.EXMDM_SEQ AS MEASUREMENT_ID,
	A.INDI_DSCM_NO AS PERSON_ID,
	MEASUREMENT_CONCEPT_ID = M.concept_id,
	MEASUREMENT_DATE = CONVERT(VARCHAR, A.HME_DT ,23),
	MEASUREMENT_TIME = NULL,
	MEASUREMENT_TYPE_CONCEPT_ID = '44818702', -- Lab result
	-- MEASUREMENT_TYPE_CONCEPT_ID = '44818701', -- From physical examination
	OPERATOR_CONCEPT_ID = NULL,
	VALUE_AS_NUMBER =CASE 
					WHEN M.VALUE_TYPE = 'num' THEN A.HME_ISPT_RSLT_VL
					END,
	VALUE_AS_CONCEPT_ID = CASE 
					WHEN M.VALUE_TYPE = 'char' THEN V.VALUE_CONCEPT_ID
					END,
	UNIT_CONCEPT_ID = M.UNIT_CONCEPT_ID,
	RANGE_LOW = A.EXMD_BZ_YYYY-P.[year_of_birth],
	RANGE_HIGH = P.[gender_source_value], 
	PROVIDER_ID = NULL,
	VISIT_OCCURRENCE_ID = NULL,
	MEASUREMENT_SOURCE_VALUE = A.HMEI_CD,
	MEASUREMENT_SOURCE_CONCEPT_ID = NULL,
	UNITS_SOURCE_VALUE = NULL,
	VALUE_SOURCE_VALUE = A.HME_ISPT_RSLT_VL
	FROM [dbo].[OHDSI_CDM_MEASUREMENT] A
	JOIN PERSON AS P
		ON A.INDI_DSCM_NO = P.PERSON_ID
	JOIN Measurement_examcode_20160908 M
		ON A.HMEI_CD = M.source_code
	LEFT JOIN Measurement_value_20160907 V
	ON M.CONCEPT_ID = V.CONCEPT_ID
	AND A.HME_ISPT_RSLT_VL = V.VALUE;
	-- (221개 행이 영향을 받음)

CREATE INDEX MEASUREMENT_IDX ON MEASUREMENT
(PERSON_ID,MEASUREMENT_DATE);
-- Add health examination visit data
insert into VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_time, visit_end_date, 
visit_end_time, visit_type_concept_id, provider_id, care_site_id, visit_source_value, visit_source_concept_id)	
SELECT VISIT_OCCURRENCE_ID = ROW_NUMBER()OVER(ORDER BY PERSON_ID),
	PERSON_ID AS PERSON_ID, 
	VISIT_CONCEPT_ID=9202,
	VISIT_START_DATE = [measurement_date], 
	VISIT_START_TIME = NULL,
	VISIT_END_DATE = [measurement_date],
	VISIT_END_TIME = NULL,
	VISIT_TYPE_CONCEPT_ID= 44818517,
	PROVIDER_ID = NULL,
	CARE_SITE_ID = NULL,
	VISIT_SOURCE_VALUE = 'Health Examination',
	VISIT_SOURCE_CONCEPT_ID = NULL 
	FROM [dbo].[MEASUREMENT];
	--(170개 행이 영향을 받음)
GO

/*
--==================================================================================================================================================================
-------- OBSERVATION 테이블  ---------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE OBSERVATION  
    ( 
     observation_id					INTEGER		identity(1,1) 	NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     observation_concept_id			INTEGER			NOT NULL , 
     observation_date				DATE			NOT NULL , 
     observation_time				VARCHAR(10)		NULL , 
     observation_type_concept_id	INTEGER			NOT NULL , 
	 value_as_number				FLOAT			NULL , 
     value_as_string				VARCHAR(MAX)	NULL , 
     value_as_concept_id			INTEGER			NULL , 
	 qualifier_concept_id			INTEGER			NULL ,
     unit_concept_id				INTEGER			NULL , 
     provider_id					INTEGER			NULL , 
     visit_occurrence_id			VARCHAR(50)			NULL , 
     observation_source_value		VARCHAR(50)		NULL ,
	 observation_source_concept_id	INTEGER			NULL , 
     unit_source_value				VARCHAR(50)		NULL ,
	 qualifier_source_value			VARCHAR(50)		NULL
    ) 
;
-- DROP TABLE OBSERVATION
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO OBSERVATION (observation_id, person_id, observation_concept_id, observation_date, observation_time, observation_type_concept_id, value_as_number,
value_as_string, value_as_concept_id, qualifier_concept_id, unit_concept_id, provider_id, visit_occurrence_id, observation_source_value,
observation_source_concept_id, unit_source_value, qualifier_source_value)
	SELECT	
		CAST((A.EXMD_BZ_YYYY+''+A.EXMDM_NO+''+A.EXMDM_SEQ) AS INTEGER) AS OBSERVATION_ID,
		A.INDI_DSCM_NO AS PERSON_ID, 
		OBSERVATION_CONCEPT_ID = M.concept_id, 
		convert(VARCHAR, A.HME_DT, 23) AS OBSERVATION_DATE,
		observation_time = NULL,
		OBSERVATION_TYPE_CONCEPT_ID = 44814721, 
		value_as_number = NULL,
		VALUE_AS_STRING = A.MELQI_WRT_RMK,
		value_as_concept_id= NULL,
		qualifier_concept_id = NULL, 
		unit_concept_id= NULL,
		provider_id= NULL,
		visit_occurrence_id= NULL,
		OBSERVATION_SOURCE_VALUE = A.MELQI_CD,
		observation_source_concept_id = NULL,
		unit_source_value= NULL,
		qualifier_source_value = NULL					
		FROM [dbo].[OHDSI_CDM_OBSERVATION] A
		JOIN PERSON AS P
			ON A.INDI_DSCM_NO = P.PERSON_ID
		JOIN Measurement_examcode_20160908 M
			ON A.MELQI_CD = M.source_code

begin tran
UPDATE OBSERVATION
  SET VISIT_OCCURRENCE_ID = B.VISIT_OCCURRENCE_ID
  FROM OBSERVATION AS A 
  INNER JOIN VISIT_OCCURRENCE AS B 
  ON A.PERSON_ID = B.PERSON_ID
	AND A.OBSERVATION_DATE BETWEEN B.VISIT_START_DATE AND B.VISIT_END_DATE 
	AND a.VISIT_OCCURRENCE_ID is null
	-- (22122446개 행이 영향을 받음)
commit
 
CREATE INDEX OBSERVATION_IDX ON OBSERVATION
(PERSON_ID,MEASUREMENT_DATE)

select * from PROCEDURE_OCCURRENCE where VISIT_OCCURRENCE_ID is null
--(개 행이 영향을 받음)

*/
--==================================================================================================================================================================
-------- PAYER_PLAN_PERIOD 테이블  ---------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE PAYER_PLAN_PERIOD  
    (
     payer_plan_period_id				INTEGER	 identity(1,1)		NOT NULL , 
     person_id							INTEGER						NOT NULL ,
     payer_plan_period_start_date		DATE						NOT NULL ,
     payer_plan_period_end_date			DATE						NOT NULL ,
     payer_source_value					VARCHAR(50) 				NULL,  
     plan_source_value					VARCHAR(50) 				NULL,  
	 family_source_value				VARCHAR(50) 				NULL   
	)
 ; -- DROP TABLE PAYER_PLAN_PERIOD
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--SET IDENTITY_INSERT PAYER_PLAN_PERIOD ON
insert into PAYER_PLAN_PERIOD 
(person_id, payer_plan_period_start_date, payer_plan_period_end_date, payer_source_value, plan_source_value, family_source_value)
select INDI_DSCM_NO as person_id,
convert(VARCHAR, BDAY, 23) as payer_plan_period_start_date,
payer_plan_period_end_date = '9999-12-31',
payer_source_value = 'National Health Insurance Service',
plan_source_value = 'National Health Insurance',
family_source_value = null
FROM OHDSI_CDM_PERSON
--SET IDENTITY_INSERT PAYER_PLAN_PERIOD OFF
--==================================================================================================================================================================
------------ 기타 테이블  ------------------------------------------------------------------------------------------------------------------------------------------
--==================================================================================================================================================================
CREATE TABLE observation_period 
    ( 
     observation_period_id				INTEGER		NOT NULL , 
     person_id							INTEGER		NOT NULL , 
     observation_period_start_date		DATE		NOT NULL , 
     observation_period_end_date		DATE		NOT NULL ,
	 period_type_concept_id				INTEGER		NOT NULL
    ) 
;

CREATE TABLE specimen
    ( 
     specimen_id						INTEGER			NOT NULL ,
	 person_id							INTEGER			NOT NULL ,
	 specimen_concept_id				INTEGER			NOT NULL ,
	 specimen_type_concept_id			INTEGER			NOT NULL ,
	 specimen_date						DATE			NOT NULL ,
	 specimen_time						VARCHAR(10)		NULL ,
	 quantity							FLOAT			NULL ,
	 unit_concept_id					INTEGER			NULL ,
	 anatomic_site_concept_id			INTEGER			NULL ,
	 disease_status_concept_id			INTEGER			NULL ,
	 specimen_source_id					VARCHAR(50)		NULL ,
	 specimen_source_value				VARCHAR(50)		NULL ,
	 unit_source_value					VARCHAR(50)		NULL ,
	 anatomic_site_source_value			VARCHAR(50)		NULL ,
	 disease_status_source_value		VARCHAR(50)		NULL
	)
;

CREATE TABLE note 
    ( 
     note_id						INTEGER			NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     note_date						DATE			NOT NULL ,
	 note_time						VARCHAR(10)		NULL ,
	 note_type_concept_id			INTEGER			NOT NULL ,
	 note_text						VARCHAR(MAX)	NOT NULL ,
     provider_id					INTEGER			NULL ,
	 visit_occurrence_id			VARCHAR(50)			NULL ,
	 note_source_value				VARCHAR(50)		NULL
    ) 
;

CREATE TABLE provider 
    ( 
     provider_id					INTEGER			NOT NULL ,
	 provider_name					VARCHAR(255)	NULL , 
     NPI							VARCHAR(20)		NULL , 
     DEA							VARCHAR(20)		NULL , 
     specialty_concept_id			INTEGER			NULL , 
     care_site_id					INTEGER			NULL , 
	 year_of_birth					INTEGER			NULL ,
	 gender_concept_id				INTEGER			NULL ,
     provider_source_value			VARCHAR(50)		NULL , 
     specialty_source_value			VARCHAR(50)		NULL ,
	 specialty_source_concept_id	INTEGER			NULL , 
	 gender_source_value			VARCHAR(50)		NULL ,
	 gender_source_concept_id		INTEGER			NULL
    ) 
;

CREATE TABLE visit_cost 
    ( 
     visit_cost_id					INTEGER			NOT NULL , 
     visit_occurrence_id			VARCHAR(50)			NOT NULL , 
	 currency_concept_id			INTEGER			NULL ,
     paid_copay						FLOAT			NULL , 
     paid_coinsurance				FLOAT			NULL , 
     paid_toward_deductible			FLOAT			NULL , 
     paid_by_payer					FLOAT			NULL , 
     paid_by_coordination_benefits	FLOAT			NULL , 
     total_out_of_pocket			FLOAT			NULL , 
     total_paid						FLOAT			NULL ,  
     payer_plan_period_id			INTEGER			NULL
    ) 
;

CREATE TABLE procedure_cost 
    ( 
     procedure_cost_id				INTEGER			NOT NULL , 
     procedure_occurrence_id		INTEGER			NOT NULL , 
     currency_concept_id			INTEGER			NULL ,
     paid_copay						FLOAT			NULL , 
     paid_coinsurance				FLOAT			NULL , 
     paid_toward_deductible			FLOAT			NULL , 
     paid_by_payer					FLOAT			NULL , 
     paid_by_coordination_benefits	FLOAT			NULL , 
     total_out_of_pocket			FLOAT			NULL , 
     total_paid						FLOAT			NULL ,
	 revenue_code_concept_id		INTEGER			NULL ,  
     payer_plan_period_id			INTEGER			NULL ,
	 revenue_code_source_value		VARCHAR(50)		NULL
	) 
;

CREATE TABLE drug_cost 
    (
     drug_cost_id					INTEGER			NOT NULL , 
     drug_exposure_id				INTEGER			NOT NULL , 
     currency_concept_id			INTEGER			NULL ,
     paid_copay						FLOAT			NULL , 
     paid_coinsurance				FLOAT			NULL , 
     paid_toward_deductible			FLOAT			NULL , 
     paid_by_payer					FLOAT			NULL , 
     paid_by_coordination_benefits	FLOAT			NULL , 
     total_out_of_pocket			FLOAT			NULL , 
     total_paid						FLOAT			NULL , 
     ingredient_cost				FLOAT			NULL , 
     dispensing_fee					FLOAT			NULL , 
     average_wholesale_price		FLOAT			NULL , 
     payer_plan_period_id			INTEGER			NULL
    ) 
;

CREATE TABLE device_cost 
    (
     device_cost_id					INTEGER			NOT NULL , 
     device_exposure_id				INTEGER			NOT NULL , 
     currency_concept_id			INTEGER			NULL ,
     paid_copay						FLOAT			NULL , 
     paid_coinsurance				FLOAT			NULL , 
     paid_toward_deductible			FLOAT			NULL , 
     paid_by_payer					FLOAT			NULL , 
     paid_by_coordination_benefits	FLOAT			NULL , 
     total_out_of_pocket			FLOAT			NULL , 
     total_paid						FLOAT			NULL , 
     payer_plan_period_id			INTEGER			NULL
    ) 
;

CREATE TABLE cost 
    (
     cost_id					INTEGER	    NOT NULL , 
     cost_event_id       INTEGER     NOT NULL ,
     cost_domain_id       VARCHAR(20)    NOT NULL ,
     cost_type_concept_id       INTEGER     NOT NULL ,
     currency_concept_id			INTEGER			NULL ,
     total_charge						FLOAT			NULL , 
     total_cost						FLOAT			NULL , 
     total_paid						FLOAT			NULL , 
     paid_by_payer					FLOAT			NULL , 
     paid_by_patient						FLOAT			NULL , 
     paid_patient_copay						FLOAT			NULL , 
     paid_patient_coinsurance				FLOAT			NULL , 
     paid_patient_deductible			FLOAT			NULL , 
     paid_by_primary						FLOAT			NULL , 
     paid_ingredient_cost				FLOAT			NULL , 
     paid_dispensing_fee					FLOAT			NULL , 
     payer_plan_period_id			INTEGER			NULL ,
     amount_allowed		FLOAT			NULL , 
     revenue_code_concept_id		INTEGER			NULL , 
     reveue_code_source_value    VARCHAR(50)    NULL
    ) 
;

CREATE TABLE cohort 
    ( 
	 cohort_definition_id			INTEGER			NOT NULL , 
     subject_id						INTEGER			NOT NULL ,
	 cohort_start_date				DATE			NOT NULL , 
     cohort_end_date				DATE			NOT NULL
    ) 
;

CREATE TABLE cohort_attribute 
    ( 
	 cohort_definition_id			INTEGER			NOT NULL , 
     cohort_start_date				DATE			NOT NULL , 
     cohort_end_date				DATE			NOT NULL , 
     subject_id						INTEGER			NOT NULL , 
     attribute_definition_id		INTEGER			NOT NULL ,
	 value_as_number				FLOAT			NULL ,
	 value_as_concept_id			INTEGER			NULL
    ) 
;

CREATE TABLE drug_era 
    ( 
     drug_era_id					INTEGER			NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     drug_concept_id				INTEGER			NOT NULL , 
     drug_era_start_date			DATE			NOT NULL , 
     drug_era_end_date				DATE			NOT NULL , 
     drug_exposure_count			INTEGER			NULL ,
	 gap_days						INTEGER			NULL
    ) 
;

CREATE TABLE dose_era 
    (
     dose_era_id					INTEGER			NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     drug_concept_id				INTEGER			NOT NULL , 
	 unit_concept_id				INTEGER			NOT NULL ,
	 dose_value						FLOAT			NOT NULL ,
     dose_era_start_date			DATE			NOT NULL , 
     dose_era_end_date				DATE			NOT NULL 
    ) 
;

CREATE TABLE condition_era 
    ( 
     condition_era_id				INTEGER			NOT NULL , 
     person_id						INTEGER			NOT NULL , 
     condition_concept_id			INTEGER			NOT NULL , 
     condition_era_start_date		DATE			NOT NULL , 
     condition_era_end_date			DATE			NOT NULL , 
     condition_occurrence_count		INTEGER			NULL
    ) 
;
