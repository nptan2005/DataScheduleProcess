CREATE OR REPLACE VIEW VCCB_ACQ_ACC_TO_FC_STT_RPT_VV AS
SELECT a.imp_session AS "PHIEN"
       ,a.group_name AS "NHOM HT"
       ,a.priority AS "THU TU HT"
       ,a.batch_no as "BatchID"
       ,trunc(posting_date) AS "NGAY HT"
       ,a.debit_branch_code AS "BRANCH TK NO"
       ,a.debit_account_number AS "TK NO"
       ,a.debit_account_name AS "TEN TK NO"
       ,'VND' AS CURRENCY
       ,SUM(a.posting_amt) AS "SO TIEN"
       ,a.credit_branch_code AS "BRANCH TK CO"
       ,a.credit_account_number AS "SO TK CO"
       ,a.credit_account_name AS "TEN TK CO"
       ,a.NARRATIVE
       ,CASE
         WHEN a.is_successed = 1 THEN
          unistr('\0054\0068\00E0\006E\0068\0020\0063\00F4\006E\0067')
         ELSE
          unistr('\004B\0068\00F4\006E\0067\0020\0074\0068\00E0\006E\0068\0020\0063\00F4\006E\0067')
       END AS "KET QUA"
       ,a.FC_RESULTDESC
       ,a.run_number AS "SO LAN HT"

FROM   VCCB_ACQ_ACCOUNTING_FC a
left join
        (
             select max(imp_session) imp_session
             from VCCB_ACQ_ACCOUNTING_FC
             where process_dt = trunc(sysdate)
             and group_name IN ('A','D','E')
        )m on a.imp_session = m.imp_session
WHERE  process_dt = trunc(SYSDATE)
       AND is_processed = 1
       AND a.group_name IN ('A','D','E')
       AND m.imp_session is not null
GROUP  BY a.imp_session
         ,a.priority
         ,a.group_name
         ,a.batch_no
         ,trunc(posting_date)
         ,a.debit_branch_code
         ,a.debit_account_number
         ,a.debit_account_name
         ,a.credit_branch_code
         ,a.credit_account_number
         ,a.credit_account_name
         ,a.narrative
         ,a.fc_resultdesc
         ,is_successed
         ,a.run_number
ORDER  BY a.imp_session
         ,a.priority
         ,a.GROUP_NAME;
