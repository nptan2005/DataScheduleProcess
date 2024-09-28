-- Create table
create table VCCB_ACQ_BANK_BENEFIT_ACCT
(
  bank_name                 VARCHAR2(250),
  acq_bank_code             VARCHAR2(10),
  tax_code                  VARCHAR2(50),
  address                   VARCHAR2(500),
  contract                  VARCHAR2(50),
  nostro_account            VARCHAR2(20),
  clearing_branch_code      VARCHAR2(15),
  clearing_account_number   VARCHAR2(30),
  clearing_account_name     VARCHAR2(250),
  suspense_branh_code       VARCHAR2(15),
  suspense_account_number   VARCHAR2(30),
  suspense_account_name     VARCHAR2(250),
  receivable_branch_code    VARCHAR2(15),
  receivable_account_number VARCHAR2(30),
  receivable_account_name   VARCHAR2(250),
  payable_branch_code       VARCHAR2(15),
  payable_account_number    VARCHAR2(30),
  payable_account_name      VARCHAR2(250),
  deposit_branch_code       VARCHAR2(15),
  deposit_account_number    VARCHAR2(30),
  deposit_account_name      VARCHAR2(250),
  active                    NUMBER(1),
  is_process_imp            NUMBER(1),
  start_date                DATE,
  end_date                  DATE,
  file_id                   NUMBER(10),
  imp_rec_id                NUMBER(22),
  import_date               DATE,
  rec_updated_date          DATE
)
;
-- Create/Recreate indexes 
create index VCCB_ACQ_BANK_BENEFIT_ACCT_IDX on VCCB_ACQ_BANK_BENEFIT_ACCT (ACQ_BANK_CODE);
