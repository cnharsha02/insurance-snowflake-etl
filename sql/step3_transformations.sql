
/* ============================================================
   STEP 3: TRANSFORMATIONS (STM IMPLEMENTATION)
   Purpose: Apply business rules & derive target-ready columns
   Source: Policy STM document
   ============================================================ */

-- ✅ Ensure correct context
USE DATABASE INSURANCE_DB;
USE SCHEMA INSURANCE_SCHEMA;

---------------------------------------------------------------
-- STEP 3.1: TRANSFORMED DATASET (WITH FILTERS + TRANSFORMS)
-- Filters from STM:
--   1) CRT_UID_C <> 'WEB'
--   2) SUB_AGT_N IN ('00000','99999')
--   3) PROD_TY_C = 'M'
--   4) RPT_D = MAX(RPT_D) per POLICY_NUMBER & PROD_TY_C='M'
---------------------------------------------------------------

SELECT
    /* ========== Direct Mapping ========== */
    C.CUSTOMER_ID,                                        -- STM: Direct mapping [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)
    P.POLICY_NUMBER,                                       -- Used for joins and target [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)
    C.RESIDENCE_STATE,
    C.CITY,
    C.ZIP_CODE,
    C.COUNTY,
    C.RESIDENCE_DESCRIPTION      AS RES_DESC,
    C.RESIDENCE_NUMBER           AS RES_NUMBER,
    C.FIRE_HYDRANT,
    C.PRIORITY_CODE,
    C.ZONE_CODE,
    C.OPT_OUT_INDICATOR          AS OPT_OUT_IND,
    CL.WILDFIRE_DATE,
    CL.CLAIM_AMOUNT,

    /* ========== Transformations from STM ========== */

    -- 1) ELIGIBILITY_STATUS from CUSTOMER.STATUS
    CASE
        WHEN C.STATUS = 'El' THEN 'Eligible'
        WHEN C.STATUS = 'En' THEN 'Enrolled'
        ELSE NULL
    END AS ELIGIBILITY_STATUS,                            -- STM rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

    -- 2) CUSTOMER_SEGMENT from CUSTOMER.SEGMENTATION
    CASE
        WHEN C.SEGMENTATION = 'SC' THEN 'Signature'
        WHEN C.SEGMENTATION = 'VP' THEN 'VIP'
        ELSE 'Portfolio'
    END AS CUSTOMER_SEGMENT,                              -- STM rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

    -- 3) POLICY_KEY
    -- STM says: convert policy number to 3 digits + add 'POL' on left [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)
    -- Our data already looks like 'POL001' etc, but this standardizes it safely.
    CONCAT('POL', LPAD(REPLACE(P.POLICY_NUMBER,'POL',''), 3, '0')) AS POLICY_KEY,

    -- 4) COVERAGE_BUCKET from POLICY.COVERAGE_RANGE
    -- STM defines bucket thresholds. COVERAGE_RANGE is text like '100000-500000' [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)[2](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/Documents/Microsoft%20Copilot%20Chat%20Files/policy%20tables.sql)
    CASE
        WHEN TO_NUMBER(SPLIT_PART(P.COVERAGE_RANGE, '-', 2)) < 1000000
            THEN 'Less than $1M'
        WHEN TO_NUMBER(SPLIT_PART(P.COVERAGE_RANGE, '-', 2)) BETWEEN 1000000 AND 4999999
            THEN '$1M to $5M'
        WHEN TO_NUMBER(SPLIT_PART(P.COVERAGE_RANGE, '-', 2)) BETWEEN 5000000 AND 9999999
            THEN '$5M to $10M'
        ELSE 'More than $10M'
    END AS COVERAGE_BUCKET,                               -- STM bucket rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

    /* ========== Filter flags from STM ========== */

    -- 5) CRT_FILTER_FLAG
    CASE
        WHEN CL.CRT_UID_C <> 'WEB' THEN 'Y'
        ELSE 'N'
    END AS CRT_FILTER_FLAG,                               -- STM flag rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

    -- 6) SUB_AGENT_FLAG
    CASE
        WHEN CL.SUB_AGT_N IN ('00000','99999') THEN 'Y'
        ELSE 'N'
    END AS SUB_AGENT_FLAG,                                -- STM flag rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

    -- 7) PROD_TYPE_FLAG
    CASE
        WHEN CL.PROD_TY_C = 'M' THEN 'Y'
        ELSE 'N'
    END AS PROD_TYPE_FLAG,                                -- STM flag rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

    -- 8) MAX_RPT_D_FLAG (latest report per policy for PROD_TY_C='M')
    CASE
        WHEN CL.RPT_D = (
            SELECT MAX(C2.RPT_D)
            FROM CLAIMS C2
            WHERE C2.POLICY_NUMBER = CL.POLICY_NUMBER
              AND C2.PROD_TY_C = 'M'
        )
        THEN 'Y'
        ELSE 'N'
    END AS MAX_RPT_D_FLAG                                 -- STM flag rule [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)

FROM CUSTOMER C
JOIN POLICY P
  ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL
  ON P.POLICY_NUMBER = CL.POLICY_NUMBER

-- ✅ Apply filters as specified in STM [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)
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
-- STEP 3.2: VALIDATION CHECKS
---------------------------------------------------------------

-- Expected to exclude WEB-created claim rows per STM [1](https://qccgrp-my.sharepoint.com/personal/harsha_qccgrp_com/_layouts/15/Doc.aspx?sourcedoc=%7B067F0380-69A6-46F3-B7C5-E8079794D666%7D&file=Policy%20STM%20document.xlsx&action=default&mobileredirect=true)
SELECT COUNT(*) AS TRANSFORMED_ROW_COUNT
FROM CUSTOMER C
JOIN POLICY P ON C.CUSTOMER_ID = P.CUSTOMER_ID
JOIN CLAIMS CL ON P.POLICY_NUMBER = CL.POLICY_NUMBER
WHERE CL.CRT_UID_C <> 'WEB'
  AND CL.SUB_AGT_N IN ('00000','99999')
  AND CL.PROD_TY_C = 'M'
  AND CL.RPT_D = (
      SELECT MAX(C2.RPT_D)
      FROM CLAIMS C2
      WHERE C2.POLICY_NUMBER = CL.POLICY_NUMBER
        AND C2.PROD_TY_C = 'M'
  );
