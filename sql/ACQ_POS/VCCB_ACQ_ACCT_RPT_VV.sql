CREATE OR REPLACE VIEW VCCB_ACQ_ACCT_RPT_VV AS
SELECT row_number() over(ORDER BY RPT_SESSION,PRIORITY, GROUP_NAME) AS NO
      ,RPT_SESSION,a."GROUP_NAME",a."PRIORITY",a."DESCRIPTION",a."POSTING_DATE",a."DEBIT_BRANCH_CODE",a."DEBIT_ACCOUNT_NUMBER",a."DEBIT_ACCOUNT_NAME",a."CURRENCY",a."POSTING_AMT",a."CREDIT_BRANCH_CODE",a."CREDIT_ACCOUNT_NUMBER",a."CREDIT_ACCOUNT_NAME",a."NARRATIVE"
FROM   (SELECT a.imp_session as RPT_SESSION
              ,a.priority
              ,'A' AS GROUP_NAME
              ,'Record the total transaction amount to the suspense account ' || a.acq_bank_code AS Description
              ,trunc(SYSDATE) AS posting_date
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
        left join
        (
             select max(imp_session) imp_session
             from VCCB_ACQ_ACCOUNTING_FC
             where process_dt = trunc(sysdate)
             and group_name = 'A'
        )m on a.imp_session = m.imp_session
        WHERE  process_dt = trunc(sysdate)
               AND a.group_name = 'A'
               AND m.imp_session is not null
        GROUP  BY a.imp_session
                 ,a.priority
                 ,a.acq_bank_code
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.imp_session as RPT_SESSION
              ,a.priority
              ,'B' AS GROUP_NAME
              ,'Record the total payable sharing fees ' || a.acq_bank_code AS Description
              ,trunc(SYSDATE) AS posting_date
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
        left join
        (
             select max(imp_session) imp_session
             from VCCB_ACQ_ACCOUNTING_FC
             where process_dt = trunc(sysdate)
             and group_name = 'B'
        )m on a.imp_session = m.imp_session
        WHERE  process_dt = trunc(sysdate)
               AND a.group_name = 'B'
               AND m.imp_session is not null
        GROUP  BY a.imp_session
                 ,a.priority
                 ,a.acq_bank_code
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.imp_session as RPT_SESSION
              ,a.priority
              ,'C' AS GROUP_NAME
              ,'Record the total credited amount into the nostro account ' || a.acq_bank_code AS Description
              ,trunc(SYSDATE) AS posting_date
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
        left join
        (
             select max(imp_session) imp_session
             from VCCB_ACQ_ACCOUNTING_FC
             where process_dt = trunc(sysdate)
             and group_name = 'C'
        )m on a.imp_session = m.imp_session
        WHERE  process_dt = trunc(sysdate)
               AND a.group_name = 'C'
               AND m.imp_session is not null
        GROUP  BY a.imp_session
                 ,a.priority
                 ,a.acq_bank_code
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.imp_session as RPT_SESSION
              ,a.priority
              ,'D' AS GROUP_NAME
              ,'Record the total credited amount to merchant ' || a.merchant_name AS Description
              ,trunc(SYSDATE) AS posting_date
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
        left join
        (
             select max(imp_session) imp_session
             from VCCB_ACQ_ACCOUNTING_FC
             where process_dt = trunc(sysdate)
             and group_name = 'D'
        )m on a.imp_session = m.imp_session
        WHERE  process_dt = trunc(sysdate)
               AND a.group_name = 'D'
               AND m.imp_session is not null
        GROUP  BY a.imp_session
                 ,a.priority
                 ,a.merchant_name
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name
        UNION
        SELECT a.imp_session as RPT_SESSION
              ,a.priority
              ,'E' AS GROUP_NAME
              ,'Record the total receivable discount fees ' || a.merchant_name AS Description
              ,trunc(SYSDATE) AS posting_date
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
        left join
        (
             select max(imp_session) imp_session
             from VCCB_ACQ_ACCOUNTING_FC
             where process_dt = trunc(sysdate)
             and group_name = 'E'
        )m on a.imp_session = m.imp_session
        WHERE  process_dt = trunc(sysdate)
               AND a.group_name = 'E'
               AND m.imp_session is not null
        GROUP  BY a.imp_session
                 ,a.priority
                 ,a.merchant_name
                 ,a.debit_branch_code
                 ,a.debit_account_number
                 ,a.debit_account_name
                 ,a.credit_branch_code
                 ,a.credit_account_number
                 ,a.credit_account_name) a
ORDER  BY RPT_SESSION,PRIORITY
         ,GROUP_NAME;
