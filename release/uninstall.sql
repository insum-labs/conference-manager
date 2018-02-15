--  verify off prevents the old/new substitution message
SET verify off
--  feedback - Displays the number of records returned by a script ON=1
SET feedback off
--  timing - Displays the time that commands take to complete
SET timing off

PRO _________________________________________________
PRO |   Droping all tables                          |
PRO +-----------------------------------------------+
PRO


PRO drop ks_session_load
drop table ks_session_load purge;

PRO drop ks_session_votes
drop table ks_session_votes purge;

PRO drop ks_sessions
drop table ks_sessions purge;

PRO drop ks_event_tracks
drop table ks_event_tracks purge;

PRO drop ks_events
drop table ks_events purge;

-- Dont drop because it's shared across applications
PRO deleting KS constrainst
delete from constraint_lookup where constraint_name like 'KS_%';
-- drop table constraint_lookup purge;


PRO drop ks_users
drop table ks_users purge;

-- PRO drop ks_user_roles
-- drop table ks_user_roles purge;

PRO drop ks_parameters
drop table ks_parameters purge;

PRO drop ks_tracks
drop table ks_tracks purge;


PRO drop ks_tags
drop table ks_tags purge;

PRO drop ks_tag_sums
drop table ks_tag_sums purge;

PRO drop ks_tag_type_sums
drop table ks_tag_type_sums purge;

PRO drop ks_session_status
drop table ks_session_status purge;

