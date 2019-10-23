PRO Installing 4.0.0 (Kscope20)

--  sqlblanklines - Allows for SQL statements to have blank lines
set sqlblanklines on
--  define - Sets the character used to prefix substitution variables
set define '^'


PRO _________________________________________________
PRO . TABLES and DDL

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


-- 
PRO .. Allow multi-byte chars for tags
-- alter table ks_tags modify tag varchar2(255);
-- alter table ks_tag_sums modify tag varchar2(255);
-- alter table ks_tag_type_sums modify tag varchar2(255);


-- #44
PRO .. Session Length
alter table ks_full_session_load add session_length varchar2(500);
alter table ks_sessions add session_length varchar2(500);



PRO _________________________________________________
PRO . VIEW

@../views/ks_sessions_v.sql
@../views/ks_users_v.sql

-- #2
@../views/ks_events_communities_v.sql
@../views/ks_events_communities_tracks_v.sql




PRO _________________________________________________
PRO . PACKAGES

-- #35
@../plsql/ks_notification_api.pls
@../plsql/ks_notification_api.plb

-- #36
@../plsql/ks_session_api.pls
@../plsql/ks_session_api.plb


-- #44
@../plsql/ks_session_load_api.pls
@../plsql/ks_session_load_api.plb


@../plsql/ks_util.pls
@../plsql/ks_util.plb


@../plsql/ks_tags_api.plb



@../views/ks_events_comps_v.sql


PRO _________________________________________________
PRO . DML

PRO .. Make presenter_user_id mandatory
@../conversion/populate_presenter_user_id.sql

alter table ks_sessions modify presenter_user_id not null;



-- #2
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_COMMUNITY_TRACKS_U01','That track is already part of the community.');
insert into constraint_lookup (constraint_name,message) values ('KS_COMMUNITY_TRACKS_FK','The community cannot be removed when it has tracks.');
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_COMMUNITY_TRACKS_FK', 'The track cannot be removed if it is associated with a community.');
-- #35
insert into ks_parameters (category, name_key, value, description) values ('Notifications','SESSION_MOVED_BETWEEN_TRACKS_TEMPLATE','SESSION_MOVED_BETWEEN_TRACKS','Name of email template for when a session is moved between tracks');

delete from ks_email_templates where name = 'SESSION_MOVED_BETWEEN_TRACKS';
insert into ks_email_templates (name, template_text)
 values ('SESSION_MOVED_BETWEEN_TRACKS'
  , q'{The session <i>"#SESSION_TITLE#"</i> from #SPEAKER# has been moved from <i>#FROM_TRACK#</i> to <b>#TO_TRACK#</b>

Sub Category : <i>#SUB_CATEGORY#</i>
Session Type : <i>#SESSION_TYPE#</i>

All existing votes from <i>#FROM_TRACK#</i> track have been removed.
Tags most likely should be revised.
}');

-- ## 44
@../conversion/seed_ks_load_mapping.sql


-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);
