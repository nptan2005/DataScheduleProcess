create or replace view vccb_acq_accounting_status_vv as
select row_number() over ( order by txn.merchant_id ) as No
       , txn.txn_id
       , txn.merchant_id mid
       , txn.terminal_id tid
       , txn.auth_id_reponse
       , txn.retrieval_ref_no
       , txn.request_amount
       , txn.posting_date
FROM   vccb_atom_pos_settl_txn_imp txn
WHERE  txn.IMPORT_DATE = trunc(sysdate)
      AND txn.is_processed = 1
order by txn.merchant_id;
