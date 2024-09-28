                     SELECT Id AS "task_id"
                            , task_order as "task_order"
                            ,task_type as "task_type"
                            ,task_name as "task_name"
                            ,run_time as "run_time"
                            ,config_key_name as "config_key_name"
                            ,CASE
                                WHEN Nvl(process_num, 1) > 3 THEN
                                3
                                WHEN Nvl(process_num, 1) < 1 THEN
                                1
                                ELSE
                                Nvl(process_num, 1)
                            END AS "process_num" 
                            ,Frequency as "frequency"
                            ,CASE
                                WHEN To_Number(To_Char(Nvl(Day_Of_Week, 1))) < 1 THEN
                                1
                                WHEN To_Number(To_Char(Nvl(Day_Of_Week, 1))) > 7 THEN
                                7
                                ELSE
                                Nvl(Day_Of_Week, 1)
                            END AS "day_of_week"
                            ,Nvl(Day_Of_Month, 1) AS "day_of_month"
                            
                            ,Script as "script"
                            ,connection_string as "connection_string"
                            ,output_name as "output_name"
                            ,src_folder_name as "src_folder_name"
                            ,src_file_name as "src_file_name"
                            ,lower(src_file_type) as "src_file_type"
                            ,dst_folder_name as "dst_folder_name"
                            ,dst_file_name as "dst_file_name"
                            ,Lower(dst_file_type) AS "dst_file_type"
                            ,Nvl(Is_Header, 1) AS "is_header"
                            ,Nvl(Is_Notification, 0) AS "is_notification"
                            ,nvl(is_attachment,0) as "is_attachment"
                            ,email as "email"
                            ,start_date as "start_date"
                            ,End_Date as "end_date"
                        FROM   Vccb_Schedule_Job
                        WHERE  Nvl(Active, 0) = 1
                            AND To_Char(Start_Date, 'YYYYMMDD') <= To_Char(SYSDATE, 'YYYYMMDD')
                            AND To_Char(End_Date, 'YYYYMMDD') >= To_Char(SYSDATE, 'YYYYMMDD')
                            AND (Frequency = 'DAILY' OR
                                    (Frequency = 'WEEKLY' AND Day_Of_Week = To_Number(To_Char(SYSDATE, 'D'))) OR
                                    (Frequency = 'MONTHLY' AND (CASE
                                                                    WHEN To_Number(To_Char(Nvl(Day_Of_Month, 1))) < 1 THEN
                                                                    1
                                                                    WHEN to_char(sysdate,'MM') = '02' AND  Nvl(Day_Of_Month, 1) > 28 AND Nvl(Day_Of_Month, 1) <> To_Number(To_Char(Last_Day(SYSDATE), 'DD')) THEN To_Number(To_Char(Last_Day(SYSDATE), 'DD'))
                                                                    WHEN Nvl(Day_Of_Month, 1) > 31 THEN to_number(To_Char(Last_Day(SYSDATE), 'DD'))
                                                                    ELSE
                                                                    Nvl(Day_Of_Month, 1)
                                                                END) = To_Number(To_Char(SYSDATE, 'DD'))))
                            AND Run_Time = :Run_Time
                            AND (to_char(:task_id) = '-1' OR ID = :task_id)
                        ORDER  BY task_order