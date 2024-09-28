-- ADD Execute Procedure
BEGIN
  bvbpks_schedule_api.Insert_Task_Execute_Prc(i_task_Order        => 6
                                           ,i_task_Name         => N'EXECUTE PROCESS AUTO CREDIT TO FC'
                                           ,i_Script            => 'Vccb_Acq_Pos_Api.pr_acq_auto_credit'
                                           ,i_Run_Time          => 1300
                                           ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 1: tuong duong thread thu nhat
                                           ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                           ,i_Start_Date        => to_date('20240910', 'YYYYMMDD')
                                           ,i_End_Date          => to_date('20240910', 'YYYYMMDD')
                                           ,i_Day_Of_Week       => 0 -- DAILY = 0 ; WEEKLY: 1: Sunday; 2: Monday; 3: Tuesday; 4: wednesday; 5: Thursday; 6: ; 7: saturday
                                           ,i_Day_Of_Month      => 0 -- DAILY = 0; set last of month: alway set 31
                                           ,i_Connection_String => 'CARD_DW' -- config name on config file; if NULL get default
                                           ,i_Is_Notification   => 0 -- value 0/1: 1: email auto send after finished
                                           ,i_Email             => 'tannp@bvbank.net.vn'
                                            /*   ,i_Active             => 1
                                               ,i_Request_User       => 'unitUser' 
                                               ,i_Request_Date       => SYSDATE
                                               ,i_Process_User       => 'sysUser'
                                               ,i_Process_Date       => SYSDATE*/);
END;

SELECT * FROM Vccb_Schedule_Job WHERE ID = 1;

-- ADD Export Task
BEGIN
  bvbpks_schedule_api.Insert_Task_Export_prc(i_task_Order        => 8
                                          ,i_task_Name         => 'ACCOUNTING STATUS TO ATOM'
                                          ,i_Run_Time          => 1400
                                          ,i_Process_Num       => 2 -- toi da cung luc chay 3 thread; 1: tuong duong thread thu hai
                                          ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                          ,i_Start_Date        => to_date('20240910', 'YYYYMMDD')
                                          ,i_End_Date          => to_date('20240910', 'YYYYMMDD')
                                          ,i_Script            => 'select * from VCCB_ACQ_ACCOUNTING_STATUS_VV'
                                          ,i_Output_Name       => 'STATUS'
                                          ,i_Folder_Name       => 'ACQ_POS'
                                          ,i_File_Name         => 'ACCOUNTING_STATUS'
                                          ,i_File_Type         => 'xlsx' -- DEFAULT: xlsx
                                          ,i_Day_Of_Week       => 0 -- DAILY = 0 ; WEEKLY: 1: Sunday; 2: Monday; 3: Tuesday; 4: wednesday; 5: Thursday; 6: ; 7: saturday
                                          ,i_Day_Of_Month      => 0 -- DAILY = 0; set last of month: alway set 31
                                          ,i_Connection_String => 'CARD_DW' -- config name on config file; if NULL get default
                                           --,i_Is_Header          IN NUMBER DEFAULT 1
                                          ,i_Is_Notification => 1
                                          ,i_Email           => 'tannp@bvbank.net.vn'
                                           /*,i_Active             IN NUMBER DEFAULT 1
                                              ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                              ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                              ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                              ,i_Process_Date       IN DATE DEFAULT SYSDATE*/);
END;

-- ADD IMPORT FILE
BEGIN
  bvbpks_schedule_api.Insert_Task_Import_prc(i_task_Order        => 4
                                          ,i_task_Name         => 'IMPORT ATOM-SETTLEMENT TXN'
                                          ,i_Run_Time          => 1500
                                          ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 3: tuong duong thread thu ba
                                          ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                          ,i_Start_Date        => to_date('20240910', 'YYYYMMDD')
                                          ,i_End_Date          => to_date('20240910', 'YYYYMMDD')
                                          ,i_Config_Key_Name   => 'ATOM_POS_SET_TXN' -- tuong config key xac dinh format file can doc: Templates\importDataTemplate\import_template_example.json
                                          ,i_Folder_Name       => 'ACQ_POS' -- folder chua file ; note: root folder can dc config tren file config: configurable\reportconfig.conf
                                          ,i_File_Name         => 'ATOM_SETTLEMENT_TXN_[YYYYMMDDHHMMSS]' -- _[YYYYMMDD] la dau hieu config: chuong trinh se hieu doc file co suffix _20240725 (ngay hien tai)
                                          ,i_File_Type         => 'xlsx'
                                          ,i_Day_Of_Week       => 0 -- DAILY = 0 ; WEEKLY: 1: Sunday; 2: Monday; 3: Tuesday; 4: wednesday; 5: Thursday; 6: ; 7: saturday
                                          ,i_Day_Of_Month      => 0 -- DAILY = 0; set last of month: alway set 31
                                          ,i_Connection_String => 'CARD_DW' -- config name on config file; if NULL get default
                                           /*   ,i_Is_Header          IN NUMBER DEFAULT 1
                                              ,i_Is_Notification    IN NUMBER DEFAULT 0
                                              ,i_Notification_Email IN VARCHAR2 DEFAULT NULL
                                              ,i_Active             IN NUMBER DEFAULT 1
                                              ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                              ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                              ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                              ,i_Process_Date       IN DATE DEFAULT SYSDATE*/);
