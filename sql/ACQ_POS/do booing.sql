select FILE_ID, PRIORITY, GROUP_NAME, DEBIT_ACCOUNT_NUMBER, CREDIT_ACCOUNT_NUMBER
       --,narrative
       , sum(POSTING_AMT) POSTING_AMT
from VCCB_ACQ_ACCOUNTING_FC
group by  FILE_ID,PRIORITY, GROUP_NAME, DEBIT_ACCOUNT_NUMBER, CREDIT_ACCOUNT_NUMBER
--, narrative
ORDER  BY PRIORITY
         ,GROUP_NAME

merge into VCCB_ACQ_ACCOUNTING_FC d
using
(
      select FILE_ID,IMP_REC_ID, Vccb_Acq_Pos_Api.fn_rnn(FILE_ID, rownum) as rrn
      from VCCB_ACQ_ACCT_RPT_VV a
)s
on (d.FILE_ID = s.FILE_ID and d.IMP_REC_ID = s.IMP_REC_ID)
when matched then update
  set d.rrn = s.rrn
  
  select lpad(vccb_fc_rrn_seq.nextval,16,'0') from dual
  
  select *
  from VCCB_ACQ_ACCOUNTING_FC
  
  select *
  from VCCB_ACQ_BANK_BENEFIT_ACCT
  
  truncate table VCCB_ACQ_BANK_BENEFIT_ACCT
  
  select * from VCCB_ACQ_BANK_BENEFIT_ACCT
  
  update VCCB_ACQ_BANK_BENEFIT_ACCT set ACQ_BANK_CODE = '970403' where ACQ_BANK_CODE = 'STB'
  
  SELECT max(nvl(imp_session,0))
       FROM vccb_atom_pos_settl_txn_imp 
       
       
       truncate table VCCB_ACQ_ACCOUNTING_FC;
       truncate table vccb_atom_pos_settl_txn_imp;
       
       
       select * from VCCB_SCHEDULE_JOB_HIS
       
       select * from VCCB_ACQ_ACCOUNTING_STATUS_VV 
       
       select * from VCCB_ACQ_ACCOUNTING_FC where PROCESS_DT = trunc(sysdate)
       
       select * from vccb_atom_pos_settl_txn_imp
       
       SELECT COUNT(*)

      FROM   VCCB_ACQ_ACCOUNTING_FC
      WHERE  process_dt = trunc(sysdate)
             AND GROUP_NAME = 'A'
       
       
       SELECT MAX(nvl(imp_session, 0))
        --INTO   l_imp_session
        FROM   vccb_atom_pos_settl_txn_imp
        WHERE  import_date = trunc(SYSDATE);
       
       select * from VCCB_ACQ_ACCOUNTING_STATUS_VV
       
       
       select * from acvw_all_ac_entries@FCLINK where  '101100000' in (ac_no,related_account)   order by 2 desc
       
       
       select * from actb_daily_log@FCLINK 
       where external_ref_no = 'ACQ0000000000377' 
       and ENTRY_SEQ_NO =1
       
       069CP24KJ0001362
      

       
      
