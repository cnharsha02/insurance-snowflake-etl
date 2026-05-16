
/* ============================================================
   STEP 2: JOIN + FILTER LOGIC
   Purpose: Combine source tables and apply business filters
   ============================================================ */

-- ✅ Ensure correct context
USE DATABASE INSURANCE_DB;
USE SCHEMA INSURANCE_SCHEMA;

---------------------------------------------------------------
-- STEP 2.1: BASIC JOIN (CUSTOMER → POLICY → CLAIMS)
---------------------------------------------------------------

SELECT 
    C.CUSTOMER_ID,
    C.INSURED_FIRST_NAME,
    C.INSURED_LAST_NAME,
    P.POLICY_NUMBER,
    CL.CLAIM_ID,
    CL.CLAIM_AMOUNT,
    CL.CRT_UID_C,
    CL.SUB_AGT_N,
    CL.PROD_TY_C,
    CL.RPT_D
FROM CUSTOMER C
JOIN POLICY P
  ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL
  ON P.POLICY_NUMBER = CL.POLICY_NUMBER;


---------------------------------------------------------------
-- STEP 2.2: APPLY BUSINESS FILTERS
---------------------------------------------------------------

SELECT 
    C.CUSTOMER_ID,
    C.INSURED_FIRST_NAME,
    C.INSURED_LAST_NAME,
    P.POLICY_NUMBER,
    CL.CLAIM_ID,
    CL.CLAIM_AMOUNT,
    CL.CRT_UID_C,
    CL.SUB_AGT_N,
    CL.PROD_TY_C,
    CL.RPT_D
FROM CUSTOMER C
JOIN POLICY P
  ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL
  ON P.POLICY_NUMBER = CL.POLICY_NUMBER

-- ✅ Business Filters (from STM document)
WHERE CL.CRT_UID_C <> 'WEB'
  AND CL.SUB_AGT_N IN ('00000','99999')
  AND CL.PROD_TY_C = 'M';


---------------------------------------------------------------
-- STEP 2.3: VALIDATION CHECKS
---------------------------------------------------------------

-- ✅ Check total records after filtering
SELECT COUNT(*) AS FILTERED_RECORD_COUNT
FROM CUSTOMER C
JOIN POLICY P
  ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL
  ON P.POLICY_NUMBER = CL.POLICY_NUMBER
WHERE CL.CRT_UID_C <> 'WEB'
  AND CL.SUB_AGT_N IN ('00000','99999')
  AND CL.PROD_TY_C = 'M';


-- ✅ View filtered data
SELECT *
FROM CUSTOMER C
JOIN POLICY P
  ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL
  ON P.POLICY_NUMBER = CL.POLICY_NUMBER
WHERE CL.CRT_UID_C <> 'WEB'
  AND CL.SUB_AGT_N IN ('00000','99999')
  AND CL.PROD_TY_C = 'M';
