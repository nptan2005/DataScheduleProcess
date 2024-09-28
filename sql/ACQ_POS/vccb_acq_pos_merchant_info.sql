CREATE TABLE vccb_acq_pos_merchant_info
(
       SALE_CODE varchar2(20) not null,
       MERCHANT_CODE varchar2(20) not null,
       BANK_BRANCH_NAME VARCHAR2(100),
       ACQ_BANK varchar2(20) not null,
       BANK_CODE varchar2(20) not null,
       MDR_FEE_CODE VARCHAR2(20) not null,
       MERCHANT_ID varchar2(20),
       TERMINAL_ID varchar2(20),
       MCC VARCHAR2(15),
       MERCHANT_NAME varchar2(250),
       BUSINESS_TYPE varchar2(250),
       CIF_NUMBER varchar2(20) not null,
       BANK_ACCOUNT_NUMBER varchar2(20) not null,
       BANK_ACCOUNT_NAME varchar2(250) not null,
       STREET_ADDR varchar2(500),
       WARD_ADDR varchar2(205),
       DISTRICT_ADDR varchar2(250),
       CITY_ADDR varchar2(250),
       PHONE_NUMBER varchar2(20),
       EMAIL varchar2(50),
       POS_ASSET_CODE varchar2(50),
       POS_PRODUCT varchar2(100),
       POS_TYPE VARCHAR2(100),
       SERIAL VARCHAR2(50),
       IS_NEW_POS VARCHAR2(10),
       ACTIVE	NUMBER(1),
	   START_DATE DATE,
	   END_DATE DATE,
     IMPORT_ID NUMBER(22),
     FILE_ID NUMBER(22),
     IS_PROCESS_IMP NUMBER(1),
	   IMPORT_DATE DATE,
     rec_updated_date date 
       
       
);
CREATE INDEX vccb_acq_pos_merchant_IDX ON vccb_acq_pos_merchant_info (MERCHANT_ID,TERMINAL_ID)


select * from vccb_acq_pos_merchant_info
