
set serveroutput on

declare
  l_count pls_integer;

begin
  -- Create Table
  select count(1)
  into l_count
  from user_tables
  where table_name = 'CONSTRAINT_LOOKUP';

  if l_count = 0 then
    execute immediate '
    create table constraint_lookup
    (   constraint_name varchar2(255) primary key not null
      , message         varchar2(4000)
    )';
    dbms_output.put_line('Table CONSTRAINT_LOOKUP created');
  else
    dbms_output.put_line('Table CONSTRAINT_LOOKUP already exists');
  end if;
end;
/
