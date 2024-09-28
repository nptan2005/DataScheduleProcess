CREATE OR REPLACE
PACKAGE BODY VCCB_SCHEDULE_API AS

  PROCEDURE Process_Import_Log
  (
    i_Template_Name IN VARCHAR2
   ,i_File_Name     IN VARCHAR2
   ,o_File_Id       OUT NUMBER
    
  ) AS
  BEGIN
    INSERT INTO Vccb_Service_Import_Log
      (File_Id, Template_Name, File_Name, Import_Date, Is_Import)
    VALUES
      (Vccb_Schedule_Imp_Seq.Nextval, i_Template_Name, i_File_Name, SYSDATE, 0)
    RETURNING File_Id INTO o_File_Id;
    COMMIT;
  END Process_Import_Log;

  PROCEDURE Update_Import_Status_Log
  (
    i_Status  IN NUMBER
   ,i_File_Id IN NUMBER
  ) AS
  BEGIN
    UPDATE Vccb_Service_Import_Log
    SET    Is_Import   = i_Status
          ,Import_Date = SYSDATE
    WHERE  File_Id = i_File_Id;
    COMMIT;
  END Update_Import_Status_Log;
  
  PROCEDURE process_error_history
  (
    i_task            VARCHAR2
   ,i_error_msg       VARCHAR2
   ,i_note            VARCHAR2
   ,i_start           DATE DEFAULT NULL
   ,i_end             DATE DEFAULT NULL
   ,i_task_id NUMBER DEFAULT NULL
   ,i_run_time        NUMBER DEFAULT NULL
  ) IS
    l_error_msg         VARCHAR2(4000);
    l_note              VARCHAR2(4000);
    l_task              VARCHAR2(500);
    l_start             DATE;
    l_end               DATE;
    l_task_id NUMBER(20);
    l_msg               CLOB := empty_clob();
  
    l_mail_list VARCHAR2(500) := 'tannp@bvbank.net.vn';
    l_subject   VARCHAR2(500);  --VARCHAR2(250);
    l_title     VARCHAR2(500);  --VARCHAR2(250);
    
  BEGIN
    l_start     := i_start;
    l_end       := i_end;
    l_note      := i_note;
    l_note := l_note || CASE
                WHEN l_start IS NULL THEN
                 ''
                ELSE
                 '|START FROM:' || l_start
              END;
    l_note := l_note || CASE
                WHEN l_end IS NULL THEN
                 ''
                ELSE
                 '|END FROM:' || l_end
              END;
    l_error_msg := i_error_msg;
    l_task      := i_task;
    ---------------------------------
    IF i_task_id IS NULL
       AND l_task IS NOT NULL THEN
      l_task_id := get_task_id_fun(i_task_name => l_task
                                                    ,i_run_time  => i_run_time);
    ELSE
      l_task_id := i_task_id;
    END IF;
  
    INSERT INTO vccb_pro_error_history
    (task, error_msg, note, error_date, task_id)
    VALUES
      (l_task, l_error_msg, l_note, SYSDATE, l_task_id);
    COMMIT;
  
    IF l_error_msg IS NOT NULL THEN
      BEGIN
        l_msg := l_error_msg || '|' || l_note;
      
        l_subject := '[Error] (' || to_char(SYSDATE, 'DD-MON-YYYY') || ') ' || l_task;
       -- send_mail(p_to => l_mail_list, p_subject => l_subject, p_msg => l_msg, p_is_bcc => 0); 20/09/2023 
      
      EXCEPTION
        WHEN OTHERS THEN
               
          l_error_msg := SQLERRM;
          l_note      := 'SEND EMAIL ERROR';
        
          INSERT INTO vccb_pro_error_history
          VALUES
            (l_task, l_error_msg, l_note, SYSDATE, l_task_id);
          COMMIT;
        
      END;
    END IF;
  
  END process_error_history;
  
  FUNCTION get_task_id_fun
  (
    i_task_name VARCHAR2
   ,i_run_time  NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    l_task_id NUMBER(20) := -1;
  BEGIN
    IF i_task_name IS NULL THEN
      RETURN l_task_id;
    END IF;
    SELECT ID
    INTO   l_task_id
    FROM   (SELECT ID
                  ,row_number() over(PARTITION BY id ORDER BY rec_updated_date DESC) seq
            FROM   VCCB_SCHEDULE_JOB
            WHERE  active = 1
                   AND to_char(start_date, 'YYYYMMDD') <= to_char(SYSDATE, 'YYYYMMDD')
                   AND to_char(end_date, 'YYYYMMDD') >= to_char(SYSDATE, 'YYYYMMDD')
                   AND (i_run_time IS NULL OR run_time = i_run_time)
                   AND upper(task_name) = upper(i_task_name)
            )
    WHERE  seq = 1;
  
    RETURN nvl(l_task_id, -1);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_task_id_fun;

  FUNCTION get_task_name_fun
  (
    i_task_id NUMBER
   ,i_run_time        NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
    l_task_name VARCHAR2(250) := '';
  BEGIN
    IF nvl(i_task_id, -1) = -1 THEN
      RETURN l_task_name;
    END IF;
    SELECT TASK_NAME
    INTO   l_task_name
    FROM   VCCB_SCHEDULE_JOB
    WHERE  ID = i_task_id
           AND active = 1
           AND to_char(start_date, 'YYYYMMDD') <= to_char(SYSDATE, 'YYYYMMDD')
           AND to_char(end_date, 'YYYYMMDD') >= to_char(SYSDATE, 'YYYYMMDD')
           AND (i_run_time IS NULL OR run_time = i_run_time);
  
    RETURN nvl(l_task_name, '');
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_task_name_fun;
  PROCEDURE schedule_history
  (
    i_task_id NUMBER DEFAULT NULL
   ,i_task_name       VARCHAR2 DEFAULT NULL
   ,i_sub_task_name   VARCHAR2 DEFAULT NULL
   ,i_start_date      DATE
   ,i_end_date        DATE DEFAULT NULL
   ,i_note            VARCHAR2 DEFAULT NULL
   ,i_is_completed    NUMBER DEFAULT 0
   ,i_run_time        NUMBER DEFAULT NULL
  ) IS
    l_end_date          DATE;
    l_task_id NUMBER(20);
    l_task_name         VARCHAR2(250);
  BEGIN
    l_end_date := CASE
                    WHEN i_end_date IS NULL THEN
                     SYSDATE
                    ELSE
                     i_end_date
                  END;
  
    IF i_task_id IS NULL
       AND i_task_name IS NOT NULL THEN
      l_task_id := get_task_id_fun(i_task_name, i_run_time);
    ELSE
      l_task_id := i_task_id;
    END IF;
  
    IF i_task_name IS NULL
       AND nvl(i_task_id, -1) <> -1 THEN
      l_task_name := get_task_name_fun(i_task_id => i_task_id
                                              ,i_run_time        => i_run_time);
    ELSE
      l_task_name := i_task_name;
    END IF;
  
    insert INTO VCCB_SCHEDULE_JOB_HIS(ID, TASK_NAME, SUB_TASK_NAME, start_date, end_date, note, is_completed, log_date)
    VALUES
      (l_task_id
      ,l_task_name
      ,i_sub_task_name
      ,i_start_date
      ,l_end_date
      ,i_note
      ,i_is_completed
      ,sysdate);
    COMMIT;
  
  END schedule_history;
FUNCTION Schedule_Frequency_Fnc(i_Frequency IN VARCHAR2) RETURN VARCHAR2 AS
  l_Frequency VARCHAR2(50);
BEGIN
  l_Frequency := CASE
                   WHEN i_Frequency IS NULL THEN
                    'DAILY'
                   WHEN i_Frequency NOT IN ('DAILY', 'WEEKLY', 'MONTHLY') THEN
                    'DAILY'
                   ELSE
                    i_Frequency
                 END;
  RETURN l_Frequency;
END Schedule_Frequency_Fnc;
FUNCTION Schedule_Day_Of_Week_Fnc
(
  i_Frequency   IN VARCHAR2
 ,i_Day_Of_Week IN NUMBER
) RETURN NUMBER AS
  l_Day_Of_Week NUMBER(2);
BEGIN
  l_Day_Of_Week := CASE
                     WHEN Nvl(i_Frequency, '') <> 'WEEKLY' THEN
                      0
                     WHEN i_Day_Of_Week > 7 THEN 7 -- thu 7
                     WHEN i_Day_Of_Week < 1 THEN 1 -- chu nhat
                     ELSE
                      i_Day_Of_Week
                   END;
  RETURN l_Day_Of_Week;
END Schedule_Day_Of_Week_Fnc;
FUNCTION Schedule_Day_Of_Month_Fnc
(
  i_Frequency    IN VARCHAR2
 ,i_Day_Of_Month IN NUMBER
) RETURN NUMBER AS
  l_Day_Of_Month NUMBER(2);
BEGIN
  l_Day_Of_Month := CASE
                      WHEN Nvl(i_Frequency, '') <> 'MONTHLY' THEN
                       0
                      WHEN i_Day_Of_Month < 1 THEN 1
                      WHEN i_Day_Of_Month > 31 THEN 31
                      ELSE
                       i_Day_Of_Month
                    END;
  RETURN l_Day_Of_Month;
END Schedule_Day_Of_Month_Fnc;
PROCEDURE Insert_Schedule_Job_prc
(
  i_task_Order          IN NUMBER
 ,i_task_Type           IN VARCHAR2
 ,i_task_Name           IN VARCHAR2
 ,i_Run_Time           IN NUMBER
 ,i_Process_Num        IN NUMBER
 ,i_Frequency          IN VARCHAR2
 ,i_Start_Date         IN DATE
 ,i_End_Date           IN DATE
 ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
 ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
 ,i_Config_Key_Name    IN VARCHAR2 DEFAULT NULL
 ,i_Script             IN VARCHAR2 DEFAULT NULL
 ,i_Connection_String  IN VARCHAR2 DEFAULT NULL
 ,i_Output_Name        IN VARCHAR2 DEFAULT NULL
 ,i_src_Folder_Name        IN VARCHAR2 DEFAULT NULL
 ,i_src_File_Name          IN VARCHAR2 DEFAULT NULL
 ,i_src_File_Type          IN VARCHAR2 DEFAULT NULL
 ,i_dst_Folder_Name        IN VARCHAR2 DEFAULT NULL
 ,i_dst_File_Name          IN VARCHAR2 DEFAULT NULL
 ,i_dst_File_Type          IN VARCHAR2 DEFAULT NULL
 ,i_Is_Header          IN NUMBER DEFAULT 0
 ,i_Is_Notification    IN NUMBER DEFAULT 0
 ,i_is_attachment IN NUMBER DEFAULT 0
 ,i_Email IN VARCHAR2 DEFAULT NULL
 ,i_Active             IN NUMBER DEFAULT 1
 ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
 ,i_Request_Date       IN DATE DEFAULT SYSDATE
 ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
 ,i_Process_Date       IN DATE DEFAULT SYSDATE
) is
BEGIN
  INSERT INTO Vccb_Schedule_Job
    (Id
    ,Task_Order
    ,Task_Type
    ,Task_Name
    ,Run_Time
    ,Process_Num
    ,Frequency
    ,Day_Of_Week
    ,Day_Of_Month
    ,Config_Key_Name
    ,Script
    ,Connection_String
    ,Output_Name
    ,src_Folder_Name
    ,src_File_Name
    ,src_File_Type
    ,dst_Folder_Name
    ,dst_File_Name
    ,dst_File_Type
    ,Is_Header
    ,Is_Notification
    ,is_attachment
    ,Email
    ,Start_Date
    ,End_Date
    ,Active
    ,Request_User
    ,Request_Date
    ,Process_User
    ,Process_Date
    ,Rec_Created_Date
    ,Rec_Updated_Date)
  VALUES
    (Vccb_Schedule_Id_Seq.Nextval
    ,i_task_Order
    ,i_task_Type
    ,i_task_Name
    ,i_Run_Time
    ,i_Process_Num
    ,i_Frequency
    ,i_Day_Of_Week
    ,i_Day_Of_Month
    ,i_Config_Key_Name
    ,i_Script
    ,i_Connection_String
    ,i_Output_Name
    ,i_src_Folder_Name
    ,i_src_File_Name
    ,i_src_File_Type
    ,i_dst_Folder_Name
    ,i_dst_File_Name
    ,i_dst_File_Type
    ,i_Is_Header
    ,i_Is_Notification
    ,i_is_attachment
    ,i_Email
    ,i_Start_Date
    ,i_End_Date
    ,i_Active
    ,i_Request_User
    ,i_Request_Date
    ,i_Process_User
    ,i_Process_Date
    ,SYSDATE
    ,SYSDATE);
  COMMIT;

END Insert_Schedule_Job_prc;

PROCEDURE Insert_Task_Execute_Prc
  (
    i_task_Order          IN NUMBER
   ,i_task_Name           IN VARCHAR2
   ,i_Script             IN VARCHAR2
   ,i_Run_Time           IN NUMBER
   ,i_Process_Num        IN NUMBER
   ,i_Frequency          IN VARCHAR2
   ,i_Start_Date         IN DATE
   ,i_End_Date           IN DATE
   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
   ,i_Connection_String  IN VARCHAR2 DEFAULT NULL
   ,i_Is_Notification    IN NUMBER DEFAULT 0
   ,i_is_attachment    IN NUMBER DEFAULT 0
   ,i_Email IN VARCHAR2 DEFAULT NULL
   ,i_Active             IN NUMBER DEFAULT 1
   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
   ,i_Request_Date       IN DATE DEFAULT SYSDATE
   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
   ,i_Process_Date       IN DATE DEFAULT SYSDATE
  )is
  l_task_Type varchar2(15):= 'EXECUTE_PROCEDURE';
  l_Frequency VARCHAR2(50);
  begin
    l_Frequency := Schedule_Frequency_Fnc(i_Frequency => i_Frequency);
    Insert_Schedule_Job_prc
      (
        i_task_Order          => i_task_Order
       ,i_task_Type           => l_task_Type
       ,i_task_Name           => i_task_Name
       ,i_Run_Time           => i_Run_Time
       ,i_Process_Num        => i_Process_Num
       ,i_Frequency          => l_Frequency
       ,i_Start_Date         => i_Start_Date
       ,i_End_Date           => i_End_Date
       ,i_Day_Of_Week        => Schedule_Day_Of_Week_Fnc(i_Frequency => l_Frequency, i_Day_Of_Week => i_Day_Of_Week)
       ,i_Day_Of_Month       => Schedule_Day_Of_Month_Fnc(i_Frequency => l_Frequency, i_Day_Of_Month => i_Day_Of_Month)
       ,i_Config_Key_Name    => NULL
       ,i_Script             => i_Script
       ,i_Connection_String  => i_Connection_String
       ,i_Output_Name        => NULL
       ,i_src_Folder_Name        => NULL
       ,i_src_File_Name          => NULL
       ,i_src_File_Type          => NULL
       ,i_dst_Folder_Name        => NULL
       ,i_dst_File_Name          => NULL
       ,i_dst_File_Type          => NULL
       ,i_Is_Header          => NULL
       ,i_Is_Notification    => i_Is_Notification
       ,i_is_attachment => i_is_attachment
       ,i_Email => i_Email
       ,i_Active             => i_Active
       ,i_Request_User       => i_Request_User
       ,i_Request_Date       => i_Request_Date
       ,i_Process_User       => i_Process_User
       ,i_Process_Date       => i_Process_Date
      );
  end Insert_Task_Execute_Prc;
  
  
  PROCEDURE Insert_Task_Python_Prc
  (
    i_task_Order          IN NUMBER
   ,i_task_Name           IN VARCHAR2
   ,i_Script             IN VARCHAR2
   ,i_Run_Time           IN NUMBER
   ,i_Process_Num        IN NUMBER
   ,i_Frequency          IN VARCHAR2
   ,i_Start_Date         IN DATE
   ,i_End_Date           IN DATE
   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
   ,i_Connection_String  IN VARCHAR2 DEFAULT NULL
   ,i_Is_Notification    IN NUMBER DEFAULT 0
   ,i_Email IN VARCHAR2 DEFAULT NULL
   ,i_Active             IN NUMBER DEFAULT 1
   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
   ,i_Request_Date       IN DATE DEFAULT SYSDATE
   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
   ,i_Process_Date       IN DATE DEFAULT SYSDATE
  )is
  l_task_Type varchar2(15):= 'EXECUTE_PYTHON';
  l_Frequency VARCHAR2(50);
  begin
    l_Frequency := Schedule_Frequency_Fnc(i_Frequency => i_Frequency);
    Insert_Schedule_Job_prc
      (
        i_task_Order          => i_task_Order
       ,i_task_Type           => l_task_Type
       ,i_task_Name           => i_task_Name
       ,i_Run_Time           => i_Run_Time
       ,i_Process_Num        => i_Process_Num
       ,i_Frequency          => l_Frequency
       ,i_Start_Date         => i_Start_Date
       ,i_End_Date           => i_End_Date
       ,i_Day_Of_Week        => Schedule_Day_Of_Week_Fnc(i_Frequency => l_Frequency, i_Day_Of_Week => i_Day_Of_Week)
       ,i_Day_Of_Month       => Schedule_Day_Of_Month_Fnc(i_Frequency => l_Frequency, i_Day_Of_Month => i_Day_Of_Month)
       ,i_Config_Key_Name    => NULL
       ,i_Script             => i_Script
       ,i_Connection_String  => i_Connection_String
       ,i_Output_Name        => NULL
       ,i_src_Folder_Name        => NULL
       ,i_src_File_Name          => NULL
       ,i_src_File_Type          => NULL
       ,i_dst_Folder_Name        => NULL
       ,i_dst_File_Name          => NULL
       ,i_dst_File_Type          => NULL
       ,i_Is_Header          => NULL
       ,i_Is_Notification    => i_Is_Notification
       ,i_is_attachment => 0
       ,i_Email => i_Email
       ,i_Active             => i_Active
       ,i_Request_User       => i_Request_User
       ,i_Request_Date       => i_Request_Date
       ,i_Process_User       => i_Process_User
       ,i_Process_Date       => i_Process_Date
      );
  end Insert_Task_Python_Prc;
  
  PROCEDURE Insert_Task_Export_prc
  (
   i_task_Order          IN NUMBER
   ,i_task_Name           IN VARCHAR2
   ,i_Run_Time           IN NUMBER
   ,i_Process_Num        IN NUMBER
   ,i_Frequency          IN VARCHAR2
   ,i_Start_Date         IN DATE
   ,i_End_Date           IN DATE
   ,i_Script             IN VARCHAR2
   ,i_Output_Name        IN VARCHAR2
   ,i_Folder_Name        IN VARCHAR2
   ,i_File_Name          IN VARCHAR2
   ,i_File_Type          IN VARCHAR2 DEFAULT 'xlsx'
   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
   ,i_Connection_String  IN VARCHAR2 DEFAULT NULL
   ,i_Is_Header          IN NUMBER DEFAULT 1
   ,i_Is_Notification    IN NUMBER DEFAULT 0
   ,i_is_attachment IN NUMBER DEFAULT 0
   ,i_Email IN VARCHAR2 DEFAULT NULL
   ,i_Active             IN NUMBER DEFAULT 1
   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
   ,i_Request_Date       IN DATE DEFAULT SYSDATE
   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
   ,i_Process_Date       IN DATE DEFAULT SYSDATE
  )is
  l_task_Type varchar2(15):= 'EXPORT';
  l_Frequency VARCHAR2(50);
  l_script            VARCHAR2(4000);
  begin
    l_Frequency := Schedule_Frequency_Fnc(i_Frequency => i_Frequency);
    l_script:= CASE WHEN INSTR(UPPER(i_Script), 'SELECT') <= 0 THEN 'SELECT * FROM ' || i_Script || ';'
                    ELSE i_Script END;
                    
    Insert_Schedule_Job_prc
      (
        i_task_Order          => i_task_Order
       ,i_task_Type           => l_task_Type
       ,i_task_Name           => i_task_Name
       ,i_Run_Time           => i_Run_Time
       ,i_Process_Num        => i_Process_Num
       ,i_Frequency          => l_Frequency
       ,i_Start_Date         => i_Start_Date
       ,i_End_Date           => i_End_Date
       ,i_Day_Of_Week        => Schedule_Day_Of_Week_Fnc(i_Frequency => l_Frequency, i_Day_Of_Week => i_Day_Of_Week)
       ,i_Day_Of_Month       => Schedule_Day_Of_Month_Fnc(i_Frequency => l_Frequency, i_Day_Of_Month => i_Day_Of_Month)
       ,i_Config_Key_Name    => NULL
       ,i_Script             => l_script
       ,i_Connection_String  => i_Connection_String
       ,i_Output_Name        => NULL
       ,i_src_Folder_Name        => NULL
       ,i_src_File_Name          => NULL
       ,i_src_File_Type          => NULL
       ,i_dst_Folder_Name        => i_Folder_Name
       ,i_dst_File_Name          => i_File_Name
       ,i_dst_File_Type          => i_File_Type
       ,i_Is_Header          => NULL
       ,i_Is_Notification    => i_Is_Notification
       ,i_is_attachment => i_is_attachment
       ,i_Email => i_Email
       ,i_Active             => i_Active
       ,i_Request_User       => i_Request_User
       ,i_Request_Date       => i_Request_Date
       ,i_Process_User       => i_Process_User
       ,i_Process_Date       => i_Process_Date
      );
    
  end Insert_Task_Export_prc;
  
  
  PROCEDURE Insert_Task_Import_prc
  (
    i_task_Order          IN NUMBER
   ,i_task_Name           IN VARCHAR2
   ,i_Run_Time           IN NUMBER
   ,i_Process_Num        IN NUMBER
   ,i_Frequency          IN VARCHAR2
   ,i_Start_Date         IN DATE
   ,i_End_Date           IN DATE
   ,i_Config_Key_Name    IN VARCHAR2
   ,i_Folder_Name        IN VARCHAR2
   ,i_File_Name          IN VARCHAR2
   ,i_File_Type          IN VARCHAR2 DEFAULT 'xlsx'
   ,i_Day_Of_Week        IN NUMBER DEFAULT NULL
   ,i_Day_Of_Month       IN NUMBER DEFAULT NULL
   ,i_Connection_String  IN VARCHAR2 DEFAULT NULL
   ,i_Is_Header          IN NUMBER DEFAULT 1
   ,i_Is_Notification    IN NUMBER DEFAULT 0
   ,i_Email IN VARCHAR2 DEFAULT NULL
   ,i_Active             IN NUMBER DEFAULT 1
   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
   ,i_Request_Date       IN DATE DEFAULT SYSDATE
   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
   ,i_Process_Date       IN DATE DEFAULT SYSDATE
  )IS 
  l_task_Type varchar2(15):= 'IMPORT';
  l_Frequency VARCHAR2(50);
  BEGIN
    l_Frequency := Schedule_Frequency_Fnc(i_Frequency => i_Frequency);
    Insert_Schedule_Job_prc
      (
        i_task_Order          => i_task_Order
       ,i_task_Type           => l_task_Type
       ,i_task_Name           => i_task_Name
       ,i_Run_Time           => i_Run_Time
       ,i_Process_Num        => i_Process_Num
       ,i_Frequency          => l_Frequency
       ,i_Start_Date         => i_Start_Date
       ,i_End_Date           => i_End_Date
       ,i_Day_Of_Week        => Schedule_Day_Of_Week_Fnc(i_Frequency => l_Frequency, i_Day_Of_Week => i_Day_Of_Week)
       ,i_Day_Of_Month       => Schedule_Day_Of_Month_Fnc(i_Frequency => l_Frequency, i_Day_Of_Month => i_Day_Of_Month)
       ,i_Config_Key_Name    => i_Config_Key_Name
       ,i_Script             => NULL
       ,i_Connection_String  => i_Connection_String
       ,i_Output_Name        => NULL
       ,i_src_Folder_Name        => i_Folder_Name
       ,i_src_File_Name          => i_File_Name
       ,i_src_File_Type          => i_File_Type
       ,i_dst_Folder_Name        => NULL
       ,i_dst_File_Name          => NUll
       ,i_dst_File_Type          => NULL
       ,i_Is_Header          => NULL
       ,i_Is_Notification    => i_Is_Notification
       ,i_is_attachment => 0
       ,i_Email => i_Email
       ,i_Active             => i_Active
       ,i_Request_User       => i_Request_User
       ,i_Request_Date       => i_Request_Date
       ,i_Process_User       => i_Process_User
       ,i_Process_Date       => i_Process_Date
      );
  END Insert_Task_Import_prc;

END VCCB_SCHEDULE_API;