END;

BEGIN
  bvbpks_schedule_api.Insert_Task_sftp_Import_prc(i_task_Order        => 2
                                               ,i_task_Name         => 'IMPORT ATOM-SETTLEMENT TXN'
                                               ,i_Run_Time          => 1615
                                               ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 3: tuong duong thread thu ba
                                               ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                               ,i_Start_Date        => to_date('20240917'
                                                                              ,'YYYYMMDD')
                                               ,i_End_Date          => to_date('20500910'
                                                                              ,'YYYYMMDD')
                                               ,i_Config_Key_Name   => 'ACQ_BANK_BENEFIT' -- tuong config key xac dinh format file can doc: Templates\importDataTemplate\import_template_example.json
                                               ,i_src_Folder_Name   => '/ke_toan_the/in' -- folder chua file ; note: root folder can dc config tren file config: configurable\reportconfig.conf
                                               ,i_src_File_Name     => 'ATOM_SETTLEMENT_TXN_[YYYYMMDD]' -- _[YYYYMMDD] la dau hieu config: chuong trinh se hieu doc file co suffix _20240725 (ngay hien tai)
                                               ,i_src_File_Type     => 'xlsx'
                                               ,i_dst_Folder_Name   => 'ACQ_POS'
                                               ,i_dst_File_Name     => 'ATOM_SETTLEMENT_TXN_[YYYYMMDDHHMMSS]'
                                               ,i_dst_File_Type     => 'xlsx'
                                               ,i_Day_Of_Week       => 0 -- DAILY = 0 ; WEEKLY: 1: Sunday; 2: Monday; 3: Tuesday; 4: wednesday; 5: Thursday; 6: ; 7: saturday
                                               ,i_Day_Of_Month      => 0 -- DAILY = 0; set last of month: alway set 31
                                               ,i_Connection_String => 'DW' -- config name on config file; if NULL get default
                                               ,i_Email             => 'tannp@bvbank.net.vn'
                                                /*   ,i_Is_Header          IN NUMBER DEFAULT 1
                                                   ,i_Is_Notification    IN NUMBER DEFAULT 0
                                                   ,i_Notification_Email IN VARCHAR2 DEFAULT NULL
                                                   ,i_Active             IN NUMBER DEFAULT 1
                                                   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                                   ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                                   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                                   ,i_Process_Date       IN DATE DEFAULT SYSDATE*/);
END;

BEGIN
  bvbpks_schedule_api.Insert_Task_sftp_export_prc(i_task_Order        => 6
                                               ,i_task_Name         => 'ACCOUNTING STATUS TO ATOM'
                                               ,i_Run_Time          => 1615
                                               ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 3: tuong duong thread thu ba
                                               ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                               ,i_Start_Date        => to_date('20240917'
                                                                              ,'YYYYMMDD')
                                               ,i_End_Date          => to_date('20500910'
                                                                              ,'YYYYMMDD')
                                               ,i_Config_Key_Name   => 'ATOM_UPDATE_ACCOUNT_STATUS' -- tuong config key xac dinh format file can doc: Templates\importDataTemplate\import_template_example.json
                                               ,i_src_Folder_Name   => 'ACQ_POS' -- folder chua file ; note: root folder can dc config tren file config: configurable\reportconfig.conf
                                               ,i_src_File_Name     => 'ATOM_ACCOUNTING_STATUS' -- _[YYYYMMDD] la dau hieu config: chuong trinh se hieu doc file co suffix _20240725 (ngay hien tai)
                                               ,i_src_File_Type     => 'xlsx'
                                               ,i_dst_Folder_Name   => '/ke_toan_the/out'
                                               ,i_dst_File_Name     => 'ATOM_ACCOUNTING_STATUS_[YYYYMMDDHHMMSS]'
                                               ,i_dst_File_Type     => 'xlsx'
                                               ,i_Script            => 'select * from VCCB_ACQ_ACCOUNTING_STATUS_VV'
                                               ,i_Output_Name       => 'DATA'
                                               ,i_Day_Of_Week       => 0 -- DAILY = 0 ; WEEKLY: 1: Sunday; 2: Monday; 3: Tuesday; 4: wednesday; 5: Thursday; 6: ; 7: saturday
                                               ,i_Day_Of_Month      => 0 -- DAILY = 0; set last of month: alway set 31
                                               ,i_Connection_String => 'DW' -- config name on config file; if NULL get default
                                               ,i_Email             => 'tannp@bvbank.net.vn'
                                               ,i_Is_Header         => 1
                                               ,i_Is_Notification   => 1
                                               ,i_is_attachment => 1
                                                /*   
                                                   ,
                                                   ,i_Notification_Email IN VARCHAR2 DEFAULT NULL
                                                   ,i_Active             IN NUMBER DEFAULT 1
                                                   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                                   ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                                   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                                   ,i_Process_Date       IN DATE DEFAULT SYSDATE*/);
