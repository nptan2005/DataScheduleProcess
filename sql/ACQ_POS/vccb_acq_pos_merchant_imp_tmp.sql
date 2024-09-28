CREATE TABLE vccb_acq_pos_merchant_imp_tmp
(
       SALE_CODE varchar2(20),
       MERCHANT_CODE varchar2(20),
       BANK_BRANCH_NAME VARCHAR2(100),
       ACQ_BANK varchar2(20),
       BANK_CODE varchar2(20),
       MDR_FEE_CODE VARCHAR2(20),
       MERCHANT_ID varchar2(20),
       TERMINAL_ID varchar2(20),
       MCC VARCHAR2(15),
       MERCHANT_NAME varchar2(250),
       BUSINESS_TYPE varchar2(250),
       CIF_NUMBER varchar2(20),
       BANK_ACCOUNT_NUMBER varchar2(20),
       BANK_ACCOUNT_NAME varchar2(250),
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
       IS_NEW_POS VARCHAR2(10)
       
       
)

select * from vccb_acq_pos_merchant_imp_tmp

SELECT table_name FROM all_tables WHERE table_name = 'VCCB_ACQ_POS_MERCHANT_IMP_TMP'

truncate table vccb_acq_pos_merchant_imp_tmp
