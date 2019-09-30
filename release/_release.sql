PRO Installing 4.0.0 (Kscope20)

--  sqlblanklines - Allows for SQL statements to have blank lines
set sqlblanklines on
--  define - Sets the character used to prefix substitution variables
set define '^'



-- *** DDL ***

-- #2
@../install/ks_event_communities.sql
@../install/ks_event_community_tracks.sql


-- *** Views ***



-- *** Objects ***



-- *** DML ***

-- #2
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_COMMUNITY_TRACKS_U01','That track is already part of the community.');
insert into constraint_lookup (constraint_name,message) values ('KS_COMMUNITY_TRACKS_FK','The community cannot be removed when it has tracks.');



  
-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);

