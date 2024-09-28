CREATE OR REPLACE PACKAGE bvbpks_Acq_Pos_Api IS

  -- Author  : TANNP
  -- Created : 18/07/2024 13:54:36
  -- Purpose : ACQ POS Project

  -- Public type declarations
  /*PROCEDURE Pr_Imp_Vpb_Txn_Online;*/
  FUNCTION fn_Get_fee_percent
  (
    i_Fee_Amt IN NUMBER
   ,i_Txn_Amt IN NUMBER
  ) RETURN NUMBER;

  /*PROCEDURE Pr_Active_Mdr_Fee;
  PROCEDURE Pr_Imp_Mdr_Fee;
  
  PROCEDURE Pr_Active_ACQ_Bank_Fee;
  PROCEDURE Pr_Imp_ACQ_Bank_Fee;*/
  
  PROCEDURE Pr_Imp_atom_pos_settl_txn;
  
  PROCEDURE Pr_Act_acq_bank_benefit_acct;
  
  PROCEDURE Pr_Imp_acq_bank_benefit_acct;
  PROCEDURE pr_imp_reconciliation_stb;
  PROCEDURE pr_reconciliation_stb;
  PROCEDURE pr_reconciliation_vpb;
  PROCEDURE pr_imp_reconciliation_vpb;
  
  function fn_rnn(prefix in varchar) return varchar2;
  
  PROCEDURE pr_acq_accounting_fc(o_rscode out varchar2, o_rsdesc out varchar2,i_process_dt in DATE DEFAULT NULL);
  
  PROCEDURE pr_acq_auto_credit_bvb(o_rscode out varchar2, o_rsdesc out varchar2, i_group_name in varchar2, i_process_dt IN DATE DEFAULT NULL);
  PROCEDURE pr_acq_auto_credit_merchant(o_rscode out varchar2, o_rsdesc out varchar2,i_group_name in varchar2, i_process_dt IN DATE DEFAULT NULL);

  
  PROCEDURE pr_acq_auto_credit(o_rscode out varchar2, o_rsdesc out varchar2,i_process_dt IN DATE DEFAULT NULL);

