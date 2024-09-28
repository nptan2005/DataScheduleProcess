                        SELECT job.Id AS "task_id"
                            ,nvl(job.parent_task_id,-1) as "parent_task_id"
                            ,nvl(group_task.task_order,job.task_order) as "task_order"
                            ,job.task_type as "task_type"
                            ,job.task_name as "task_name"
                            ,job.run_time  as "run_time"
                            ,job.config_key_name as "config_key_name"
                            ,CASE
                                WHEN group_task.process_num is not null then group_task.process_num
                                WHEN Nvl(job.process_num, 1) > 3 THEN
                                3
                                WHEN Nvl(job.process_num, 1) < 1 THEN
                                1
                                ELSE
                                Nvl(job.process_num, 1)
                            END AS "process_num" 
                            ,job.Frequency as "frequency"
                            ,CASE
                                WHEN To_Number(To_Char(Nvl(job.Day_Of_Week, 1))) < 1 THEN
                                1
                                WHEN To_Number(To_Char(Nvl(job.Day_Of_Week, 1))) > 7 THEN
                                7
                                ELSE
                                Nvl(job.Day_Of_Week, 1)
                            END AS "day_of_week"
                            ,Nvl(job.Day_Of_Month, 1) AS "day_of_month"
                            
                            ,job.Script as "script"
                            ,job.connection_string as "connection_string"
                            ,job.output_name as "output_name"
                            ,job.src_folder_name as "src_folder_name"
                            ,job.src_file_name as "src_file_name"
                            ,lower(job.src_file_type) as "src_file_type"
                            ,dst_folder_name as "dst_folder_name"
                            ,dst_file_name as "dst_file_name"
                            ,Lower(job.dst_file_type) AS "dst_file_type"
                            ,Nvl(job.Is_Header, 1) AS "is_header"
                            ,Nvl(job.Is_Notification, 0) AS "is_notification"
                            ,nvl(job.is_attachment,0) as "is_attachment"
                            ,job.email as "email"
                            ,job.start_date as "start_date"
                            ,job.End_Date as "end_date"
                            ,job.task_time_out as "task_time_out"
                            ,job.retry_number as "retry_number"
                            ,job.sub_task_max_retry as "sub_task_max_retry"
                            ,CASE WHEN job.parent_task_id is null then 0 else 1 end as "is_sub_task"
                            ,case when group_task.id is null then 0 else 1 end as "is_frequency_task"
                            ,case when group_task.is_notify_fail is not null then group_task.is_notify_fail else 0 end as "is_notify_fail"
                            ,case when group_task.is_notify_sucess is not null then group_task.is_notify_sucess else 0 end as "is_notify_sucess"
                        FROM   Vccb_Schedule_Job job
                        left join
                        (
                             select ID, PARENT_TASK_ID, TASK_ORDER, PROCESS_NUM, IS_NOTIFY_FAIL, IS_NOTIFY_SUCESS
                             from VCCB_JOB_frequency
                             where nvl(is_active,0) = 1
                             AND To_Char(Start_Date, 'YYYYMMDD') <= To_Char(SYSDATE, 'YYYYMMDD')
                             AND To_Char(End_Date, 'YYYYMMDD') >= To_Char(SYSDATE, 'YYYYMMDD')
                             AND to_number(to_char(sysdate,'HH24mi')) between START_FROM_TIME and END_FROM_TIME
                
                        )group_task
                             on job.ID = group_task.ID and job.Frequency = 'DAILY'
                        WHERE  Nvl(job.Active, 0) = 1
                            AND To_Char(job.Start_Date, 'YYYYMMDD') <= To_Char(SYSDATE, 'YYYYMMDD')
                            AND To_Char(job.End_Date, 'YYYYMMDD') >= To_Char(SYSDATE, 'YYYYMMDD')
                            AND (job.Frequency = 'DAILY' OR
                                    (job.Frequency = 'WEEKLY' AND job.Day_Of_Week = To_Number(To_Char(SYSDATE, 'D'))) OR
                                    (job.Frequency = 'MONTHLY' AND (CASE
                                                                    WHEN To_Number(To_Char(Nvl(job.Day_Of_Month, 1))) < 1 THEN
                                                                    1
                                                                    WHEN to_char(sysdate,'MM') = '02' AND  Nvl(job.Day_Of_Month, 1) > 28 AND Nvl(job.Day_Of_Month, 1) <> To_Number(To_Char(Last_Day(SYSDATE), 'DD')) THEN To_Number(To_Char(Last_Day(SYSDATE), 'DD'))
                                                                    WHEN Nvl(job.Day_Of_Month, 1) > 31 THEN to_number(To_Char(Last_Day(SYSDATE), 'DD'))
                                                                    ELSE
                                                                    Nvl(job.Day_Of_Month, 1)
                                                                END) = To_Number(To_Char(SYSDATE, 'DD'))))
                            AND (
                              job.run_time = 1615
                                     OR group_task.id is not null
                              )
                            AND (to_char(-1) = '-1' OR job.ID = -1)
                        ORDER  BY nvl(group_task.task_order,job.task_order)


;

select * from VCCB_JOB_frequency

update VCCB_JOB_frequency set START_FROM_TIME = 800 where id = 2

update Vccb_Schedule_Job set SUB_TASK_MAX_RETRY = 1 where id in (2,3,4,5,6)

select * from Vccb_Schedule_Job


insert into VCCB_JOB_frequency (id, PARENT_TASK_ID, TASK_ORDER, PROCESS_NUM,START_DATE,END_DATE,  START_FROM_TIME, END_FROM_TIME,  IS_NOTIFY_FAIL, IS_NOTIFY_SUCESS)
select id, PARENT_TASK_ID, task_order, PROCESS_NUM, start_date, end_date
, 800 START_FROM_TIME
,2200 END_FROM_TIME
,0 IS_NOTIFY_FAIL
,1 IS_NOTIFY_SUCESS
from Vccb_Schedule_Job
where id in (2,3,4,5,6)

alter table VCCB_JOB_frequency add (is_active number(1))
