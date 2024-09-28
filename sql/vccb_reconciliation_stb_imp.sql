create table vccb_reconciliation_stb_imp
(
MERCHANT_ID varchar2(15),
MM_DBA_NAME varchar2(250),
TERMINAL_ID varchar2(15),
BATCH_NO number(8),
Invoice_No varchar2(15),
SETTLE_DATE varchar2(15),
SETTLE_TIME varchar2(15),
TRANS_DATE varchar2(15),
TRANS_TIME varchar2(15),
CARD_NO varchar2(19),
TRANS_AMOUNT number(18,2),
CURR_RATE number(4,2),
BILLING_AMOUNT number(18,2),
DISCOUNT number(18,2),
NET_AMOUNT number(18,2),
APPROVE_CODE varchar2(15),
APPROVE_CODE_SALE varchar2(15),
PROC_DATE varchar2(15),
BOOK_DATE varchar2(15),
DISCOUNT_RATE number(4,2),
Crd_Type varchar2(15),
STATUS varchar2(15),
MM_BIZ_NAME varchar2(250),
ACQ_Ref_No varchar2(50),
Req_Rec_Id varchar2(50),
Customer_Description varchar2(15),
Reference_No varchar2(50),
Bill_Code varchar2(15),
Customer_Name varchar2(250),
Service_cd varchar2(15),
Real_card varchar2(19),
QR_SSP varchar2(15),
transaction_id varchar2(50),
Pos_Entry varchar2(15),
CURR_TYPE varchar2(3),
ORDER_ID varchar2(15),
FILE_ID NUMBER(10),
IMP_REC_ID NUMBER(22),
	IMPORT_DATE DATE,
  IMP_SESSION NUMBER(3),
  rec_created_date date,
  rec_updated_date date,
  is_processed NUMBER(1),
  is_matched NUMBER(1)
)
PARTITION BY RANGE(IMPORT_DATE) INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))  
(PARTITION P1 VALUES LESS THAN (TO_DATE('01/01/2025', 'DD/MM/YYYY')));  
CREATE INDEX vccb_recon_stb_imp_mid_idx ON vccb_reconciliation_stb_imp (MERCHANT_ID);
CREATE INDEX vccb_recon_stb_imp_tid_idx ON vccb_reconciliation_stb_imp (TERMINAL_ID);


select * from vccb_reconciliation_stb_imp