END;

-- sftp
BEGIN
  bvbpks_schedule_api.Insert_Task_sftp_prc(i_task_Order        => 9
                                        ,i_task_Name         => 'UPLOAD ACCOUNTING STATUS'
                                        ,i_task_Type         => 'SFTP_MOVE_TO_SERVER' --SFTP_DOWNLOAD/SFTP_UPLOAD/SFTP_MOVE_TO_SERVER/SFTP_MOVE_TO_LOCAL
                                        ,i_Run_Time          => 1500
                                        ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 3: tuong duong thread thu ba
                                        ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                        ,i_Start_Date        => to_date('20240910', 'YYYYMMDD')
                                        ,i_End_Date          => to_date('20540910', 'YYYYMMDD')
                                        ,i_Connection_String => 'SFTP_DEFAULT' -- config name on config file; if NULL get default
                                        ,i_src_Folder_Name   => 'ACQ_POS'
                                        ,i_src_File_Name     => 'ACCOUNTING_STATUS_[YYYYMMDDHHMMSS]'
                                        ,i_src_File_Type     => 'xlsx'
                                        ,i_dst_Folder_Name   => '/var/tmp/test'
                                        ,i_dst_File_Name     => 'ACCOUNTING_STATUS_[YYYYMMDDHHMMSS]'
                                        ,i_dst_File_Type     => 'xlsx'
                                         
                                         --   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
                                         --   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
                                         --   ,i_Config_Key_Name  IN VARCHAR2 DEFAULT NULL
                                         --   ,i_Is_Header          IN NUMBER DEFAULT 1
                                         --   ,i_Is_Notification    IN NUMBER DEFAULT 0
                                         --   ,i_Email IN VARCHAR2 DEFAULT NULL
                                         --   ,i_Active             IN NUMBER DEFAULT 1
                                         --   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                         --   ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                         --   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                         --   ,i_Process_Date       IN DATE DEFAULT SYSDATE
                                         );

END;

--EMAIL REPORT 
BEGIN
  bvbpks_schedule_api.insert_Task_email_report_prc(i_task_Order        => 5
                                                ,i_task_Name         => 'TEST EMAIL REPORT'
                                                ,i_Run_Time          => 1500
                                                ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 3: tuong duong thread thu ba
                                                ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                                ,i_Start_Date        => to_date('20240725'
                                                                               ,'YYYYMMDD')
                                                ,i_End_Date          => to_date('20240726'
                                                                               ,'YYYYMMDD')
                                                ,i_Connection_String => 'LOCAL' -- config name on config file; if NULL get default
                                                ,i_Email             => 'tannp@bvbank.net.vn'
                                                ,i_Script            => 'select sysdate from dual'
                                                 --   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
                                                 --   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
                                                 --   ,i_Active             IN NUMBER DEFAULT 1
                                                 --   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                                 --   ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                                 --   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                                 --   ,i_Process_Date       IN DATE DEFAULT SYSDATE
                                                 );
