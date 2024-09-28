create or replace NONEDITIONABLE PACKAGE VCCB_SCHEDULE_API AS 

 -- Author  : TANNP
  -- Created : 16/07/2024 16:31:23
  -- Purpose : execute, get data purpose process schedule job
  
  PROCEDURE process_import_log(
     i_template_name in varchar2
    ,i_file_name in varchar2
    ,o_file_id out number
    
  );
  
  PROCEDURE update_import_status_log(i_status in number, i_file_id in number);
  PROCEDURE process_error_history
  (
    i_task            VARCHAR2
   ,i_error_msg       VARCHAR2
   ,i_note            VARCHAR2
   ,i_start           DATE DEFAULT NULL
   ,i_end             DATE DEFAULT NULL
   ,i_task_id NUMBER DEFAULT NULL
   ,i_run_time        NUMBER DEFAULT NULL
  );
  FUNCTION get_task_id_fun
  (
    i_task_name VARCHAR2
   ,i_run_time  NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION get_task_name_fun
  (
    i_task_id NUMBER
   ,i_run_time        NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;
  
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
  );
  FUNCTION schedule_frequency_fnc(i_Frequency          IN VARCHAR2) return varchar2;
  FUNCTION schedule_day_of_week_fnc(i_Frequency IN VARCHAR2,i_Day_Of_Week        IN NUMBER )return number;
  FUNCTION schedule_day_of_month_fnc(i_Frequency IN VARCHAR2,i_Day_Of_Month        IN NUMBER )return number;
  PROCEDURE Insert_Schedule_Job_prc
  (
    i_Task_Order          IN NUMBER
   ,i_Task_Type           IN VARCHAR2
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
   ,i_is_attachment      IN NUMBER DEFAULT 0
   ,i_Email              IN VARCHAR2 DEFAULT NULL
   ,i_Active             IN NUMBER DEFAULT 1
   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
   ,i_Request_Date       IN DATE DEFAULT SYSDATE
   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
   ,i_Process_Date       IN DATE DEFAULT SYSDATE
  );
  
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
   ,i_Email IN VARCHAR2 DEFAULT NULL
   ,i_Active             IN NUMBER DEFAULT 1
   ,i_Request_User       IN VARCHAR2 DEFAULT 'unitUser'
   ,i_Request_Date       IN DATE DEFAULT SYSDATE
   ,i_Process_User       IN VARCHAR2 DEFAULT 'sysUser'
   ,i_Process_Date       IN DATE DEFAULT SYSDATE
  );
  
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
  );
  
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
   ,i_src_Folder_Name        IN VARCHAR2 DEFAULT NULL
   ,i_src_File_Name          IN VARCHAR2 DEFAULT NULL
   ,i_src_File_Type          IN VARCHAR2 DEFAULT NULL
   ,i_dst_Folder_Name        IN VARCHAR2 DEFAULT NULL
   ,i_dst_File_Name          IN VARCHAR2 DEFAULT NULL
   ,i_dst_File_Type          IN VARCHAR2 DEFAULT NULL
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
  );
  
  
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
   ,i_src_Folder_Name        IN VARCHAR2 DEFAULT NULL
   ,i_src_File_Name          IN VARCHAR2 DEFAULT NULL
   ,i_src_File_Type          IN VARCHAR2 DEFAULT NULL
   ,i_dst_Folder_Name        IN VARCHAR2 DEFAULT NULL
   ,i_dst_File_Name          IN VARCHAR2 DEFAULT NULL
   ,i_dst_File_Type          IN VARCHAR2 DEFAULT NULL
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
  );


END VCCB_SCHEDULE_API;