END bvbpks_Acq_Pos_Api;
/
CREATE OR REPLACE PACKAGE BODY bvbpks_Acq_Pos_Api IS
  /*
    PROCEDURE Pr_Imp_Vpb_Txn_Online AS
      l_Duplicate NUMBER;
    BEGIN
    
      SELECT COUNT(*)
      INTO   l_Duplicate
      FROM   (SELECT Rrn
              FROM   Vccb_Acq_Vpb_Onl_Txn_Tmp_Imp
              WHERE  Nvl(Credit_Amount, 0) > 0
                     AND Nvl(Debit_Amount, 0) = 0
              GROUP  BY Rrn
              HAVING COUNT(*) > 1);
      IF l_Duplicate = 0
      THEN
        --merge insert new record VCCB_ACQ_VPB_ONL_TXN
        MERGE INTO Vccb_Acq_Vpb_Onl_Txn d
        USING (SELECT *
               FROM   Vccb_Acq_Vpb_Onl_Txn_Tmp_Imp
               WHERE  Nvl(Credit_Amount, 0) > 0
                      AND Nvl(Debit_Amount, 0) = 0) s
        ON (d.Rrn = s.Rrn)
        WHEN NOT MATCHED THEN
          INSERT
            (Import_Id
            ,File_Id
            ,Doc_Id
            ,Debit_Amount
            ,Credit_Amount
            ,Balance_Amount
            ,Terminal_Id
            ,Trans_Date
            ,Card_Number
            ,Card_Type
            ,Auth_Code
            ,Trans_Amount
            ,Fee_Amount
            ,Vat_Amount
            ,Rrn
            ,Import_Content
            ,Batch_No
            ,Import_Date
            ,Is_Processed
            ,Rec_Updated_Date)
          VALUES
            (Vccb_Schedule_Imp_Seq.Nextval
            ,s.File_Id
            ,s.Doc_Id
            ,s.Debit_Amount
            ,s.Credit_Amount
            ,s.Balance_Amount
            ,s.Terminal_Id
            ,s.Trans_Date
            ,s.Card_Number
            ,s.Card_Type
            ,s.Auth_Code
            ,s.Trans_Amount
            ,s.Fee_Amount
            ,s.Vat_Amount
            ,s.Rrn
            ,s.Import_Content
            ,s.Batch_No
            ,SYSDATE
            ,0
            ,SYSDATE);
        COMMIT;
        --- merge update debit amount
        MERGE INTO Vccb_Acq_Vpb_Onl_Txn d
        USING (SELECT Rrn
                     ,Debit_Amount
               FROM   Vccb_Acq_Vpb_Onl_Txn_Tmp_Imp
               WHERE  Nvl(Credit_Amount, 0) = 0
                      AND Nvl(Debit_Amount, 0) > 0) s
        ON (d.Rrn = s.Rrn)
        WHEN MATCHED THEN
          UPDATE
          SET    d.Debit_Amount   = s.Debit_Amount
                ,Rec_Updated_Date = SYSDATE;
        COMMIT;
      
      END IF;
    
    END Pr_Imp_Vpb_Txn_Online;
  */
  FUNCTION fn_Get_fee_percent
  (
    i_Fee_Amt IN NUMBER
   ,i_Txn_Amt IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN i_Fee_Amt * 100 / i_Txn_Amt;
  END fn_Get_fee_percent;

  /*PROCEDURE Pr_Active_Mdr_Fee AS
  BEGIN
    --- inactive expired fee
    UPDATE Vccb_Acq_Mdr_Fee SET Active = 0 WHERE End_Date < Trunc(SYSDATE);
    COMMIT;
  
    MERGE INTO Vccb_Acq_Mdr_Fee d
    USING (SELECT DISTINCT Mdr_Fee_Code
                          ,Start_Date
                          ,End_Date
                          ,Active
           FROM   Vccb_Acq_Mdr_Fee
           WHERE  Active = 0
                  AND Is_Process_Imp = 0
                  AND Start_Date = Trunc(SYSDATE)
                  AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE))) s
    ON (d.Mdr_Fee_Code = s.Mdr_Fee_Code)
    WHEN MATCHED THEN
      UPDATE
      SET    d.Active           = 0
            ,d.End_Date         = CASE
                                    WHEN d.End_Date IS NULL THEN
                                     Trunc(SYSDATE)
                                    ELSE
                                     d.End_Date
                                  END
            ,d.Rec_Updated_Date = SYSDATE
      WHERE  d.Is_Process_Imp = 1
             AND d.Active = 1
      
      ;
    COMMIT;
  
    --- active new fee 
    UPDATE Vccb_Acq_Mdr_Fee
    SET    Active           = 1
          ,Is_Process_Imp   = 1
          ,Rec_Updated_Date = SYSDATE
    WHERE  Active = 0
           AND Is_Process_Imp = 0
           AND Start_Date <= Trunc(SYSDATE)
           AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE));
  
    COMMIT;
  
  END Pr_Active_Mdr_Fee;
  
  PROCEDURE Pr_Imp_Mdr_Fee AS
  BEGIN
  
    INSERT INTO Vccb_Acq_Mdr_Fee
      (Mdr_Fee_Code
      ,Napas_Fee
      ,Visa_Acq_Fee
      ,Visa_Iss_Domestic_Fee
      ,Visa_Iss_Foreign_Fee
      ,Master_Acq_Fee
      ,Master_Iss_Domestic_Fee
      ,Master_Iss_Foreign_Fee
      ,Jcb_Acq_Fee
      ,Jcb_Iss_Domestic_Fee
      ,Jcb_Iss_Foreign_Fee
      ,Active
      ,Start_Date
      ,End_Date
      ,Import_Id
      ,File_Id
      ,Import_Date
      ,Is_Process_Imp
      ,Rec_Updated_Date)
      SELECT Mdr_Fee_Code
            ,Napas_Fee
            ,Visa_Acq_Fee
            ,Visa_Iss_Domestic_Fee
            ,Visa_Iss_Foreign_Fee
            ,Master_Acq_Fee
            ,Master_Iss_Domestic_Fee
            ,Master_Iss_Foreign_Fee
            ,Jcb_Acq_Fee
            ,Jcb_Iss_Domestic_Fee
            ,Jcb_Iss_Foreign_Fee
            ,0 AS Active
            ,Trunc(SYSDATE + 1) AS Start_Date
            ,NULL AS End_Date
            ,Vccb_Schedule_Imp_Seq.Nextval AS Import_Id
            ,File_Id
            ,SYSDATE AS Import_Date
            ,0 Is_Process_Imp
            ,SYSDATE Rec_Updated_Date
      FROM   Vccb_Acq_Mdr_Fee_Tmp_Imp
      WHERE  Mdr_Fee_Code IS NOT NULL;
    COMMIT;
  
    Pr_Active_Mdr_Fee;
  
  END Pr_Imp_Mdr_Fee;
  
  PROCEDURE Pr_Active_ACQ_Bank_Fee AS
  BEGIN
    --- inactive expired fee
    UPDATE VCCB_ACQ_BANK_FEE SET Active = 0 WHERE End_Date < Trunc(SYSDATE);
    COMMIT;
  
    MERGE INTO VCCB_ACQ_BANK_FEE d
    USING (SELECT DISTINCT BANK_Code
                          ,Start_Date
                          ,End_Date
                          ,Active
           FROM   VCCB_ACQ_BANK_FEE
           WHERE  Active = 0
                  AND Is_Process_Imp = 0
                  AND Start_Date = Trunc(SYSDATE)
                  AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE))) s
    ON (d.BANK_Code = s.BANK_Code)
    WHEN MATCHED THEN
      UPDATE
      SET    d.Active           = 0
            ,d.End_Date         = CASE
                                    WHEN d.End_Date IS NULL THEN
                                     Trunc(SYSDATE)
                                    ELSE
                                     d.End_Date
                                  END
            ,d.Rec_Updated_Date = SYSDATE
      WHERE  d.Is_Process_Imp = 1
             AND d.Active = 1
      
      ;
    COMMIT;
  
    --- active new fee 
    UPDATE VCCB_ACQ_BANK_FEE
    SET    Active           = 1
          ,Is_Process_Imp   = 1
          ,Rec_Updated_Date = SYSDATE
    WHERE  Active = 0
           AND Is_Process_Imp = 0
           AND Start_Date <= Trunc(SYSDATE)
           AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE));
  
    COMMIT;
  
  END Pr_Active_ACQ_Bank_Fee;
  
  PROCEDURE Pr_Imp_ACQ_Bank_Fee AS
  BEGIN
  
    INSERT INTO VCCB_ACQ_BANK_FEE
      (BANK_CODE
      ,Napas_Fee
      ,Visa_Acq_Fee
      ,Visa_Iss_Domestic_Fee
      ,Visa_Iss_Foreign_Fee
      ,Master_Acq_Fee
      ,Master_Iss_Domestic_Fee
      ,Master_Iss_Foreign_Fee
      ,Jcb_Acq_Fee
      ,Jcb_Iss_Domestic_Fee
      ,Jcb_Iss_Foreign_Fee
      ,Active
      ,Start_Date
      ,End_Date
      ,Import_Id
      ,File_Id
      ,Import_Date
      ,Is_Process_Imp
      ,Rec_Updated_Date)
      SELECT BANK_CODE
            ,Napas_Fee
            ,Visa_Acq_Fee
            ,Visa_Iss_Domestic_Fee
            ,Visa_Iss_Foreign_Fee
            ,Master_Acq_Fee
            ,Master_Iss_Domestic_Fee
            ,Master_Iss_Foreign_Fee
            ,Jcb_Acq_Fee
            ,Jcb_Iss_Domestic_Fee
            ,Jcb_Iss_Foreign_Fee
            ,0 AS Active
            ,Trunc(SYSDATE) AS Start_Date
            ,NULL AS End_Date
            ,Vccb_Schedule_Imp_Seq.Nextval AS Import_Id
            ,File_Id
            ,SYSDATE AS Import_Date
            ,0 Is_Process_Imp
            ,SYSDATE Rec_Updated_Date
      FROM   VCCB_ACQ_BANK_FEE_TMP_IMP
      WHERE  BANK_CODE IS NOT NULL;
    COMMIT;
  
    Pr_Active_ACQ_Bank_Fee;
  
  END Pr_Imp_ACQ_Bank_Fee;*/

  PROCEDURE Pr_Imp_atom_pos_settl_txn AS
    l_Duplicate   NUMBER;
    l_imp_session NUMBER(3) := 0;
    l_import_date DATE;
    l_sqlErr      VARCHAR2(600);
  BEGIN
    l_import_date := trunc(SYSDATE);
    SELECT COUNT(*)
    INTO   l_Duplicate
    FROM   (SELECT acq_bank_code || retrieval_ref_no || txn_id
            FROM   vccb_atom_pos_settl_txn_tmp
            WHERE  (1 = 1)
            GROUP  BY acq_bank_code || retrieval_ref_no || txn_id
            HAVING COUNT(*) > 1);
  
    IF l_Duplicate = 0
    THEN
      BEGIN
        SELECT MAX(imp_session)
        INTO   l_imp_session
        FROM   vccb_atom_pos_settl_txn_imp
        WHERE  import_date = l_import_date;
      EXCEPTION
        WHEN no_data_found THEN
          l_imp_session := 0;
      END;
      l_imp_session := nvl(l_imp_session, 0) + 1;
    
      MERGE INTO vccb_atom_pos_settl_txn_imp d
      USING (SELECT * FROM vccb_atom_pos_settl_txn_tmp WHERE 1 = 1) s
      ON (d.txn_id = s.txn_id AND d.acq_bank_code = s.acq_bank_code AND d.merchant_id = s.merchant_id AND d.terminal_id = s.terminal_id AND d.RETRIEVAL_REF_NO = s.RETRIEVAL_REF_NO)
      WHEN NOT MATCHED THEN
        INSERT
          (record_date
          ,merchant_name
          ,master_merchant
          ,merchant_id
          ,terminal_id
          ,serial_no
          ,batch_no
          ,invoice_no
          ,card_number
          ,card_type
          ,card_origin
          ,request_amount
          ,is_settle
          ,is_void
          ,is_reversal
          ,auth_id_reponse
          ,issuer_bank
          ,orig_txn_date
          ,response_code
          ,retrieval_ref_no
          ,settle_unix_time
          ,txn_id
          ,void_txn_id
          ,void_unix_time
          ,reversal_txn_id
          ,reversal_time
          ,merchant_fee_rate
          ,master_merchant_fee_rate
          ,cost_price_rate
          ,mcc
          ,acq_bank_code
          ,transaction_type
          ,pos_entry_mode
          ,master_merchant_fee
          ,acq_bank_fee
          ,bvb_credit_amt
          ,discount_amt
          ,merchant_credit_amt
          ,account_number
          ,account_name
          ,file_id
          ,imp_rec_id
          ,import_date
          ,IMP_SESSION
          ,rec_created_date
          ,rec_updated_date
          ,is_processed)
        VALUES
          (s.record_date
          ,s.merchant_name
          ,s.master_merchant
          ,s.merchant_id
          ,s.terminal_id
          ,s.serial_no
          ,s.batch_no
          ,s.invoice_no
          ,s.card_number
          ,s.card_type
          ,s.card_origin
          ,s.request_amount
          ,s.is_settle
          ,s.is_void
          ,s.is_reversal
          ,s.auth_id_reponse
          ,s.issuer_bank
          ,s.orig_txn_date
          ,s.response_code
          ,s.retrieval_ref_no
          ,s.settle_unix_time
          ,s.txn_id
          ,s.void_txn_id
          ,s.void_unix_time
          ,s.reversal_txn_id
          ,s.reversal_time
          ,s.merchant_fee_rate
          ,s.master_merchant_fee_rate
          ,s.cost_price_rate
          ,s.mcc
          ,s.acq_bank_code
          ,s.transaction_type
          ,s.pos_entry_mode
          ,s.master_merchant_fee
          ,s.acq_bank_fee
          ,s.bvb_credit_amt
          ,s.discount_amt
          ,s.merchant_credit_amt
          ,s.account_number
          ,s.account_name
          ,s.file_id
          ,s.imp_rec_id
          ,l_import_date
          ,l_imp_session
          ,SYSDATE
          ,SYSDATE
          ,0);
      COMMIT;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 500);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('Pr_Imp_atom_pos_settl_txn'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'IMPORT DATA'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END Pr_Imp_atom_pos_settl_txn;

  PROCEDURE Pr_Act_acq_bank_benefit_acct AS
    l_sqlErr VARCHAR2(600);
  BEGIN
    --- inactive expired fee
    UPDATE VCCB_ACQ_BANK_BENEFIT_ACCT SET Active = 0 WHERE End_Date < Trunc(SYSDATE);
    COMMIT;
  
    MERGE INTO VCCB_ACQ_BANK_BENEFIT_ACCT d
    USING (SELECT DISTINCT acq_bank_code
                          ,nvl(Start_Date, trunc(SYSDATE)) Start_Date
                          ,End_Date
                          ,Active
           FROM   VCCB_ACQ_BANK_BENEFIT_ACCT
           WHERE  Active = 0
                  AND Is_Process_Imp = 0
                  AND nvl(Start_Date, trunc(SYSDATE)) = Trunc(SYSDATE)
                  AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE))) s
    ON (d.acq_bank_code = s.acq_bank_code)
    WHEN MATCHED THEN
      UPDATE
      SET    d.Active           = 0
            ,d.End_Date         = CASE
                                    WHEN d.End_Date IS NULL THEN
                                     Trunc(SYSDATE)
                                    ELSE
                                     d.End_Date
                                  END
            ,d.Rec_Updated_Date = SYSDATE
      WHERE  d.Is_Process_Imp = 1
             AND d.Active = 1
      
      ;
    COMMIT;
  
    --- active new fee 
    UPDATE VCCB_ACQ_BANK_BENEFIT_ACCT
    SET    Active           = 1
          ,Is_Process_Imp   = 1
          ,Rec_Updated_Date = SYSDATE
    WHERE  Active = 0
           AND Is_Process_Imp = 0
           AND Start_Date <= Trunc(SYSDATE)
           AND (End_Date IS NULL OR End_Date >= Trunc(SYSDATE));
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 500);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('Pr_Act_acq_bank_benefit_acct'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'IMPORT DATA'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END Pr_Act_acq_bank_benefit_acct;

  PROCEDURE Pr_Imp_acq_bank_benefit_acct AS
    l_Duplicate NUMBER;
    l_sqlErr    VARCHAR2(600);
  BEGIN
    SELECT COUNT(*)
    INTO   l_Duplicate
    FROM   (SELECT acq_bank_code
            FROM   VCCB_ACQ_BANK_BENEFIT_ACCT_TMP
            WHERE  acq_bank_code IS NOT NULL
            GROUP  BY acq_bank_code
            HAVING COUNT(*) > 1);
    IF l_Duplicate = 0
    THEN
      INSERT INTO VCCB_ACQ_BANK_BENEFIT_ACCT
        (bank_name
        ,acq_bank_code
        ,tax_code
        ,address
        ,contract
        ,nostro_account
        ,clearing_branch_code
        ,clearing_account_number
        ,clearing_account_name
        ,suspense_branh_code
        ,suspense_account_number
        ,suspense_account_name
        ,Receivable_branch_code
        ,Receivable_account_number
        ,Receivable_account_name
        ,payable_branch_code
        ,payable_account_number
        ,payable_account_name
        ,deposit_branch_code
        ,deposit_account_number
        ,deposit_account_name
        ,file_id
        ,imp_rec_id
        ,active
        ,is_process_imp
        ,start_date
        ,end_date
        ,import_date
        ,rec_updated_date)
        SELECT bank_name
              ,acq_bank_code
              ,tax_code
              ,address
              ,contract
              ,nostro_account
              ,clearing_branch_code
              ,clearing_account_number
              ,clearing_account_name
              ,suspense_branh_code
              ,suspense_account_number
              ,suspense_account_name
              ,Receivable_branch_code
              ,Receivable_account_number
              ,Receivable_account_name
              ,payable_branch_code
              ,payable_account_number
              ,payable_account_name
              ,deposit_branch_code
              ,deposit_account_number
              ,deposit_account_name
              ,file_id
              ,imp_rec_id
              ,0 AS active
              ,0 AS is_process_imp
              ,Trunc(SYSDATE) AS Start_Date
              ,NULL AS end_date
              ,SYSDATE AS import_date
              ,SYSDATE AS rec_updated_date
        FROM   VCCB_ACQ_BANK_BENEFIT_ACCT_TMP
        WHERE  acq_bank_code IS NOT NULL;
      COMMIT;
    END IF;
    Pr_Act_acq_bank_benefit_acct;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 500);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('Pr_Imp_acq_bank_benefit_acct'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'IMPORT DATA'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END Pr_Imp_acq_bank_benefit_acct;

  PROCEDURE pr_imp_reconciliation_stb AS
    l_Duplicate   NUMBER;
    l_import_date DATE;
    l_imp_session NUMBER(3) := 0;
    l_sqlErr      VARCHAR2(600);
  BEGIN
    l_import_date := trunc(SYSDATE);
    SELECT COUNT(*)
    INTO   l_Duplicate
    FROM   (SELECT MERCHANT_ID || TERMINAL_ID || reference_no || approve_code ||
                   to_char(trans_amount)
            FROM   vccb_reconciliation_stb_tmp
            WHERE  MERCHANT_ID IS NOT NULL
                   AND TERMINAL_ID IS NOT NULL
                   AND reference_no IS NOT NULL
                   AND approve_code IS NOT NULL
            GROUP  BY MERCHANT_ID || TERMINAL_ID || reference_no || approve_code ||
                      to_char(trans_amount)
            HAVING COUNT(*) > 1);
    IF l_Duplicate = 0
    THEN
      BEGIN
        SELECT MAX(imp_session)
        INTO   l_imp_session
        FROM   vccb_reconciliation_stb_imp
        WHERE  import_date = l_import_date;
      EXCEPTION
        WHEN no_data_found THEN
          l_imp_session := 0;
      END;
      l_imp_session := nvl(l_imp_session, 0) + 1;
      MERGE INTO vccb_reconciliation_stb_imp d
      USING (SELECT *
             FROM   vccb_reconciliation_stb_tmp
             WHERE  MERCHANT_ID IS NOT NULL
                    AND TERMINAL_ID IS NOT NULL
                    AND reference_no IS NOT NULL
                    AND approve_code IS NOT NULL) s
      ON (d.MERCHANT_ID = s.MERCHANT_ID AND d.TERMINAL_ID = s.TERMINAL_ID AND d.reference_no = s.reference_no AND d.approve_code = s.approve_code)
      WHEN NOT MATCHED THEN
        INSERT
          (merchant_id
          ,mm_dba_name
          ,terminal_id
          ,batch_no
          ,invoice_no
          ,settle_date
          ,settle_time
          ,trans_date
          ,trans_time
          ,card_no
          ,curr_rate
          ,billing_amount
          ,discount
          ,net_amount
          ,approve_code
          ,approve_code_sale
          ,proc_date
          ,book_date
          ,discount_rate
          ,crd_type
          ,status
          ,mm_biz_name
          ,acq_ref_no
          ,req_rec_id
          ,customer_description
          ,reference_no
          ,bill_code
          ,customer_name
          ,service_cd
          ,real_card
          ,qr_ssp
          ,transaction_id
          ,pos_entry
          ,curr_type
          ,order_id
          ,file_id
          ,imp_rec_id
          ,IMPORT_DATE
          ,IMP_SESSION
          ,rec_created_date
          ,rec_updated_date
          ,is_processed
          ,is_matched)
        VALUES
          (s.merchant_id
          ,s.mm_dba_name
          ,s.terminal_id
          ,s.batch_no
          ,s.invoice_no
          ,s.settle_date
          ,s.settle_time
          ,s.trans_date
          ,s.trans_time
          ,s.card_no
          ,s.curr_rate
          ,s.billing_amount
          ,s.discount
          ,s.net_amount
          ,s.approve_code
          ,s.approve_code_sale
          ,s.proc_date
          ,s.book_date
          ,s.discount_rate
          ,s.crd_type
          ,s.status
          ,s.mm_biz_name
          ,s.acq_ref_no
          ,s.req_rec_id
          ,s.customer_description
          ,s.reference_no
          ,s.bill_code
          ,s.customer_name
          ,s.service_cd
          ,s.real_card
          ,s.qr_ssp
          ,s.transaction_id
          ,s.pos_entry
          ,s.curr_type
          ,s.order_id
          ,s.file_id
          ,s.imp_rec_id
          ,l_import_date
          ,l_imp_session
          ,SYSDATE
          ,SYSDATE
          ,0
          ,0);
      COMMIT;
      pr_reconciliation_stb;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 500);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_imp_reconciliation_stb'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'IMPORT DATA'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END pr_imp_reconciliation_stb;

  PROCEDURE pr_reconciliation_stb AS
    l_import_date DATE;
  BEGIN
    l_import_date := trunc(SYSDATE);
    MERGE INTO vccb_reconciliation_stb_imp d
    USING (SELECT *
           FROM   vccb_atom_pos_settl_txn_imp
           WHERE  import_date >= l_import_date - 3
                  AND ACQ_BANK_CODE = '970403'
                  AND IS_PROCESSED = 1) s
    ON (d.merchant_id = s.merchant_id AND d.terminal_id = s.terminal_id AND d.approve_code = s.AUTH_ID_REPONSE AND d.reference_no = s.RETRIEVAL_REF_NO AND d.trans_amount = s.REQUEST_AMOUNT)
    WHEN MATCHED THEN
      UPDATE
      SET    d.is_processed     = 1
            ,d.is_matched       = CASE
                                    WHEN s.IS_SETTLE = 1
                                         AND s.RESPONSE_CODE = '00' THEN
                                     1
                                    ELSE
                                     0
                                  END
            ,d.rec_updated_date = SYSDATE
      WHERE  d.is_matched = 0
             AND d.import_date = l_import_date;
    COMMIT;
  
  END pr_reconciliation_stb;

  PROCEDURE pr_imp_reconciliation_vpb AS
    l_Duplicate   NUMBER;
    l_import_date DATE;
    l_imp_session NUMBER(3) := 0;
    l_sqlErr      VARCHAR2(600);
  BEGIN
    l_import_date := trunc(SYSDATE);
    SELECT COUNT(*)
    INTO   l_Duplicate
    FROM   (SELECT merchant_id || terminal_id || reference_no || approve_code ||
                   to_char(trans_amount)
            FROM   VCCB_RECONCILIATION_VPB_TMP
            WHERE  merchant_id IS NOT NULL
                   AND terminal_id IS NOT NULL
                   AND reference_no IS NOT NULL
                   AND approve_code IS NOT NULL
            GROUP  BY merchant_id || terminal_id || reference_no || approve_code ||
                      to_char(trans_amount)
            HAVING COUNT(*) > 1);
    IF l_Duplicate = 0
    THEN
      BEGIN
        SELECT MAX(imp_session)
        INTO   l_imp_session
        FROM   vccb_reconciliation_vpb_imp
        WHERE  import_date = l_import_date;
      EXCEPTION
        WHEN no_data_found THEN
          l_imp_session := 0;
      END;
      l_imp_session := nvl(l_imp_session, 0) + 1;
      MERGE INTO vccb_reconciliation_vpb_imp d
      USING (SELECT *
             FROM   VCCB_RECONCILIATION_VPB_TMP
             WHERE  merchant_id IS NOT NULL
                    AND terminal_id IS NOT NULL
                    AND reference_no IS NOT NULL
                    AND approve_code IS NOT NULL) s
      ON (d.merchant_id = s.merchant_id AND d.terminal_id = s.terminal_id AND d.reference_no = s.reference_no AND d.approve_code = s.approve_code)
      WHEN NOT MATCHED THEN
        INSERT
          (merchant_id
          ,terminal_id
          ,trans_type
          ,request_category
          ,trans_datetime
          ,approve_code
          ,card_no
          ,crd_type
          ,curr_type
          ,trans_amount
          ,fee_amount
          ,vat_amount
          ,reference_no
          ,status
          ,trans_condition
          ,contract_name
          ,order_id
          ,cybers_order_id
          ,cybers_purch_id
          ,file_id
          ,imp_rec_id
          ,IMPORT_DATE
          ,IMP_SESSION
          ,rec_created_date
          ,rec_updated_date
          ,is_processed
          ,is_matched)
        VALUES
          (s.merchant_id
          ,s.terminal_id
          ,s.trans_type
          ,s.request_category
          ,s.trans_datetime
          ,s.approve_code
          ,s.card_no
          ,s.crd_type
          ,s.curr_type
          ,s.trans_amount
          ,s.fee_amount
          ,s.vat_amount
          ,s.reference_no
          ,s.status
          ,s.trans_condition
          ,s.contract_name
          ,s.order_id
          ,s.cybers_order_id
          ,s.cybers_purch_id
          ,s.file_id
          ,s.imp_rec_id
          ,l_import_date
          ,l_imp_session
          ,SYSDATE
          ,SYSDATE
          ,0
          ,0);
      COMMIT;
      pr_reconciliation_vpb;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 500);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_imp_reconciliation_vpb'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END pr_imp_reconciliation_vpb;

  PROCEDURE pr_reconciliation_vpb AS
    l_import_date DATE;
    l_sqlErr      VARCHAR2(600);
  BEGIN
    l_import_date := trunc(SYSDATE);
    MERGE INTO vccb_reconciliation_vpb_imp d
    USING (SELECT *
           FROM   vccb_atom_pos_settl_txn_imp
           WHERE  import_date >= l_import_date - 3
                  AND ACQ_BANK_CODE = '970432'
                  AND IS_PROCESSED = 1) s
    ON (d.merchant_id = s.merchant_id AND d.terminal_id = s.terminal_id AND d.approve_code = s.AUTH_ID_REPONSE AND d.reference_no = s.RETRIEVAL_REF_NO AND d.trans_amount = s.REQUEST_AMOUNT)
    WHEN MATCHED THEN
      UPDATE
      SET    d.is_processed     = 1
            ,d.is_matched       = CASE
                                    WHEN s.IS_SETTLE = 1
                                         AND s.RESPONSE_CODE = '00' THEN
                                     1
                                    ELSE
                                     0
                                  END
            ,d.rec_updated_date = SYSDATE
      WHERE  d.is_matched = 0
             AND d.import_date = l_import_date;
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 500);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_imp_reconciliation_vpb'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END pr_reconciliation_vpb;

  FUNCTION fn_rnn(prefix IN VARCHAR) RETURN VARCHAR2 IS
    l_seq     VARCHAR2(12);
    l_max_len NUMBER(3) := 16;
    l_pad_len NUMBER(16);
  BEGIN
    l_seq     := to_char(vccb_fc_rrn_seq.nextval);
    l_pad_len := l_max_len - length(l_seq);
    RETURN rpad(prefix, l_pad_len, '0') || l_seq;
  
  END fn_rnn;

  FUNCTION fn_is_fc_posted(i_rrn IN VARCHAR2) RETURN BOOLEAN IS
    l_rec_counter NUMBER(6) := 0;
  BEGIN
    BEGIN
      SELECT COUNT(1) INTO l_rec_counter FROM actb_daily_log@FCLINK WHERE external_ref_no = i_rrn;
    EXCEPTION
      WHEN no_data_found THEN
        l_rec_counter := 0;
    END;
  
    RETURN CASE WHEN l_rec_counter > 0 THEN TRUE ELSE FALSE END;
  END fn_is_fc_posted;

  PROCEDURE pr_check_fc_posted
  (
    i_rrn              IN VARCHAR2
   ,o_is_skip_post     OUT BOOLEAN
   ,o_fc_ref_no        OUT VARCHAR2
   ,o_fc_txn_init_date OUT DATE
   ,o_rs_msg           OUT VARCHAR2
  ) IS
    l_rec_counter NUMBER(6) := 0;
    l_sqlErr      VARCHAR2(600);
  BEGIN
    IF i_rrn IS NULL
    THEN
      o_fc_ref_no        := NULL;
      o_fc_txn_init_date := NULL;
      o_rs_msg           := NULL;
      o_is_skip_post     := FALSE;
    ELSE
      -- check fc staus, if exist table post success
      BEGIN
        SELECT TRN_REF_NO
              ,TXN_INIT_DATE
              ,COUNT(external_ref_no) OVER(PARTITION BY external_ref_no) AS ref_no_count
        INTO   o_fc_ref_no
              ,o_fc_txn_init_date
              ,l_rec_counter
        FROM   actb_daily_log@FCLINK
        WHERE  external_ref_no = i_rrn
               AND NVL(ENTRY_SEQ_NO, 1) = 1;
      EXCEPTION
        WHEN no_data_found THEN
          l_rec_counter      := 0;
          o_is_skip_post     := FALSE;
          o_rs_msg           := 'No data found';
          o_fc_ref_no        := NULL;
          o_fc_txn_init_date := NULL;
        WHEN DUP_VAL_ON_INDEX THEN
          l_rec_counter      := 99;
          o_is_skip_post     := TRUE;
          o_rs_msg           := 'Duplicate record found';
          o_fc_ref_no        := NULL;
          o_fc_txn_init_date := NULL;
        
        WHEN OTHERS THEN
          o_fc_ref_no        := NULL;
          o_fc_txn_init_date := NULL;
          l_sqlErr           := substr(SQLERRM, 0, 480);
          o_is_skip_post     := TRUE;
          CASE
            WHEN SQLCODE = -12154 THEN
              o_rs_msg := 'TNS:could not resolve the connect identifier specified';
            WHEN SQLCODE = -2019 THEN
              o_rs_msg := 'Connection description for remote database not found';
            WHEN SQLCODE = -1017 THEN
              o_rs_msg := 'Invalid username/password; logon denied';
            WHEN SQLCODE = -2085 THEN
              o_rs_msg := 'Database link connects to different database';
            WHEN SQLCODE = -2020 THEN
              o_rs_msg := 'Too many database links in use';
            WHEN SQLCODE = -12545 THEN
              o_rs_msg := 'Connect failed because target host or object does not exist';
            ELSE
              o_rs_msg := 'Other error: ' || l_sqlErr;
          END CASE;
        
          l_rec_counter  := 99;
          o_is_skip_post := TRUE;
          INSERT INTO vccb_pro_error_history
            (process_name
            ,process_key
            ,error_msg
            ,note
            ,error_date
            ,process_id)
          VALUES
            ('pr_get_fc_ref_no'
            ,'ACQ_POS'
            ,l_sqlErr
            ,o_rs_msg
            ,SYSDATE
            ,-1);
          COMMIT;
      END;
    END IF;
  
    o_is_skip_post := CASE
                        WHEN l_rec_counter > 0
                             OR o_is_skip_post = TRUE THEN
                         TRUE
                        ELSE
                         FALSE
                      END;
  
  EXCEPTION
    WHEN OTHERS THEN
      o_is_skip_post     := TRUE;
      o_fc_ref_no        := NULL;
      o_fc_txn_init_date := NULL;
      l_sqlErr           := substr(SQLERRM, 0, 480);
    
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_get_fc_ref_no'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE'
        ,SYSDATE
        ,-1);
      COMMIT;
  END pr_check_fc_posted;

  PROCEDURE pr_acq_accounting_fc
  (
    o_rscode     OUT VARCHAR2
   ,o_rsdesc     OUT VARCHAR2
   ,i_process_dt IN DATE DEFAULT NULL
  ) AS
    l_process_dt      DATE;
    l_process_counter NUMBER(10);
    l_imp_session     NUMBER(3) := 0;
    l_rscode          VARCHAR2(2);
    l_rsdesc          VARCHAR2(250);
    l_sqlErr          VARCHAR2(600);
  BEGIN
    IF i_process_dt IS NULL
    THEN
      l_process_dt := trunc(SYSDATE);
    ELSE
      l_process_dt := trunc(i_process_dt);
    END IF;
  
    -- check data before process
    BEGIN
      SELECT COUNT(*)
      INTO   l_process_counter
      FROM   vccb_atom_pos_settl_txn_imp txn
            ,VCCB_ACQ_BANK_BENEFIT_ACCT  acq
      WHERE  txn.IMPORT_DATE = l_process_dt
             AND nvl(txn.is_processed, 0) = 0
             AND txn.IS_SETTLE = 1
             AND txn.RESPONSE_CODE = '00'
             AND txn.acq_bank_code = acq.acq_bank_code
             AND acq.active = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_rsdesc          := 'No data found';
        l_process_counter := 0;
        l_rscode          := '01';
    END; -- end check data before process
  
    IF l_process_counter > 0
    THEN
      MERGE INTO VCCB_ACQ_ACCOUNTING_FC d
      USING (SELECT txn.FILE_ID
                   ,txn.IMP_REC_ID
                   ,1 AS priority
                   ,'A' AS GROUP_NAME
                   ,acq.acq_bank_code
                   ,txn.merchant_name
                   ,txn.merchant_id
                   ,txn.terminal_id
                   ,txn.retrieval_ref_no
                   ,txn.batch_no
                   ,txn.txn_id
                   ,txn.IMPORT_DATE
                   ,txn.imp_session
                   ,'Record the total transaction amount to the suspense account' AS posting_name
                   ,acq.clearing_branch_code AS debit_branch_code
                   ,acq.clearing_account_number AS debit_account_number
                   ,acq.clearing_account_name AS debit_account_name
                   ,'VND' AS currency
                   ,nvl(REQUEST_AMOUNT, 0) posting_amt
                   ,acq.suspense_branh_code AS credit_branch_code
                   ,acq.suspense_account_number AS credit_account_number
                   ,acq.suspense_account_name AS credit_account_name
             FROM   vccb_atom_pos_settl_txn_imp txn
                   ,VCCB_ACQ_BANK_BENEFIT_ACCT  acq
             WHERE  txn.IMPORT_DATE = l_process_dt
                    AND nvl(txn.is_processed, 0) = 0
                    AND txn.IS_SETTLE = 1
                    AND txn.RESPONSE_CODE = '00'
                    AND txn.acq_bank_code = acq.acq_bank_code
                    AND acq.active = 1
             -- Nhom B
             UNION
             SELECT txn.FILE_ID
                   ,txn.IMP_REC_ID
                   ,5 AS priority
                   ,'B' AS GROUP_NAME
                   ,acq.acq_bank_code
                   ,txn.merchant_name
                   ,txn.merchant_id
                   ,txn.terminal_id
                   ,txn.retrieval_ref_no
                   ,txn.batch_no
                   ,txn.txn_id
                   ,txn.IMPORT_DATE
                   ,txn.imp_session
                   ,'Record the total payable sharing fees' AS posting_name
                   ,acq.Receivable_branch_code AS debit_branch_code
                   ,acq.Receivable_account_number AS debit_account_number
                   ,acq.Receivable_account_name AS debit_account_name
                   ,'VND' AS currency
                   ,nvl(txn.acq_bank_fee, 0) posting_amt
                   ,acq.clearing_branch_code AS credit_branch_code
                   ,acq.clearing_account_number AS credit_account_number
                   ,acq.clearing_account_name AS credit_account_name
             FROM   vccb_atom_pos_settl_txn_imp txn
                   ,VCCB_ACQ_BANK_BENEFIT_ACCT  acq
             WHERE  txn.IMPORT_DATE = l_process_dt
                    AND nvl(txn.is_processed, 0) = 0
                    AND txn.IS_SETTLE = 1
                    AND txn.RESPONSE_CODE = '00'
                    AND txn.acq_bank_code = acq.acq_bank_code
                    AND acq.active = 1
             UNION
             -- Nhom C
             SELECT txn.FILE_ID
                   ,txn.IMP_REC_ID
                   ,4 AS priority
                   ,'C' AS GROUP_NAME
                   ,acq.acq_bank_code
                   ,txn.merchant_name
                   ,txn.merchant_id
                   ,txn.terminal_id
                   ,txn.retrieval_ref_no
                   ,txn.batch_no
                   ,txn.txn_id
                   ,txn.IMPORT_DATE
                   ,txn.imp_session
                   ,'Record the total credited amount into the nostro account' AS posting_name
                   ,acq.deposit_branch_code AS debit_branch_code
                   ,acq.deposit_account_number AS debit_account_number
                   ,acq.deposit_account_name AS debit_account_name
                   ,'VND' AS currency
                   ,nvl(txn.bvb_credit_amt, 0) posting_amt
                   ,acq.clearing_branch_code AS credit_branch_code
                   ,acq.clearing_account_number AS credit_account_number
                   ,acq.clearing_account_name AS credit_account_name
             FROM   vccb_atom_pos_settl_txn_imp txn
                   ,VCCB_ACQ_BANK_BENEFIT_ACCT  acq
             WHERE  txn.IMPORT_DATE = l_process_dt
                    AND nvl(txn.is_processed, 0) = 0
                    AND txn.IS_SETTLE = 1
                    AND txn.RESPONSE_CODE = '00'
                    AND txn.acq_bank_code = acq.acq_bank_code
                    AND acq.active = 1
             UNION
             -- Nhom D
             SELECT txn.FILE_ID
                   ,txn.IMP_REC_ID
                   ,2 AS priority
                   ,'D' AS GROUP_NAME
                   ,acq.acq_bank_code
                   ,txn.merchant_name
                   ,txn.merchant_id
                   ,txn.terminal_id
                   ,txn.retrieval_ref_no
                   ,txn.batch_no
                   ,txn.txn_id
                   ,txn.IMPORT_DATE
                   ,txn.imp_session
                   ,'Record the total credited amount to merchant' AS posting_name
                   ,acq.suspense_branh_code AS debit_branch_code
                   ,acq.suspense_account_number AS debit_account_number
                   ,acq.suspense_account_name AS debit_account_name
                   ,'VND' AS currency
                   ,nvl(txn.merchant_credit_amt, 0) posting_amt
                   ,substr(txn.account_number, 0, 3) AS credit_branch_code
                   ,txn.account_number AS credit_account_number
                   ,txn.account_name AS credit_account_name
             FROM   vccb_atom_pos_settl_txn_imp txn
                   ,VCCB_ACQ_BANK_BENEFIT_ACCT  acq
             WHERE  txn.IMPORT_DATE = l_process_dt
                    AND nvl(txn.is_processed, 0) = 0
                    AND txn.IS_SETTLE = 1
                    AND txn.RESPONSE_CODE = '00'
                    AND txn.acq_bank_code = acq.acq_bank_code
                    AND acq.active = 1
             -- Nhom E
             UNION
             SELECT txn.FILE_ID
                   ,txn.IMP_REC_ID
                   ,3 AS priority
                   ,'E' AS GROUP_NAME
                   ,acq.acq_bank_code
                   ,txn.merchant_name
                   ,txn.merchant_id
                   ,txn.terminal_id
                   ,txn.retrieval_ref_no
                   ,txn.batch_no
                   ,txn.txn_id
                   ,txn.IMPORT_DATE
                   ,txn.imp_session
                   ,'Record the total receivable discount fees' AS posting_name
                   ,acq.suspense_branh_code AS debit_branch_code
                   ,acq.suspense_account_number AS debit_account_number
                   ,acq.suspense_account_name AS debit_account_name
                   ,'VND' AS currency
                   ,nvl(txn.discount_amt, 0) posting_amt
                   ,acq.Receivable_branch_code AS credit_branch_code
                   ,acq.Receivable_account_number AS credit_account_number
                   ,acq.Receivable_account_name AS credit_account_name
             FROM   vccb_atom_pos_settl_txn_imp txn
                   ,VCCB_ACQ_BANK_BENEFIT_ACCT  acq
             WHERE  txn.IMPORT_DATE = l_process_dt
                    AND nvl(txn.is_processed, 0) = 0
                    AND txn.IS_SETTLE = 1
                    AND txn.RESPONSE_CODE = '00'
                    AND txn.acq_bank_code = acq.acq_bank_code) s
      ON (d.txn_id = s.txn_id AND d.acq_bank_code = s.acq_bank_code AND d.merchant_id = s.merchant_id AND d.terminal_id = s.terminal_id AND d.retrieval_ref_no = s.retrieval_ref_no)
      WHEN NOT MATCHED THEN
        INSERT
          (file_id
          ,imp_rec_id
          ,txn_id
          ,priority
          ,group_name
          ,acq_bank_code
          ,merchant_name
          ,merchant_id
          ,terminal_id
          ,retrieval_ref_no
          ,batch_no
          ,posting_name
          ,debit_branch_code
          ,debit_account_number
          ,debit_account_name
          ,currency
          ,posting_amt
          ,credit_branch_code
          ,credit_account_number
          ,credit_account_name
          ,is_processed
          ,is_successed
          ,process_dt
          ,imp_session
          ,rec_created_date)
        VALUES
          (s.file_id
          ,s.imp_rec_id
          ,s.txn_id
          ,s.priority
          ,s.group_name
          ,s.acq_bank_code
          ,s.merchant_name
          ,s.merchant_id
          ,s.terminal_id
          ,s.retrieval_ref_no
          ,s.batch_no
          ,s.posting_name
          ,s.debit_branch_code
          ,s.debit_account_number
          ,s.debit_account_name
          ,s.currency
          ,s.posting_amt
          ,s.credit_branch_code
          ,s.credit_account_number
          ,s.credit_account_name
          ,0
          ,0
          ,trunc(s.import_date)
          ,s.imp_session
          ,SYSDATE);
    
      COMMIT;
    
    END IF; -- end check counter before process and process data
  
    -- get max imp session
    BEGIN
      SELECT MAX(imp_session)
      INTO   l_imp_session
      FROM   vccb_atom_pos_settl_txn_imp
      WHERE  import_date = l_process_dt;
    EXCEPTION
      WHEN no_data_found THEN
        l_imp_session := 0;
    END;
    -- end get max import session
  
    -- check data after process
    BEGIN
      SELECT COUNT(*)
      INTO   l_process_counter
      FROM   VCCB_ACQ_ACCOUNTING_FC
      WHERE  process_dt = l_process_dt
             AND imp_session = l_imp_session;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_rsdesc          := 'No data found after process';
        l_process_counter := 0;
        l_rscode          := '02';
    END; -- end check data after process
  
    o_rscode := CASE
                  WHEN l_process_counter > 0 THEN
                   '00'
                  ELSE
                   l_rscode
                END;
    o_rsdesc := CASE
                  WHEN l_process_counter > 0 THEN
                   'success'
                  ELSE
                   l_rsdesc
                END;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 420);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_acq_accounting_fc'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE - PROCESS TXN BEFORE POST TO FC'
        ,SYSDATE
        ,-1);
      COMMIT;
      o_rscode := '96';
      o_rsdesc := 'ERROR WHEN EXECUTE ' || l_sqlErr;
  END pr_acq_accounting_fc;

  PROCEDURE pr_update_acq_account_fc
  (
    i_file_id        IN NUMBER
   ,i_group_name     IN VARCHAR2
   ,i_priority       IN NUMBER
   ,i_rrn            IN VARCHAR2
   ,i_fcref          IN VARCHAR2
   ,i_debt_acct_no   IN VARCHAR2
   ,i_crd_acct_no    IN VARCHAR2
   ,i_is_process     IN NUMBER
   ,i_resultcode     IN VARCHAR2
   ,i_resultdesc     IN VARCHAR2
   ,i_posting_rsdesc IN NVARCHAR2
   ,i_posting_date   IN DATE
   ,i_narrative      IN VARCHAR2
   ,i_errCode        IN VARCHAR2
   ,i_acq_bank_code  IN VARCHAR2
   ,i_merchant_id    IN VARCHAR2
   ,i_process_dt     IN DATE
  ) AS
    l_sqlErr VARCHAR2(600);
  BEGIN
  
    UPDATE VCCB_ACQ_ACCOUNTING_FC
    SET    is_processed     = i_is_process
          ,is_successed = CASE
                            WHEN i_is_process = 1
                                 AND i_resultcode = '00'
                                 AND lower(i_resultdesc) = 'success' THEN
                             1
                            ELSE
                             0
                          END
          ,FC_RESULTCODE = CASE
                             WHEN i_resultcode IS NOT NULL THEN
                              i_resultcode
                             ELSE
                              FC_RESULTCODE
                           END
          ,FC_RESULTDESC = CASE
                             WHEN i_resultdesc IS NOT NULL THEN
                              i_resultdesc
                             ELSE
                              FC_RESULTDESC
                           END
          ,POSTING_DATE = CASE
                            WHEN i_is_process = 1
                                 AND i_resultcode = '00'
                                 AND lower(i_resultdesc) = 'success' THEN
                             i_posting_date
                            WHEN i_posting_date IS NULL THEN
                             POSTING_DATE
                            ELSE
                             NULL
                          END
          ,STATUS = CASE
                      WHEN i_posting_rsdesc IS NOT NULL THEN
                       i_posting_rsdesc
                      ELSE
                       STATUS
                    END
          ,rrn = CASE
                   WHEN i_rrn IS NOT NULL THEN
                    i_rrn
                   ELSE
                    rrn
                 END
          ,FC_REF = CASE
                      WHEN i_fcref IS NOT NULL THEN
                       i_fcref
                      ELSE
                       FC_REF
                    END
          ,narrative = CASE
                         WHEN i_narrative IS NOT NULL THEN
                          i_narrative
                         ELSE
                          narrative
                       END
          ,RUN_NUMBER       = nvl(RUN_NUMBER, 0) + 1
          ,error_message = CASE
                             WHEN i_errCode IS NOT NULL THEN
                              i_errCode
                             ELSE
                              error_message
                           END
          ,REC_UPDATED_DATE = SYSDATE
    WHERE  FILE_ID = i_file_id
           AND process_dt = i_process_dt
           AND PRIORITY = i_priority
           AND group_name = i_group_name
           AND DEBIT_ACCOUNT_NUMBER = i_debt_acct_no
           AND CREDIT_ACCOUNT_NUMBER = i_crd_acct_no
           AND (i_acq_bank_code IS NULL OR acq_bank_code = i_acq_bank_code)
           AND (i_merchant_id IS NULL OR merchant_id = i_merchant_id);
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 420);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_update_acq_account_fc'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE - PROCESS TXN AFTER POST TO FC'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END pr_update_acq_account_fc;

  PROCEDURE pr_update_atom_sett_txn
  (
    i_group_name IN VARCHAR2
   ,i_process_dt IN DATE
  ) AS
    l_sqlErr VARCHAR2(600);
  BEGIN
    MERGE INTO vccb_atom_pos_settl_txn_imp d
    USING (SELECT FILE_ID
                 ,IMP_REC_ID
                 ,retrieval_ref_no
                 ,acq_bank_code
                 ,merchant_id
                 ,terminal_id
                 ,txn_id
                 ,POSTING_DATE
                 ,is_successed
           FROM   VCCB_ACQ_ACCOUNTING_FC
           WHERE  process_dt = i_process_dt
                  AND GROUP_NAME = i_group_name) s
    ON (d.FILE_ID = s.FILE_ID AND d.IMP_REC_ID = s.IMP_REC_ID)
    WHEN MATCHED THEN
      UPDATE
      SET    d.POSTING_DATE     = s.POSTING_DATE
            ,d.posting_rscode   = CASE
                                    WHEN nvl(s.is_successed, 0) = 0 THEN
                                     '01'
                                    WHEN nvl(s.is_successed, 0) = 1 THEN
                                     '00'
                                    ELSE
                                     '02'
                                  END
            ,d.posting_rsdesc   = CASE
                                    WHEN nvl(s.is_successed, 0) = 0 THEN
                                     'GROUP ' || i_group_name || ' NOT POSTING'
                                    WHEN nvl(s.is_successed, 0) = 1 THEN
                                     'POSTING GROUP ' || i_group_name || ' - SUCCESS'
                                    ELSE
                                     'GROUP ' || i_group_name || ' NOT POSTING'
                                  END
            ,d.rec_updated_date = SYSDATE;
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 420);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_update_atom_sett_txn'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE - PROCESS UPDATE ATOM SETT TXN'
        ,SYSDATE
        ,-1);
      COMMIT;
    
  END pr_update_atom_sett_txn;

  PROCEDURE pr_acq_auto_credit_bvb
  (
    o_rscode     OUT VARCHAR2
   ,o_rsdesc     OUT VARCHAR2
   ,i_group_name IN VARCHAR2
   ,i_process_dt IN DATE DEFAULT NULL
  ) AS
    l_resultcode   VARCHAR2(50) := '';
    l_resultdesc   VARCHAR2(50) := '';
    l_fcref        VARCHAR2(50) := '';
    l_process_dt   DATE;
    l_posting_date DATE;
    l_rrn          VARCHAR2(20);
    l_narrative    VARCHAR2(200);
    l_is_process   NUMBER(1) := 0;
  
    l_errCode VARCHAR2(500);
  
    l_posting_rscode VARCHAR2(2); -- process error
    l_posting_rsdesc NVARCHAR2(250);
  
    l_grp_counter NUMBER(8) := 0;
    l_grp_rs      NUMBER(8) := 0;
  
    l_sqlErr VARCHAR2(600);
  
  BEGIN
    o_rscode := '96'; -- Default success code
    o_rsdesc := 'GROUP ' || i_group_name || ' PROCESS IS NOT SUCCESS';
    IF i_process_dt IS NULL
    THEN
      l_process_dt := trunc(SYSDATE);
    ELSE
      l_process_dt := i_process_dt;
    END IF;
    -- counter all A
    BEGIN
      SELECT COUNT(*)
      INTO   l_grp_counter
      FROM   VCCB_ACQ_ACCOUNTING_FC
      WHERE  process_dt = l_process_dt
             AND GROUP_NAME = i_group_name;
    EXCEPTION
      WHEN no_data_found THEN
        l_grp_counter := 0;
    END;
    --PROCESS
    IF l_grp_counter > 0
    THEN
      FOR credit_rec IN (
                         -- Group A: hach toan tong tien BVB dc bao co
                         SELECT FILE_ID
                                ,PRIORITY
                                ,GROUP_NAME
                                ,acq_bank_code
                                ,DEBIT_ACCOUNT_NUMBER
                                ,CREDIT_ACCOUNT_NUMBER
                                ,rrn
                                ,SUM(POSTING_AMT) POSTING_AMT
                         FROM   VCCB_ACQ_ACCOUNTING_FC
                         WHERE  process_dt = l_process_dt
                                AND nvl(is_successed, 0) = 0
                                AND GROUP_NAME = i_group_name
                         GROUP  BY FILE_ID
                                   ,PRIORITY
                                   ,GROUP_NAME
                                   ,acq_bank_code
                                   ,DEBIT_ACCOUNT_NUMBER
                                   ,CREDIT_ACCOUNT_NUMBER
                                   ,rrn
                         ORDER  BY PRIORITY)
      LOOP
        DECLARE
          l_is_skip BOOLEAN;
        BEGIN
          pr_check_fc_posted(i_rrn              => credit_rec.rrn
                            ,o_is_skip_post     => l_is_skip
                            ,o_fc_ref_no        => l_fcref
                            ,o_fc_txn_init_date => l_posting_date
                            ,o_rs_msg           => l_errCode);
          IF l_is_skip = FALSE
          THEN
          
            --start post to FC
            BEGIN
              l_is_process   := 0;
              l_narrative    := 'KC SO TIEN GIAO DICH PHAI THU NGAY ' ||
                                to_char(SYSDATE, 'DD/MM/YYYY') || ' VAO TK TT BU TRU VOI ' ||
                                credit_rec.acq_bank_code;
              l_rrn          := fn_rnn('ACQ');
              l_posting_date := SYSDATE;
            
              FCUBSIT2.bvbpks_auto_cardpayment.pr_merchant_tran@FCLINK(drac       => credit_rec.DEBIT_ACCOUNT_NUMBER
                                                                      ,crac       => credit_rec.CREDIT_ACCOUNT_NUMBER
                                                                      ,amount     => credit_rec.posting_amt
                                                                      ,narrative  => l_narrative
                                                                      ,trndate    => l_posting_date
                                                                      ,rrn        => l_rrn
                                                                      ,resultcode => l_resultcode
                                                                      ,resultdesc => l_resultdesc
                                                                      ,fcref      => l_fcref);
              l_is_process     := 1;
              l_posting_rsdesc := 'GROUP ' || i_group_name || ' PROCECCED';
            EXCEPTION
            
              WHEN OTHERS THEN
              
                IF SQLCODE = -12154
                THEN
                  l_posting_rscode := '01';
                  l_posting_rsdesc := 'PROCESS GROUP ' || i_group_name || ' DBLINK TIMEOUT';
                  l_errCode        := 'DBLink timeout' || substr(SQLERRM, 1, 480);
                ELSE
                  l_posting_rscode := '02';
                  l_posting_rsdesc := 'PROCESS GROUP ' || i_group_name || ' ERROR';
                  l_errCode        := substr(SQLERRM, 1, 499);
                END IF;
                l_is_process := 0;
            END; -- end post FC
          ELSE
            -- check is skip: error when check or exist FC
            l_narrative      := NULL;
            l_rrn            := credit_rec.rrn;
            l_posting_rsdesc := 'PROCESS GROUP ' || i_group_name ||
                                ' FC PROCECCED | IS RE-CHECK FC';
          
            IF l_fcref IS NOT NULL
            THEN
              -- check if: exist rrn in FC mask success
              l_resultcode := '00';
              l_resultdesc := 'Success';
              l_is_process := 1;
            ELSE
              l_resultcode := NULL;
              l_resultdesc := NULL;
              l_is_process := 0;
            END IF;
          
          END IF;
          pr_update_acq_account_fc(i_file_id        => credit_rec.file_id
                                  ,i_group_name     => credit_rec.group_name
                                  ,i_priority       => credit_rec.priority
                                  ,i_rrn            => l_rrn
                                  ,i_fcref          => l_fcref
                                  ,i_debt_acct_no   => credit_rec.debit_account_number
                                  ,i_crd_acct_no    => credit_rec.credit_account_number
                                  ,i_is_process     => l_is_process
                                  ,i_resultcode     => l_resultcode
                                  ,i_resultdesc     => l_resultdesc
                                  ,i_posting_rsdesc => l_posting_rsdesc
                                  ,i_posting_date   => l_posting_date
                                  ,i_narrative      => l_narrative
                                  ,i_errCode        => l_errCode
                                  ,i_acq_bank_code  => credit_rec.acq_bank_code
                                  ,i_merchant_id    => NULL
                                  ,i_process_dt     => l_process_dt);
        
        END; -- end khoi loop
      END LOOP;
      --- END GROUP 
    
      -- update status nhom A
      pr_update_atom_sett_txn(i_group_name => i_group_name, i_process_dt => l_process_dt);
    END IF; -- end count and process
    --counter all completed
    BEGIN
      SELECT COUNT(*)
      INTO   l_grp_rs
      FROM   VCCB_ACQ_ACCOUNTING_FC
      WHERE  process_dt = l_process_dt
             AND nvl(is_successed, 0) = 1
             AND GROUP_NAME = i_group_name;
    
    EXCEPTION
      WHEN no_data_found THEN
        l_grp_rs := 0;
    END;
    --end counter all completed
    -- check
    IF l_grp_counter = 0
    THEN
      l_posting_rscode := '03';
      l_posting_rsdesc := 'GROUP ' || i_group_name || ' NOT DATA TO PROCESS: ' || TO_CHAR(l_grp_rs) || '/' ||
                          TO_CHAR(l_grp_counter);
    ELSIF l_grp_rs = 0
    THEN
      l_posting_rscode := '04';
      l_posting_rsdesc := 'POSTING GROUP ' || i_group_name || ' NOT SUCCESS: ' || TO_CHAR(l_grp_rs) || '/' ||
                          TO_CHAR(l_grp_counter);
    ELSIF l_grp_rs < l_grp_counter
    THEN
      l_posting_rscode := '05';
      l_posting_rsdesc := 'POSTING GROUP ' || i_group_name || ' COMPLETE: ' || TO_CHAR(l_grp_rs) || '/' ||
                          TO_CHAR(l_grp_counter);
    ELSIF l_grp_counter > 0
          AND l_grp_counter = l_grp_rs
    THEN
      l_posting_rscode := '00';
      l_posting_rsdesc := 'GROUP ' || i_group_name || ' SUCCESS';
    
    END IF; -- end check group a completed
  
    o_rscode := l_posting_rscode; -- Default success code
    o_rsdesc := l_posting_rsdesc;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 420);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_acq_auto_credit_bvb'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE - PROCESS TXN BEFORE POST TO FC'
        ,SYSDATE
        ,-1);
      COMMIT;
      o_rscode := '96';
      o_rsdesc := 'ERROR WHEN EXECUTE ' || l_sqlErr;
    
  END pr_acq_auto_credit_bvb;

  FUNCTION fn_get_acq_merchant_name
  (
    i_file_id     IN NUMBER
   ,i_merchant_id IN VARCHAR2
   ,i_priority    IN NUMBER
   ,i_group_name  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_merchant_name VARCHAR2(250);
  
  BEGIN
    SELECT MERCHANT_NAME
    INTO   l_merchant_name
    FROM   VCCB_ACQ_ACCOUNTING_FC
    WHERE  FILE_ID = i_file_id
           AND MERCHANT_ID = i_merchant_id
           AND PRIORITY = i_priority
           AND GROUP_NAME = i_group_name
           AND rownum = 1;
    RETURN l_merchant_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '';
    
  END fn_get_acq_merchant_name;

  PROCEDURE pr_acq_auto_credit_merchant
  (
    o_rscode     OUT VARCHAR2
   ,o_rsdesc     OUT VARCHAR2
   ,i_group_name IN VARCHAR2
   ,i_process_dt IN DATE DEFAULT NULL
  ) AS
    l_resultcode   VARCHAR2(50) := '';
    l_resultdesc   VARCHAR2(50) := '';
    l_fcref        VARCHAR2(50) := '';
    l_process_dt   DATE;
    l_posting_date DATE;
    l_rrn          VARCHAR2(20);
    l_narrative    VARCHAR2(200);
    l_is_process   NUMBER(1) := 0;
  
    l_errCode VARCHAR2(500);
  
    l_posting_rscode VARCHAR2(2); -- process error
    l_posting_rsdesc NVARCHAR2(250);
  
    l_grp_counter NUMBER(8) := 0;
    l_grp_rs      NUMBER(8) := 0;
  
    l_sqlErr VARCHAR2(600);
  
  BEGIN
    o_rscode := '96'; -- Default success code
    o_rsdesc := 'GROUP ' || i_group_name || ' PROCESS IS NOT SUCCESS';
    IF i_process_dt IS NULL
    THEN
      l_process_dt := trunc(SYSDATE);
    ELSE
      l_process_dt := i_process_dt;
    END IF;
  
    -- counter all 
    BEGIN
      SELECT COUNT(*)
      INTO   l_grp_counter
      FROM   VCCB_ACQ_ACCOUNTING_FC
      WHERE  process_dt = l_process_dt
             AND GROUP_NAME = i_group_name;
    EXCEPTION
      WHEN no_data_found THEN
        l_grp_counter := 0;
    END;
    IF l_grp_counter > 0
    THEN
      FOR credit_rec IN (
                         -- D: hach toan tien bao co cho don vi chap nhan the
                         SELECT FILE_ID
                                ,PRIORITY
                                ,GROUP_NAME
                                ,MERCHANT_ID
                                ,DEBIT_ACCOUNT_NUMBER
                                ,CREDIT_ACCOUNT_NUMBER
                                ,rrn
                                ,SUM(POSTING_AMT) POSTING_AMT
                         FROM   VCCB_ACQ_ACCOUNTING_FC
                         WHERE  process_dt = l_process_dt
                                AND nvl(is_successed, 0) = 0
                                AND GROUP_NAME = i_group_name
                         GROUP  BY FILE_ID
                                   ,PRIORITY
                                   ,GROUP_NAME
                                   ,MERCHANT_ID
                                   ,DEBIT_ACCOUNT_NUMBER
                                   ,CREDIT_ACCOUNT_NUMBER
                                   ,rrn
                         ORDER  BY PRIORITY
                                   ,GROUP_NAME
                         
                         )
      LOOP
        DECLARE
          l_is_skip       BOOLEAN;
          l_merchant_name VARCHAR2(250);
        BEGIN
          pr_check_fc_posted(i_rrn              => credit_rec.rrn
                            ,o_is_skip_post     => l_is_skip
                            ,o_fc_ref_no        => l_fcref
                            ,o_fc_txn_init_date => l_posting_date
                            ,o_rs_msg           => l_errCode);
          IF l_is_skip = FALSE
          THEN
            BEGIN
              l_is_process    := 0;
              l_merchant_name := fn_get_acq_merchant_name(i_file_id     => credit_rec.file_id
                                                         ,i_merchant_id => credit_rec.merchant_id
                                                         ,i_priority    => credit_rec.priority
                                                         ,i_group_name  => credit_rec.group_name);
              l_narrative := CASE
                               WHEN i_group_name = 'D' THEN
                                'BVBANK THANH TOAN CONG NO POS NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') ||
                                ' CHO ' || l_merchant_name
                               WHEN i_group_name = 'E' THEN
                                'PHI CHIET KHAU POS NGAY ' || to_char(SYSDATE, 'DD/MM/YYYY') || ' PHAI THU ' ||
                                l_merchant_name
                               ELSE
                                ''
                             END;
              l_rrn           := fn_rnn('ACQ');
              l_posting_date  := SYSDATE;
              FCUBSIT2.bvbpks_auto_cardpayment.pr_merchant_tran@FCLINK(drac       => credit_rec.debit_account_number
                                                                      ,crac       => credit_rec.credit_account_number
                                                                      ,amount     => credit_rec.posting_amt
                                                                      ,narrative  => l_narrative
                                                                      ,trndate    => l_posting_date
                                                                      ,rrn        => l_rrn
                                                                      ,resultcode => l_resultcode
                                                                      ,resultdesc => l_resultdesc
                                                                      ,fcref      => l_fcref);
              l_is_process     := 1;
              l_posting_rsdesc := 'GROUP ' || i_group_name || ' PROCECCED';
            EXCEPTION
            
              WHEN OTHERS THEN
              
                IF SQLCODE = -12154
                THEN
                  l_posting_rscode := '01';
                  l_posting_rsdesc := 'PROCESS GROUP ' || i_group_name || ' DBLINK TIMEOUT';
                  l_errCode        := 'DBLink timeout' || substr(SQLERRM, 1, 480);
                ELSE
                  l_posting_rscode := '02';
                  l_posting_rsdesc := 'PROCESS GROUP ' || i_group_name || ' ERROR';
                  l_errCode        := substr(SQLERRM, 1, 499);
                END IF;
                l_is_process := 0;
            END; -- end post FC
          ELSE
            -- check is skip: error when check or exist FC
            l_narrative      := NULL;
            l_rrn            := credit_rec.rrn;
            l_posting_rsdesc := 'PROCESS GROUP ' || i_group_name ||
                                ' FC PROCECCED | IS RE-CHECK FC';
          
            IF l_fcref IS NOT NULL
            THEN
              -- check if: exist rrn in FC mask success
              l_resultcode := '00';
              l_resultdesc := 'Success';
              l_is_process := 1;
            ELSE
              l_resultcode := NULL;
              l_resultdesc := NULL;
              l_is_process := 0;
            END IF;
          
          END IF;
          pr_update_acq_account_fc(i_file_id        => credit_rec.file_id
                                  ,i_group_name     => credit_rec.group_name
                                  ,i_priority       => credit_rec.priority
                                  ,i_rrn            => l_rrn
                                  ,i_fcref          => l_fcref
                                  ,i_debt_acct_no   => credit_rec.debit_account_number
                                  ,i_crd_acct_no    => credit_rec.credit_account_number
                                  ,i_is_process     => l_is_process
                                  ,i_resultcode     => l_resultcode
                                  ,i_resultdesc     => l_resultdesc
                                  ,i_posting_rsdesc => l_posting_rsdesc
                                  ,i_posting_date   => l_posting_date
                                  ,i_narrative      => l_narrative
                                  ,i_errCode        => l_errCode
                                  ,i_acq_bank_code  => NULL
                                  ,i_merchant_id    => credit_rec.merchant_id
                                  ,i_process_dt     => l_process_dt);
        
        END; -- end khoi loop
      END LOOP;
    
      -- end hach toan  nhom D,E
      pr_update_atom_sett_txn(i_group_name => i_group_name, i_process_dt => l_process_dt);
    END IF; -- end check rec to process
    --counter all completed
    BEGIN
      SELECT COUNT(*)
      INTO   l_grp_rs
      FROM   VCCB_ACQ_ACCOUNTING_FC
      WHERE  process_dt = l_process_dt
             AND nvl(is_successed, 0) = 1
             AND GROUP_NAME = i_group_name;
    
    EXCEPTION
      WHEN no_data_found THEN
        l_grp_rs := 0;
    END;
  
    -- check
    IF l_grp_counter = 0
    THEN
      l_posting_rscode := '03';
      l_posting_rsdesc := 'GROUP ' || i_group_name || ' NOT DATA TO PROCESS: ' || TO_CHAR(l_grp_rs) || '/' ||
                          TO_CHAR(l_grp_counter);
    ELSIF l_grp_rs = 0
    THEN
      l_posting_rscode := '04';
      l_posting_rsdesc := 'POSTING GROUP ' || i_group_name || ' NOT SUCCESS: ' || TO_CHAR(l_grp_rs) || '/' ||
                          TO_CHAR(l_grp_counter);
    ELSIF l_grp_rs < l_grp_counter
    THEN
      l_posting_rscode := '05';
      l_posting_rsdesc := 'POSTING GROUP ' || i_group_name || ' COMPLETE: ' || TO_CHAR(l_grp_rs) || '/' ||
                          TO_CHAR(l_grp_counter);
    ELSIF l_grp_counter > 0
          AND l_grp_counter = l_grp_rs
    THEN
      l_posting_rscode := '00';
      l_posting_rsdesc := 'GROUP ' || i_group_name || ' SUCCESS';
    
    END IF; -- end check group a completed
  
    o_rscode := l_posting_rscode; -- Default success code
    o_rsdesc := l_posting_rsdesc;
  
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 420);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_acq_auto_credit_merchant'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE - PROCESS TXN BEFORE POST TO FC'
        ,SYSDATE
        ,-1);
      COMMIT;
      o_rscode := '96';
      o_rsdesc := 'ERROR WHEN EXECUTE ' || l_sqlErr;
    
  END pr_acq_auto_credit_merchant;

  PROCEDURE pr_acq_auto_credit
  (
    o_rscode     OUT VARCHAR2
   ,o_rsdesc     OUT VARCHAR2
   ,i_process_dt IN DATE DEFAULT NULL
  ) AS
  
    l_process_dt DATE;
  
    l_posting_rscode VARCHAR2(2); -- process error
    l_posting_rsdesc VARCHAR2(100);
  
    l_sqlErr VARCHAR2(600);
  
  BEGIN
    o_rscode := '96'; -- Default success code
    o_rsdesc := 'PROCESS IS NOT SUCCESS';
    IF i_process_dt IS NULL
    THEN
      l_process_dt := trunc(SYSDATE);
    ELSE
      l_process_dt := i_process_dt;
    END IF;
  
    pr_acq_auto_credit_bvb(o_rscode     => l_posting_rscode
                          ,o_rsdesc     => l_posting_rsdesc
                          ,i_group_name => 'A'
                          ,i_process_dt => l_process_dt);
  
    IF l_posting_rscode = '00'
    THEN
      -- Xu li cac nhom kha
    
      pr_acq_auto_credit_merchant(o_rscode     => l_posting_rscode
                                 ,o_rsdesc     => l_posting_rsdesc
                                 ,i_group_name => 'D'
                                 ,i_process_dt => l_process_dt);
      pr_acq_auto_credit_merchant(o_rscode     => l_posting_rscode
                                 ,o_rsdesc     => l_posting_rsdesc
                                 ,i_group_name => 'E'
                                 ,i_process_dt => l_process_dt);
    END IF;
    o_rscode := l_posting_rscode; -- Default success code
    o_rsdesc := l_posting_rsdesc;
  EXCEPTION
    WHEN OTHERS THEN
      l_sqlErr := substr(SQLERRM, 0, 420);
      INSERT INTO vccb_pro_error_history
        (process_name
        ,process_key
        ,error_msg
        ,note
        ,error_date
        ,process_id)
      VALUES
        ('pr_acq_auto_credit'
        ,'ACQ_POS'
        ,l_sqlErr
        ,'SCHEDULE - PROCESS TXN BEFORE POST TO FC'
        ,SYSDATE
        ,-1);
      COMMIT;
      o_rscode := '96';
      o_rsdesc := 'ERROR WHEN EXECUTE ' || l_sqlErr;
    
  END pr_acq_auto_credit;

END bvbpks_Acq_Pos_Api;
/
