
/* ============================================================
   STEP 4: FINAL LOAD INTO DATA WAREHOUSE TABLE
   Target: DW_INSURANCE.POSITIONS
   Purpose: Create analytics-ready dataset using CTAS
   ============================================================ */

---------------------------------------------------------------
-- STEP 4.1: CREATE TARGET SCHEMA
---------------------------------------------------------------

CREATE OR REPLACE SCHEMA DW_INSURANCE;

---------------------------------------------------------------
-- STEP 4.2: CREATE FINAL TABLE USING CTAS
---------------------------------------------------------------

CREATE OR REPLACE TABLE DW_INSURANCE.POSITIONS AS

SELECT
    C.CUSTOMER_ID,

    --  ELIGIBILITY STATUS
    CASE 
        WHEN C.STATUS = 'El' THEN 'Eligible'
        WHEN C.STATUS = 'En' THEN 'Enrolled'
    END AS ELIGIBILITY_STATUS,

    --  CUSTOMER SEGMENT
    CASE 
        WHEN C.SEGMENTATION = 'SC' THEN 'Signature'
        WHEN C.SEGMENTATION = 'VP' THEN 'VIP'
        ELSE 'Portfolio'
    END AS CUSTOMER_SEGMENT,

    -- POLICY KEY
    CONCAT('POL', LPAD(REPLACE(P.POLICY_NUMBER,'POL',''), 3, '0')) AS POLICY_KEY,

    --  DERIVED POLICY
    CONCAT(
        SUBSTR(P.POLICY_NUMBER, 3, 6),
        '-',
        SUBSTR(P.POLICY_NUMBER, 6)
    ) AS DERIVED_POLICY,

    --  COVERAGE BUCKET
    CASE 
        WHEN TO_NUMBER(SPLIT_PART(P.COVERAGE_RANGE, '-', 2)) < 1000000 
            THEN 'Less than $1M'
        WHEN TO_NUMBER(SPLIT_PART(P.COVERAGE_RANGE, '-', 2)) BETWEEN 1000000 AND 4999999 
            THEN '$1M to $5M'
        WHEN TO_NUMBER(SPLIT_PART(P.COVERAGE_RANGE, '-', 2)) BETWEEN 5000000 AND 9999999 
            THEN '$5M to $10M'
        ELSE 'More than $10M'
    END AS COVERAGE_BUCKET,

    -- DIRECT FIELDS
    P.POLICY_NUMBER,
    C.RESIDENCE_STATE,
    C.CITY,
    C.ZIP_CODE,
    C.COUNTY,
    CL.WILDFIRE_DATE,
    CL.CLAIM_AMOUNT,

    -- FLAGS (FROM STM)
    CASE WHEN CL.CRT_UID_C <> 'WEB' THEN 'Y' ELSE 'N' END AS CRT_FILTER_FLAG,
    CASE WHEN CL.SUB_AGT_N IN ('00000','99999') THEN 'Y' ELSE 'N' END AS SUB_AGENT_FLAG,
    CASE WHEN CL.PROD_TY_C = 'M' THEN 'Y' ELSE 'N' END AS PROD_TYPE_FLAG,

    --  MAX REPORT FLAG
    CASE 
        WHEN CL.RPT_D = (
            SELECT MAX(C2.RPT_D)
            FROM CLAIMS C2
            WHERE C2.POLICY_NUMBER = CL.POLICY_NUMBER
              AND C2.PROD_TY_C = 'M'
        )
        THEN 'Y'
        ELSE 'N'
    END AS MAX_RPT_D_FLAG

FROM CUSTOMER C
JOIN POLICY P
  ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL
  ON P.POLICY_NUMBER = CL.POLICY_NUMBER

--  FINAL FILTER CONDITIONS (STM)
WHERE CL.CRT_UID_C <> 'WEB'
  AND CL.SUB_AGT_N IN ('00000','99999')
  AND CL.PROD_TY_C = 'M'
  AND CL.RPT_D = (
      SELECT MAX(C2.RPT_D)
      FROM CLAIMS C2
      WHERE C2.POLICY_NUMBER = CL.POLICY_NUMBER
        AND C2.PROD_TY_C = 'M'
  );

---------------------------------------------------------------
-- STEP 4.3: VALIDATION
---------------------------------------------------------------

--  Row count check
SELECT COUNT(*) AS FINAL_ROW_COUNT 
FROM DW_INSURANCE.POSITIONS;

--  View final data
SELECT * 
FROM DW_INSURANCE.POSITIONS;
