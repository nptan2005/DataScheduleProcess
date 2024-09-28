                    SELECT Id AS Job_Id
                            ,Job_Type
                            ,Job_Name
                            ,Task
                            ,Config_Key_Name
                            ,CASE
                                WHEN Nvl(Process_Num, 1) > 3 THEN
                                3
                                WHEN Nvl(Process_Num, 1) < 1 THEN
                                1
                                ELSE
                                Nvl(Process_Num, 1)
                            END AS Process_Num
                            ,Frequency
                            ,CASE
                                WHEN To_Number(To_Char(Nvl(Day_Of_Week, 1))) < 1 THEN
                                1
                                WHEN To_Number(To_Char(Nvl(Day_Of_Week, 1))) > 7 THEN
                                7
                                ELSE
                                Nvl(Day_Of_Week, 1)
                            END AS Day_Of_Week
                            ,Nvl(Day_Of_Month, 1) AS Day_Of_Month
                            ,CASE
                                WHEN Task = 'EXPORT' THEN
                                'True'
                                ELSE
                                'False'
                            END AS Is_Export
                            ,CASE
                                WHEN Task = 'IMPORT' THEN
                                'True'
                                ELSE
                                'False'
                            END AS Is_Import
                            ,To_Char(Nvl(Is_Header, 1)) AS Is_Header
                            ,Script
                            ,Connection_String
                            ,Output_Name_Arr
                            ,Folder_Name
                            ,File_Name
                            ,Lower(File_Type) AS File_Type
                            ,Nvl(Is_Notification, 0) AS Is_Notification
                            ,Notification_Email
                            ,Run_Time
                            ,Start_Date
                            ,End_Date
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
                            AND Run_Time = 1420
                            AND ('5' = '-1' OR ID = 5)
                        ORDER  BY Job_Order;
                        
                        select ACCT_NUMBER, CLIENT_NUMBER, SERVICE_CONTRACT_ID, BILLING_CYCLE from DW_CAS_CLIENT_ACCOUNT t WHERE rownum < 100
                          inner join DW_CAS_CLIENT_LIMITS t2
                          on t.limit_number = t2.limit_number
                          WHERE rownum < 1000 and ACCT_CURRENCY = 704 and ACCT_NUMBER_RBS is not null;
