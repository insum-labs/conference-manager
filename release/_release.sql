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


-- *** Objects ***
-- #3
@@../install/ks_event_admins.sql


@@../views/ks_events_tracks_v.sql

-- *** DML ***



-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);

