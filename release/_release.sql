PRO Installing 3.0.0 (Kscope19)

--  sqlblanklines - Allows for SQL statements to have blank lines
set sqlblanklines on
--  define - Sets the character used to prefix substitution variables
set define '^'



-- *** DDL ***

-- #17
alter table ks_events add blind_vote_flag varchar2(1);
comment on column ks_events.blind_vote_begin_date is 'begin date of Public voting';
comment on column ks_events.blind_vote_end_date is 'end date of Public voting';
comment on column ks_events.blind_vote_flag is 'Indicates that the Public Voting will be "blind"';

-- #11
alter table ks_sessions add room_size_code varchar2(20);
comment on column ks_sessions.room_size_code is 'Define the size for a room S|M|L';

-- #13
alter table ks_users add expired_passwd_flag varchar2(1);
alter table ks_users add login_attempts number;
alter table ks_users add last_login_date date;
comment on column ks_users.expired_passwd_flag is 'Set to Y when the account password is expired.';
comment on column ks_users.login_attempts is 'Number of unsuccessful login attempts since last login';
comment on column ks_users.last_login_date is 'Date the user was las successful login in';


-- #16
-- Changes made by Ben Shumway
alter table ks_full_session_load add presented_anything_ind varchar2(4000);
alter table ks_full_session_load add presented_anything_where varchar2(4000);
comment on column ks_full_session_load.presented_anything_ind is 'Whether the presenter has ever done a live presentation, anywhere for anything.';
comment on column ks_full_session_load.presented_anything_where is 'Where the presenter has done live presentations (of any kind).';

alter table ks_sessions add presented_anything_ind varchar2(1);
alter table ks_sessions add presented_anything_where varchar2(4000);
alter table ks_sessions add constraint ks_sessions_pres_any_yn check (presented_anything_ind in ('Y','N'));
comment on column ks_sessions.presented_anything_ind is 'Whether the presenter has ever done a live presentation(s), anywhere for anything.';
comment on column ks_sessions.presented_anything_where is 'Where the presenter has done live presentation (of any kind)';

comment on column ks_sessions.presented_before_ind is 'Whether the session has been presented before';
comment on column ks_sessions.presented_before_where is 'Where the presentaton been done before';


-- #20
alter table ks_session_votes add decline_vote_flag varchar2(1);
comment on column ks_session_votes.decline_vote_flag is 'Used when a user abstains form voting on a session.';

create index ks_session_votes_i01 on ks_session_votes(session_id);

-- #3
@../install/ks_event_admins.sql
@../install/ks_email_templates.sql




-- *** Views ***

-- #3
@../views/ks_users_v.sql

@../views/ks_events_tracks_v.sql
@../views/ks_events_sec_v.sql
@../views/ks_events_allowed_v.sql

-- #16
@../views/ks_session_load_coll_v.sql

-- #32 
@../views/ks_sessions_v.sql





-- *** Objects ***

-- Added ks_log calls
@../plsql/ks_tags_api.plb

-- #4
@../plsql/ks_error_handler.plb

-- #1, #22, #20, #32
@../plsql/ks_session_api.pls
@../plsql/ks_session_api.plb

-- #16
@../plsql/ks_session_load_api.pls
@../plsql/ks_session_load_api.plb

-- #6, #13
@../plsql/ks_email_api.pls
@../plsql/ks_email_api.plb
@../plsql/ks_notification_api.pls
@../plsql/ks_notification_api.plb

-- #13
@../plsql/ks_sec.pls
@../plsql/ks_sec.plb




-- *** DML ***
insert into constraint_lookup (constraint_name,message) values ('KS_USERNAME_U','User already exists.');

delete from ks_parameters where name_key in ('ADMIN_APP_ID');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'ADMIN_APP_ID', '83791', 'ID of Admin app');

delete from ks_parameters where name_key in ('SERVER_URL');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'SERVER_URL', 'https://apex.oracle.com/pls/apex/f?p=', 'Server URL');

delete from ks_parameters where name_key in ('LOAD_NOTIFICATION_TEMPLATE');
insert into ks_parameters(category, name_key, value, description) values ('Notifications', 'LOAD_NOTIFICATION_TEMPLATE', 'SESSION_LOAD', 'Name of email template for load notifications');


insert into ks_parameters (category,name_key,value,description) values ('Notifications','RESET_PASSWORD_DONE_NOTIFICATION_TEMPLATE','RESET_PASSWORD_DONE_NOTIFICATION','Name of email template for when a reset password is executed');
insert into ks_parameters (category,name_key,value,description) values ('Notifications','RESET_PASSWORD_REQUEST_NOTIFICATION_TEMPLATE','RESET_PASSWORD_REQUEST_NOTIFICATION','Name of email template for reset password request notifications');


update ks_roles
   set name = 'Public Voter'
 where role_type = 'VOTING'
   and code = 'BLIND';


-- #16
-- New columns presented_anything_ind, presented_anything_where
-- fix order
@../conversion/seed_ks_load_mapping.sql
@../conversion/seed_ks_email_templates.sql


-- New Status
insert into ks_session_status (display_seq, code, name, active_ind) values (25, 'CANCELED', 'Canceled', 'Y');
  
-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);

