CREATE TABLE VCCB_ACQ_MDR_FEE_TMP_IMP 
(
       FILE_ID NUMBER(20),
       MDR_FEE_CODE VARCHAR2(20),
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


select * from VCCB_ACQ_MDR_FEE_TMP_IMP
