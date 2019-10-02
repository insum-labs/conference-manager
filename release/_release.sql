PRO Installing 4.0.0 (Kscope20)

--  sqlblanklines - Allows for SQL statements to have blank lines
set sqlblanklines on
--  define - Sets the character used to prefix substitution variables
set define '^'



-- *** DDL ***

-- #2
@../install/ks_event_communities.sql
@../install/ks_event_community_tracks.sql

-- #42
alter table ks_sessions add ranking number;
comment on column ks_sessions.ranking is 'Used to specify the rank for a group of sessions.';


-- #36
create index ks_users_i01
  on ks_users(external_sys_ref)
/
@../install/ks_event_comp_users.sql


-- *** Views ***



-- *** Objects ***



-- *** DML ***

-- #2
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_COMMUNITY_TRACKS_U01','That track is already part of the community.');
insert into constraint_lookup (constraint_name,message) values ('KS_COMMUNITY_TRACKS_FK','The community cannot be removed when it has tracks.');

-- #35
insert into ks_parameters (category, name_key, value, description) values ('Notifications','SESSION_MOVED_BETWEEN_TRACKS_TEMPLATE','SESSION_MOVED_BETWEEN_TRACKS','Name of email template for when a session is moved between tracks');
insert into ks_email_templates (name, template_text)
 values ('SESSION_MOVED_BETWEEN_TRACKS'
  , q'{The session <span style="font-style: italic;">"#SESSION_TITLE#"</span> from #SPEAKER# has been moved from <span style="font-style: italic;">#FROM_TRACK#</span> to <span style="font-style: italic;font-weight: bold;">#TO_TRACK#</span>
  Sub Category : <span style="font-style: italic;">#SUB_CATEGORY#</span>
  Session Type : <span style="font-style: italic;">#SESSION_TYPE#</span>

  All existing votes from <span style="font-style: italic;">#FROM_TRACK#</span> track have been removed.
  Tags most likely should be revised.}');


-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);

