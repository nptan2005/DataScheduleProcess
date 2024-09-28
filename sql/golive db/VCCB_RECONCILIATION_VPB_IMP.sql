-- Create table
create table VCCB_RECONCILIATION_VPB_IMP
(
  merchant_id      VARCHAR2(15),
  terminal_id      VARCHAR2(15),
  trans_type       VARCHAR2(15),
  request_category VARCHAR2(15),
  trans_datetime   DATE,
  approve_code     VARCHAR2(15),
  card_no          VARCHAR2(19),
  crd_type         VARCHAR2(15),
  curr_type        VARCHAR2(15),
  trans_amount     NUMBER(18,2),
  fee_amount       NUMBER(18,2),
  vat_amount       NUMBER(18,2),
  reference_no     VARCHAR2(50),
  status           VARCHAR2(15),
  trans_condition  VARCHAR2(100),
  contract_name    VARCHAR2(250),
  order_id         VARCHAR2(15),
  cybers_order_id  VARCHAR2(15),
  cybers_purch_id  VARCHAR2(15),
  file_id          NUMBER(10),
  imp_rec_id       NUMBER(22),
  import_date      DATE,
  imp_session      NUMBER(3),
  rec_created_date DATE,
  rec_updated_date DATE,
  is_processed     NUMBER(1),
  is_matched       NUMBER(1)
)
PARTITION BY RANGE(IMPORT_DATE) INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))  
(PARTITION P1 VALUES LESS THAN (TO_DATE('01/01/2025', 'DD/MM/YYYY')));  
CREATE INDEX vccb_recon_vpb_imp_mid_idx ON vccb_reconciliation_vpb_imp (MERCHANT_ID);
CREATE INDEX vccb_recon_vpb_imp_tid_idx ON vccb_reconciliation_vpb_imp (TERMINAL_ID);
