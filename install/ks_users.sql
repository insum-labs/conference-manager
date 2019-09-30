create table ks_users (
    id               number        generated by default on null as identity (start with 1) primary key not null
  , username         varchar2(60)  not null
  , password         varchar2(200)
  , first_name       varchar2(50)
  , last_name        varchar2(50)
  , email            varchar2(254)
  , expired_passwd_flag varchar2(1)
  , active_ind       varchar2(1)   not null
  , admin_ind        varchar2(1)   not null
  , external_sys_ref varchar2(20)
  , login_attempts   number
  , last_login_date  date
  , created_by       varchar2(60)  default
                      coalesce(
                          sys_context('APEX$SESSION','app_user')
                        , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                        , sys_context('userenv','session_user')
                      )
                      not null
  , created_on       date         default sysdate not null
  , updated_by       varchar2(60)
  , updated_on       date
  , constraint ks_users_ck_active
      check (active_ind in ('Y', 'N'))
  , constraint ks_admin_users_ck
      check (admin_ind in ('Y', 'N'))
  , constraint ks_username_u unique (username)
)
enable primary key using index
/

create unique index ks_users_u01
  on ks_users(upper(username))
/
create unique index ks_users_u02
  on ks_users(upper(email))
/
create index ks_users_i01
  on ks_users(external_sys_ref)
/

comment on table ks_users is 'All users in the system.';

comment on column ks_users.username is 'Order for displaying the lines';
comment on column ks_users.admin_ind is 'Is this a System Admin user Y/N?';
comment on column ks_users.login_attempts is 'Number of unsuccessful login attempts since last login';
comment on column ks_users.last_login_date is 'Date the user was las successful login in';
comment on column ks_users.expired_passwd_flag is 'Set to Y when the account password is expired.';
comment on column ks_users.active_ind is 'Is the record enabled Y/N?';
comment on column ks_users.created_by is 'User that created this record';
comment on column ks_users.created_on is 'Date the record was first created';
comment on column ks_users.updated_by is 'User that last modified this record';
comment on column ks_users.updated_on is 'Date the record was last modified';


--------------------------------------------------------
--  DDL for Trigger ks_users_iu
--------------------------------------------------------
create or replace trigger ks_users_iu
before insert or update
on ks_users
referencing old as old new as new
for each row
begin
  if inserting then
    :new.created_on := sysdate;
    :new.created_by := coalesce(v('APP_USER'), sys_context ('userenv', 'os_user'), user);
  elsif updating then
    :new.updated_on := sysdate;
    :new.updated_by := coalesce(
                           sys_context('APEX$SESSION','app_user')
                         , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                         , sys_context('userenv','session_user')
                       );
  end if;
/*
  -- HEADS UP! This code is maintained and installed form plsql/ks_users_iu.sql
  -- This is due to the dependency on cw_sec

  if :new.password is not null then
    l_pass_w_salt := ks_sec.password_with_salt(:new.password);
    :new.password := l_pass_w_salt;
  end if;
*/

end;
/
alter trigger ks_users_iu enable;
