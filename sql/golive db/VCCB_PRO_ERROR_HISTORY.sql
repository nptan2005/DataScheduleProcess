-- Create table
create table VCCB_PRO_ERROR_HISTORY
(
  process_name       VARCHAR2(255),
  process_key varchar2(50),
  error_msg  VARCHAR2(4000),
  note       VARCHAR2(500),
  error_date DATE,
  process_id    NUMBER(20) default null
)

PARTITION BY RANGE(error_date) INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))  
(PARTITION P1 VALUES LESS THAN (TO_DATE('01/01/2025', 'DD/MM/YYYY')));  
CREATE INDEX VCCB_PRO_ERROR_HISTORY_key_IDX ON VCCB_PRO_ERROR_HISTORY (process_key);
