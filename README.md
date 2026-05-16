
# 🏢 Insurance Data Engineering Pipeline (Snowflake)

## 📌 Project Overview
This project demonstrates an end-to-end ETL pipeline built using Snowflake based on a Source-to-Target Mapping (STM) document. The objective is to transform raw insurance data from multiple source tables into a clean, analytics-ready data warehouse table.

---

## 🛠️ Tech Stack
- Snowflake
- SQL
- Data Warehousing (ETL/ELT Concepts)
- GitHub (Version Control)

---

## 📊 Source System (OLTP Tables)

The following source tables are used:

| Table Name | Description |
|-----------|------------|
| CUSTOMER | Stores customer demographic and personal details |
| POLICY | Stores insurance policy information |
| COVERAGE | Stores coverage type and amount |
| CLAIMS | Stores claim details including amount and reporting data |

---

## 🔗 Data Model / Relationships
CUSTOMER → POLICY → CLAIMS

CUSTOMER → POLICY → CLAIMS

- CUSTOMER connects to POLICY using `CUSTOMER_ID`
- POLICY connects to CLAIMS using `POLICY_NUMBER`

---

## ⚙️ ETL Pipeline Architecture


Raw Data → Join → Filter → Transform → Load → Analytics Table

---

## 🚀 ETL Pipeline Steps

---

### Step 1: Data Setup
- Created database `INSURANCE_DB`
- Created schema `INSURANCE_SCHEMA`
- Created source tables (CUSTOMER, POLICY, COVERAGE, CLAIMS)
- Loaded sample data

📂 File:

sql/step1_setup.sql

---

### Step 2: Join & Filter Logic
- Joined CUSTOMER, POLICY, and CLAIMS tables
- Applied business filters:
  - Excluded records where `CRT_UID_C = 'WEB'`
  - Selected only valid sub-agent records (`00000`, `99999`)
  - Filtered for product type `'M'`

📂 File:

sql/step2_join_filter.sql

---

###  Step 3: Data Transformations (STM Implementation)

Applied business logic using transformations:

- Eligibility Mapping:
  - `El → Eligible`
  - `En → Enrolled`

- Customer Segmentation:
  - `SC → Signature`
  - `VP → VIP`
  - Others → Portfolio

- Policy Key Generation
- Coverage Bucketing:
  - Less than $1M
  - $1M to $5M
  - $5M to $10M
  - More than $10M

- Data Quality Flags:
  - CRT Filter Flag
  - Sub-Agent Flag
  - Product Type Flag
  - Max Report Date Flag

📂 File:

sql/step3_transformations.sql

---

###  Step 4: Final Data Warehouse Table
- Created target schema: `DW_INSURANCE`
- Built final analytics table:


DW_INSURANCE.POSITIONS

- Loaded transformed data using CTAS (Create Table As Select)

📂 File:

sql/step4_final_load.sql

---

## 📈 Final Output

### 🎯 Target Table:

DW_INSURANCE.POSITIONS

### Features:
- Cleaned and filtered data
- Business rule transformations applied
- Joined multi-source dataset
- Analytics-ready table for reporting

---

##  Data Validation

- Verified record counts after filtering
- Removed unwanted records (WEB data)
- Ensured latest reporting data per policy
- Validated transformation outputs

---

## 🧠 Key Learnings

- Designed end-to-end ETL pipeline in Snowflake
- Implemented Source-to-Target Mapping (STM)
- Performed multi-table joins and filtering
- Applied business transformations using SQL
- Built data warehouse table using CTAS
- Structured project professionally in GitHub

---

## 🚀 Future Enhancements

- Implement incremental loading using Streams
- Add automation using Tasks
- Integrate dbt for transformation management
- Add data quality checks and logging
- Schedule pipeline execution

---

## 👨‍💻 Author

**Harsha C N**  
Data Engineer  
Bangalore, India

