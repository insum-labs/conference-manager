
CLEAR SCREEN
PRO 

PRO  =========================== ODTUG Review App =========================
PRO  == Software Version: 1.00
PRO  ============================= Installation ===========================
PRO

-- Terminate the script on Error during the beginning
whenever sqlerror exit

--  define - Sets the character used to prefix substitution variables
SET define '^'
--  verify off prevents the old/new substitution message
SET verify off
--  feedback - Displays the number of records returned by a script ON=1
SET feedback off
--  timing - Displays the time that commands take to complete
SET timing off

PRO _________________________________________________
PRO |   Installing all tables                       |
PRO _________________________________________________
PRO

PRO constraint_lookup
@constraint_lookup.sql

PRO ks_session_load
@ks_session_load.sql

PRO ks_users
@ks_users.sql

-- PRO ks_user_roles
-- @ks_user_roles.sql

PRO ks_parameters
@ks_parameters.sql

PRO ks_tracks
@ks_tracks.sql

PRO ks_events
@ks_events.sql

PRO ks_event_tracks
@ks_event_tracks.sql

PRO ks_sessions
@ks_sessions.sql

PRO ks_session_votes
@ks_session_votes.sql

PRO ks_tags
@ks_tags.sql

PRO ks_session_status
@ks_session_status.sql

PRO ks_tags post install
@ks_tags_post_install.sql


PRO _________________________________________________
PRO |   Views
PRO _________________________________________________
PRO
@@../views/ks_sessions_v.sql


PRO _________________________________________________
PRO |   Seed tables                                  |
PRO _________________________________________________
PRO 

@@../conversion/seed_ks_users.sql
@@../conversion/seed_ks_tracks.sql
@@../conversion/seed_ks_sessions_status.sql
@@../conversion/seed_ks_events.sql
@@../conversion/seed_ks_event_tracks.sql

@@../conversion/seed_constraint_lookup.sql

commit;


