CREATE TABLE VCCB_ACQ_BANK_FEE_TMP_IMP 
(
       FILE_ID NUMBER(20),
       BANK_CODE VARCHAR2(20),
       NAPAS_FEE NUMBER(3,2),
       VISA_ACQ_FEE NUMBER(3,2),
       VISA_ISS_DOMESTIC_FEE NUMBER(3,2),
     VISA_ISS_FOREIGN_FEE NUMBER(3,2),
       MASTER_ACQ_FEE NUMBER(3,2),
     MASTER_ISS_DOMESTIC_FEE NUMBER(3,2),
     MASTER_ISS_FOREIGN_FEE NUMBER(3,2),
       JCB_ACQ_FEE NUMBER(3,2),
     JCB_ISS_DOMESTIC_FEE NUMBER(3,2),
     JCB_ISS_FOREIGN_FEE NUMBER(3,2)
)

select * from Vccb_Acq_Bank_Fee_Tmp_Imp

truncate table Vccb_Acq_Bank_Fee_Tmp_Imp

SELECT COLUMN_NAME, DATA_TYPE FROM ALL_TAB_COLUMNS WHERE table_name = upper('Vccb_Acq_Bank_Fee_Tmp_Imp')

