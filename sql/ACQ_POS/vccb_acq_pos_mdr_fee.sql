CREATE TABLE VCCB_ACQ_MDR_FEE 
(
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
     JCB_ISS_FOREIGN_FEE NUMBER(3,2),
	   ACTIVE	NUMBER(1),
	   START_DATE DATE,
	   END_DATE DATE,
     IMPORT_ID NUMBER(22),
     FILE_ID NUMBER(22),
     IS_PROCESS_IMP NUMBER(1),
	   IMPORT_DATE DATE,
     rec_updated_date date  
);
CREATE INDEX VCCB_ACQ_MDR_FEE_IDX ON VCCB_ACQ_MDR_FEE (MDR_FEE_CODE)




begin
  --Vccb_Acq_Pos_Api.Process_Import_Mdr_Fee;
  Vccb_Acq_Pos_Api.Process_Active_Mdr_Fee;
end;

select * from VCCB_ACQ_MDR_FEE

update VCCB_ACQ_MDR_FEE 
set START_DATE = to_date('20240718','yyyymmdd') 
--set active =1  
--set IS_PROCESS_IMP = 1
--where END_DATE is  null and IS_PROCESS_IMP = 0
where  START_DATE = to_date('20240719','yyyymmdd') 

update VCCB_ACQ_MDR_FEE set active = 0 where START_DATE = to_date('20240717','yyyymmdd') 




SELECT Mdr_Fee_Code
                 ,Start_Date
                 ,End_Date
                 ,Active
           FROM   Vccb_Acq_Mdr_Fee
           WHERE  Active = 0
                  AND Is_Process_Imp = 0
                  AND Start_Date = Trunc(SYSDATE)
                  AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE))


select trunc(sysdate - 1) from dual


select * 
from VCCB_ACQ_MDR_FEE
WHERE NVL(ACTIVE,0) = 1
                AND TO_CHAR(START_DATE,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
                AND (END_DATE IS NULL OR TO_CHAR(END_DATE,'YYYYMMDD') >= TO_CHAR(SYSDATE,'YYYYMMDD'))
                
                
                SELECT TO_DATE('8/16/2024 2:41:25 PM', 'MM/DD/YYYY HH:MI:SS AM') FROM dual;
