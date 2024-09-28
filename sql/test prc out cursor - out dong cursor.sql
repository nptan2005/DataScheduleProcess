DECLARE
  v_out_cursor   SYS_REFCURSOR;
  v_cursor_id    INTEGER;
  v_column_value VARCHAR2(4000);
  v_column_count INTEGER;
  v_desc_tab     DBMS_SQL.DESC_TAB;
  counter number:= 0;
BEGIN
 /* DBMS_SESSION.RESET_PACKAGE;*/
  -- Gọi procedure để lấy cursor
   bvbpks_momo_installment_process.pr_get_installment_list(i_card_account => '90443485001'
  ,o_res       => v_out_cursor);
 /*    bvbpks_momo_installment_process.pr_card_balance_inq(i_card_account => '90443485001'
  ,o_res       => v_out_cursor);*/
  /* bvbpks_momo_installment_process.pr_inq_inst_txn(i_translip => '34260532765',i_card_account => '90443485001', i_inst_time => 12, i_fee_code => 'test', i_fee_amt => 10000
  ,o_res       => v_out_cursor);*/
  /* bvbpks_momo_installment_process.pr_get_installed_list(i_card_account => '90443485001'
  ,o_res       => v_out_cursor);*/
/*  bvbpks_momo_installment_process.pr_get_installed_txn(i_translip => '34260532765' , i_card_account => '90443485001'
  ,o_res       => v_out_cursor);*/
/*  bvbpks_momo_installment_process.pr_test_logi(i_card_code => '34260533123'
                                              ,o_res       => v_out_cursor);*/
/*  bvbpks_momo_installment_process.pr_card_balance_inq(i_card_code => '0009044348500461882708401'
  ,o_res       => v_out_cursor);*/
  
  
  /*  bvbpks_momo_installment_process.pr_request_installment(i_translip => '34260532765', i_card_account => '90443485001',i_inst_time => 12,i_fee_code => 'abc',i_fee_amt => 768, i_func_request_id => 904434850046188212 
  ,o_res       => v_out_cursor);*/

  -- Chuyển đổi cursor thành DBMS_SQL cursor
  v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(v_out_cursor);

  -- Lấy số lượng cột
  DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_column_count, v_desc_tab);

  -- Xác định các cột
  FOR i IN 1 .. v_column_count
  LOOP
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_column_value, 4000);
  END LOOP;

  -- Lấy dữ liệu từ cursor
  
  WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0
  LOOP
    counter := counter + 1;
    DBMS_OUTPUT.PUT_LINE('Row: ' || to_char(counter));
    FOR i IN 1 .. v_column_count
    LOOP
      DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_column_value);
      /*DBMS_OUTPUT.PUT_LINE(v_desc_tab(i)
                           .col_name || ' (' || v_desc_tab(i).col_type || '): ' || v_column_value);*/
       DBMS_OUTPUT.PUT_LINE(v_desc_tab(i).col_name || ': '|| v_column_value);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('---------------------------');
    
  END LOOP;
  counter:= 0;

  -- Đóng cursor
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
/*EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Lỗi xảy ra: ' || SQLERRM);
    -- Reset trạng thái của gói nếu có lỗi
    DBMS_SESSION.RESET_PACKAGE;*/
END;
