create TABLE VCCB_SCHEDULE_JOB_HIS
(
       ID NUMBER(18),
       TASK_NAME VARCHAR2(255),
       TASK_JOB_NAME VARCHAR2(255),
       start_date date,
       end_date date,
       note varchar2(1000),
       is_completed number(1),
       log_date date
)
