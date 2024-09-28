DECLARE
l_resultcode varchar2(50):= '';
l_resultdesc varchar2(50):= '';
l_fcref varchar2(50):= '';
BEGIN
  -- Call the procedure
  FCUBSIT2.bvbpks_auto_cardpayment.pr_merchant_tran@FCLINK(drac       => '101100000'
                                                   ,crac       => '8017041000915'
                                                   ,amount     => 10000
                                                   ,narrative  => 'TEST'
                                                   ,trndate    => sysdate
                                                   ,rrn        => '999900002'
                                                   ,resultcode => l_resultcode
                                                   ,resultdesc => l_resultdesc
                                                   ,fcref      => l_fcref);
  DBMS_OUTPUT.PUT_LINE('l_resultcode: ' || l_resultcode);
  DBMS_OUTPUT.PUT_LINE('l_resultdesc: ' || l_resultdesc);
  DBMS_OUTPUT.PUT_LINE('l_fcref: ' || l_fcref);
END;


select ACY_AVL_BAL,a.* from sttm_cust_account@FCLINK a WHERE  cust_ac_no='8017041000915'

select Vccb_Acq_Pos_Api.fn_rnn('') from dual

select rpad('1',10,'0') from dual

begin
  Vccb_Acq_Pos_Api.pr_acq_accounting_fc;
end;

declare
  v_rs varchar2(10);
  vs_desc varchar2(100);
begin
   --Vccb_Acq_Pos_Api.pr_acq_auto_credit_bvb(o_rscode => v_rs, o_rsdesc => vs_desc,i_group_name => 'A');
   --Vccb_Acq_Pos_Api.pr_acq_auto_credit_merchant(o_rscode => v_rs, o_rsdesc => vs_desc,i_group_name => 'E');
   Vccb_Acq_Pos_Api.pr_acq_auto_credit(o_rscode => v_rs, o_rsdesc => vs_desc);
   DBMS_OUTPUT.PUT_LINE(v_rs);
   DBMS_OUTPUT.PUT_LINE(vs_desc);
end;



SELECT COLUMN_NAME
                                    , DATA_TYPE
                                    , DATA_LENGTH as MAX_LENGTH
                                    , DATA_PRECISION as PRECISION
                                    ,DATA_SCALE as SCALE, table_name
                                FROM user_tab_columns 
                                where table_name = 'VCCB_ACQ_ACCOUNTING_FC'

