-- Create table
create table VCCB_JOB_frequency
(
  id                 NUMBER(18),
  parent_task_id     NUMBER(18) DEFAULT NULL,
  task_order          NUMBER(8),
  process_num        NUMBER(1),
  start_date         DATE,
  end_date           DATE,
  start_from_time NUMBER(4),
  end_from_time NUMBER(4),
  is_notify_fail NUMBER(1) DEFAULT 0,
  is_notify_sucess NUMBER(1) DEFAULT 1,
  is_active NUMBER(1) DEFAULT 1
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table VCCB_JOB_frequency
  add constraint VCCB_JOB_frequency_UNIQUE unique (ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
