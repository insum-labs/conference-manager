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


-- #20
alter table ks_session_votes add decline_vote_flag varchar2(1);
comment on column ks_session_votes.decline_vote_flag is 'Used when a user abstains form voting on a session.';


-- *** Objects ***
-- #3
@@../install/ks_event_admins.sql


@@../views/ks_events_tracks_v.sql
@@../views/ks_events_sec_v.sql
@@../views/ks_events_allowed_v.sql

-- Added ks_log calls
@@../plsql/ks_tags_api.plb

-- #16
@@../plsql/ks_session_load_api.plb

-- #4
@@../plsql/ks_error_handler.plb


-- #1
@@../plsql/ks_session_api.pls
@@../plsql/ks_session_api.plb


-- *** DML ***
delete from ks_parameters where name_key in ('ADMIN_APP_ID');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'ADMIN_APP_ID', '83791', 'ID of Admin app');

update ks_roles
   set name = 'Public Voter'
 where role_type = 'VOTING'
   and code = 'BLIND';


-- #16
-- New columns presented_anything_ind, presented_anything_where
-- fix order
@@../conversion/seed_ks_load_mapping.sql


-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);

