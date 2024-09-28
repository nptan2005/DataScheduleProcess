/*create or replace view vccb_acq_acct_rpt_vv as*/
SELECT row_number() over(ORDER BY PRIORITY, GROUP_NAME) AS No
      ,a.*
FROM   (SELECT a.priority
              ,'A' AS GROUP_NAME
              ,'Record the total transaction amount to the suspense account ' || a.acq_bank_code AS Description
              ,NULL AS batch_no
              ,SYSDATE AS posting_date
              ,a.debit_branch_code
              ,a.debit_account_number
              ,a.debit_account_name
              ,SUM(a.posting_amt) AS posting_amt
              ,'VND' AS currency
              ,a.credit_branch_code
              ,a.credit_account_number
              ,a.credit_account_name
              ,'KC SO TIEN GIAO DICH PHAI THU NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') ||
               ' VAO TK TT BU TRU VOI ' || a.acq_bank_code AS narrative
        FROM   VCCB_ACQ_ACCOUNTING_FC a
        WHERE  a.group_name = 'A'
        GROUP  BY a.priority
                 ,a.acq_bank_code
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.priority
              ,'B' AS GROUP_NAME
              ,'Record the total payable sharing fees ' || a.acq_bank_code AS Description
              ,NULL AS batch_no
              ,SYSDATE AS posting_date
              ,a.debit_branch_code
              ,a.debit_account_number
              ,a.debit_account_name
              ,SUM(a.posting_amt) AS posting_amt
              ,'VND' AS currency
              ,a.credit_branch_code
              ,a.credit_account_number
              ,a.credit_account_name
              ,'KC SO TIEN GIAO DICH PHAI THU NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') ||
               ' VAO TK TT BU TRU VOI ' || a.acq_bank_code AS narrative
        FROM   VCCB_ACQ_ACCOUNTING_FC a
        WHERE  a.group_name = 'B'
        GROUP  BY a.priority
                 ,a.acq_bank_code
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.priority
              ,'C' AS GROUP_NAME
              ,'Record the total credited amount into the nostro account ' || a.acq_bank_code AS Description
              ,NULL AS batch_no
              ,SYSDATE AS posting_date
              ,a.debit_branch_code
              ,a.debit_account_number
              ,a.debit_account_name
              ,SUM(a.posting_amt) AS posting_amt
              ,'VND' AS currency
              ,a.credit_branch_code
              ,a.credit_account_number
              ,a.credit_account_name
              ,'KC KHOAN PHAI THU ' || a.acq_bank_code || ' TU TK TGKKH TAI ' || a.acq_bank_code ||
               ' NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') AS narrative
        FROM   VCCB_ACQ_ACCOUNTING_FC a
        WHERE  a.group_name = 'C'
        GROUP  BY a.priority
                 ,a.acq_bank_code
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.priority
              ,'D' AS GROUP_NAME
              ,'Record the total credited amount to merchant ' || a.merchant_name AS Description
              ,a.batch_no
              ,SYSDATE AS posting_date
              ,a.debit_branch_code
              ,a.debit_account_number
              ,a.debit_account_name
              ,SUM(a.posting_amt) AS posting_amt
              ,'VND' AS currency
              ,a.credit_branch_code
              ,a.credit_account_number
              ,a.credit_account_name
              ,'BVBANK THANH TOAN CONG NO POS NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') || ' CHO ' ||
               a.merchant_name AS narrative
        FROM   VCCB_ACQ_ACCOUNTING_FC a
        WHERE  a.group_name = 'D'
        GROUP  BY a.priority
                 ,a.merchant_name
                 ,a.batch_no
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.priority
              ,'E' AS GROUP_NAME
              ,'Record the total receivable discount fees ' || a.merchant_name AS Description
              ,a.batch_no
              ,SYSDATE AS posting_date
              ,a.debit_branch_code
              ,a.debit_account_number
              ,a.debit_account_name
              ,SUM(a.posting_amt) AS posting_amt
              ,'VND' AS currency
              ,a.credit_branch_code
              ,a.credit_account_number
              ,a.credit_account_name
              ,'PHI CHIET KHAU POS NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') || ' PHAI THU ' ||
               a.merchant_name AS narrative
        FROM   VCCB_ACQ_ACCOUNTING_FC a
        WHERE  a.group_name = 'E'
        GROUP  BY a.priority
                 ,a.merchant_name
                 ,a.batch_no
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name) a
ORDER  BY PRIORITY
         ,GROUP_NAME

;
create or replace view vccb_acq_bank_total_txn_rpt_vv as
select row_number() over ( order by txn.acq_bank_code ) as No
       , txn.acq_bank_code as ACQ_BANK
       , count(txn.retrieval_ref_no) as num_of_txn
       , sum(txn.request_amount) as txn_amt
       , sum(txn.acq_bank_fee) as share_fee
       , sum(txn.bvb_credit_amt) as bvb_amt
FROM   vccb_atom_pos_settl_txn_imp txn
WHERE  txn.IS_SETTLE = 1
      AND txn.RESPONSE_CODE = '00'
group by txn.acq_bank_code
order by txn.acq_bank_code

;
create or replace view vccb_acq_mer_total_txn_rpt_vv as
select row_number() over ( order by txn.merchant_name ) as No
       , txn.merchant_name as Merchant_Name
       , txn.merchant_id mid
       , txn.terminal_id tid
       , count(txn.retrieval_ref_no) as num_of_txn
       , sum(txn.request_amount) as txn_amt
       , sum(txn.discount_amt) as discount_amt
       , sum(txn.merchant_credit_amt) as merchant_credit_amt
       , txn.account_number
       , txn.account_name
FROM   vccb_atom_pos_settl_txn_imp txn
WHERE  txn.IS_SETTLE = 1
      AND txn.RESPONSE_CODE = '00'
group by txn.merchant_name, txn.merchant_id, txn.terminal_id, txn.account_number, txn.account_name
order by txn.merchant_name

;

create or replace view vccb_acq_accounting_status_vv as
select row_number() over ( order by txn.merchant_id ) as No
       , txn.merchant_id mid
       , txn.terminal_id tid
       , txn.auth_id_reponse
       , txn.retrieval_ref_no
       , txn.request_amount
       , sysdate posting_date
FROM   vccb_atom_pos_settl_txn_imp txn
WHERE  txn.IS_SETTLE = 1
      AND txn.RESPONSE_CODE = '00'
order by txn.merchant_id;

SELECT 
department_id, 
job_id, 
SUM(salary) AS total_salary
FROM 
employees
GROUP BY 
ROLLUP(department_id, job_id);


SELECT parameter, value 
FROM nls_database_parameters 
WHERE parameter = 'NLS_CHARACTERSET';

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8


select * from vccb_acq_acct_rpt_vv