END;
-- email send attachment file
BEGIN
  bvbpks_schedule_api.Insert_Task_email_attach_prc(i_task_Order        => 5
                                                ,i_task_Name         => 'TEST EMAIL ATTACH REPORT'
                                                ,i_Run_Time          => 1500
                                                ,i_Process_Num       => 1 -- toi da cung luc chay 3 thread; 3: tuong duong thread thu ba
                                                ,i_Frequency         => 'DAILY' -- DAILY /WEEKLY/ MONTHLY
                                                ,i_Start_Date        => to_date('20240725'
                                                                               ,'YYYYMMDD')
                                                ,i_End_Date          => to_date('20240726'
                                                                               ,'YYYYMMDD')
                                                ,i_Connection_String => 'LOCAL' -- config name on config file; if NULL get default
                                                ,i_Email             => 'tannp@bvbank.net.vn'
                                                ,i_Script            => 'select sysdate from dual'
                                                ,i_Output_Name       => 'TEST'
                                                ,i_Folder_Name       => 'TEST_EXPORT'
                                                ,i_File_Name         => 'TEST'
                                                ,i_File_Type         => 'xlsx' -- DEFAULT: xlsx
                                                 --   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
                                                 --   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
                                                 --   ,i_Active             IN NUMBER DEFAULT 1
                                                 --   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
                                                 --   ,i_Request_Date       IN DATE DEFAULT SYSDATE
                                                 --   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
                                                 --   ,i_Process_Date       IN DATE DEFAULT SYSDATE
                                                 );
END;
update Vccb_Schedule_Job set SCRIPT = 'bvbpks_Acq_Pos_Api.pr_acq_accounting_fc' where id = 3;
update Vccb_Schedule_Job set SCRIPT = 'bvbpks_Acq_Pos_Api.pr_acq_auto_credit' where id = 4;
--update Vccb_Schedule_Job set PROCESS_NUM = 1 where id in(1,2)
--update Vccb_Schedule_Job set JOB_ORDER = 6 where id = 6

--update Vccb_Schedule_Job set PARENT_TASK_ID = 3 where id = 4

select * from VCCB_JOB_FREQUENCY

/*merge into VCCB_JOB_FREQUENCY d
using Vccb_Schedule_Job s
on (d.id = s.id )
when matched then update
  set d.parent_task_id = s.parent_task_id*/

SELECT *
FROM   Vccb_Schedule_Job
ORDER  BY task_order
          update Vccb_Schedule_Job set id = TASK_ORDER
          --delete Vccb_Schedule_Job where id in (10,11)
          --update Vccb_Schedule_Job set RUN_TIME = 1615
          --update Vccb_Schedule_Job set TASK_ORDER = TASK_ORDER + 1 where TASK_ORDER >= 6
         --update Vccb_Schedule_Job set PARENT_TASK_ID = 4 where id in (5,6)
         --update Vccb_Schedule_Job set PARENT_TASK_ID = NULL WHERE ID IN (5,6)
           UPDATE Vccb_Schedule_Job SET CONFIG_KEY_NAME = 'OUT_RESPONSE_CODE', TASK_TYPE = 'ACQ_AUTO_ACCOUNTING'
WHERE  id = 7 drop TABLE CARD_DW.VCCB_ATOM_POS_SETTL_TXN_TMP

 UPDATE Vccb_Schedule_Job SET DST_FILE_NAME = 'ACCOUNTING_STATUS_[YYYYMMDDHHMMSS]'
WHERE  id = 11

 UPDATE Vccb_Schedule_Job SET OUTPUT_NAME = 'HACH_TOAN;ACQ_BANK;MERCHANT'
WHERE  id = 12

  SELECT *
        FROM   VCCB_ACQ_ACCOUNTING_STATUS_VV
         
         UPDATE Vccb_Schedule_Job SET email = email || ';' || 'quyenttt@bvbank.net.vn', IS_ATTACHMENT = 1
        WHERE  id IN (5, 6)
        
         UPDATE Vccb_Schedule_Job SET email = 'tannp@bvbank.net.vn'
        WHERE  id IN (5, 6)
        
         UPDATE Vccb_Schedule_Job SET IS_ATTACHMENT = 0, email = 'tannp@bvbank.net.vn'
        WHERE  id NOT IN (8, 10)
        
         UPDATE Vccb_Schedule_Job SET CONFIG_KEY_NAME = 'ACQ_POS_ACCOUNTING_REPORT'
        WHERE  id = 8
        
         ACQ_BANK;

MERCHANT;
HACH_TOAN;
FC STATUS

  SELECT * FROM VCCB_ACQ_BANK_TOTAL_TXN_RPT_VV;
SELECT * FROM VCCB_ACQ_MER_TOTAL_TXN_RPT_VV;
SELECT * FROM VCCB_ACQ_ACCT_RPT_VV;
SELECT * FROM VCCB_ACQ_ACC_TO_FC_STT_RPT_VV


select * from VCCB_ACQ_BANK_BENEFIT_ACCT where active = 1


