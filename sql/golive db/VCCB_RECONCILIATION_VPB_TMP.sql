-- Create table
create table VCCB_RECONCILIATION_VPB_TMP
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
  imp_rec_id       NUMBER(22)
);