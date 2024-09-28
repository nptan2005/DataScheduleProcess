-- Create table
create table VCCB_SCHEDULE_JOB_HIS
(
  id           NUMBER(18),
  task_name    VARCHAR2(255),
  start_date   DATE,
  end_date     DATE,
  note         VARCHAR2(1000),
  is_completed NUMBER(1),
  log_date     DATE
)
PARTITION BY RANGE(log_date) INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))  
(PARTITION P1 VALUES LESS THAN (TO_DATE('01/01/2025', 'DD/MM/YYYY')));  
CREATE INDEX VCCB_SCHEDULE_JOB_HIS_idx ON VCCB_SCHEDULE_JOB_HIS (ID);
;
