-- Create table
create table VCCB_SERVICE_IMPORT_LOG
(
  file_id       NUMBER(20),
  template_name VARCHAR2(250),
  file_name     VARCHAR2(1000),
  import_date   DATE,
  is_import     NUMBER(1)
)
;
