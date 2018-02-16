
-- =============================================================================

insert into ks_session_status (display_seq, code, name, active_ind) values (35, 'ALT', 'Alternate', 'Y');



-- =============================================================================

-- install new version of the staging table to accomodate the new columns
@../install/ks_full_session_load.sql


-- install staging table's "lookup table" for what columns in it match what columns in the export file
@../install/ks_load_mapping.sql
@../conversion/seed_ks_load_mapping.sql


-- new tables to accomdate roles
@../install/ks_roles.sql
@../conversion/seed_ks_roles.sql


@../install/ks_user_event_track_roles.sql



-- =============================================================================
@../conversion/move_owners_to_roles.sql

-- drop track owner from the track instance
alter table ks_event_tracks drop column owner;




-- =============================================================================
-- add voting date fields to events and event-tracks
alter table ks_events add (
    blind_vote_begin_date  date
  , blind_vote_end_date    date
  , committee_vote_begin_date date
  , committee_vote_end_date   date
)
/
comment on column ks_events.blind_vote_begin_date is 'Begin date of blind voting';
comment on column ks_events.blind_vote_end_date is 'End date of blind voting';
comment on column ks_events.committee_vote_begin_date is 'Begin date of committee voting';
comment on column ks_events.committee_vote_end_date is 'End date of committee voting';

alter table ks_event_tracks add (
    blind_vote_begin_date  date
  , blind_vote_end_date    date
  , committee_vote_begin_date date
  , committee_vote_end_date   date
)
/

comment on column ks_event_tracks.blind_vote_begin_date is 'Track Override for Begin date of blind voting';
comment on column ks_event_tracks.blind_vote_end_date is 'Track Override for End date of blind voting';
comment on column ks_event_tracks.committee_vote_begin_date is 'Track Override for Begin date of committee voting';
comment on column ks_event_tracks.committee_vote_end_date is 'Track Override for End date of committee voting';


-- =============================================================================
alter table ks_event_tracks add (
    blind_vote_help        varchar2(4000)
  , committee_vote_help    varchar2(4000)
)
/
comment on column ks_event_tracks.blind_vote_help is 'Help for blind voters';
comment on column ks_event_tracks.committee_vote_help is 'Help for committee voters';




-- =============================================================================
alter table ks_users add external_sys_ref varchar2(20);
comment on column ks_users.external_sys_ref is 'Unique "ID" for external system.';





-- =============================================================================

--Update ks_sessions to allow for scoring, and other input from the user's uploading of an excel file.
alter table ks_sessions add presenter_email varchar2(500);
alter table ks_sessions add session_summary varchar2(4000);
alter table ks_sessions add session_abstract clob;
alter table ks_sessions add target_audience varchar2(60);
alter table ks_sessions add presented_before_ind varchar2(1) default on null 'N';
alter table ks_sessions add presented_before_where varchar2(4000);
alter table ks_sessions add technology_product varchar2(500);
alter table ks_sessions add ace_level varchar2(30);
alter table ks_sessions add video_link varchar2(4000);
alter table ks_sessions add contains_demo_ind varchar2(1) default on null 'N';
alter table ks_sessions add webinar_willing_ind varchar2(1) default on null 'N';
alter table ks_sessions add presenter_biography clob;
alter table ks_sessions add external_sys_ref varchar2(20);
alter table ks_sessions add presenter_user_id varchar2(20);
alter table ks_sessions add co_presenter_user_id varchar2(20);

alter table ks_sessions add constraint sessions_ck_presb4_is_yn check (presented_before_ind in ('Y', 'N'));
alter table ks_sessions add constraint sessions_ck_demo_is_yn check (contains_demo_ind in ('Y', 'N'));
alter table ks_sessions add constraint sessions_ck_web_will_is_yn check (webinar_willing_ind in ('Y', 'N'));

comment on column ks_sessions.presenter_email is 'The email address to contact the presenter.';
comment on column ks_sessions.session_summary is 'Summary/Short description. This is cut off at 4000 characters since anything submitted that''s longer is not short.';
comment on column ks_sessions.session_abstract is 'The full abstract of the session. This is a clob b/c it can be > 4000 characters';
comment on column ks_sessions.target_audience is 'The audience the session is intended for. Can be multiple audiences.';
comment on column ks_sessions.presented_before_ind is 'Whether the presenter has presented this session before.';
comment on column ks_sessions.presented_before_where is 'Where the presenter has presented this session before. ';
comment on column ks_sessions.technology_product is 'Technologies or products discussed in the presentation.';
comment on column ks_sessions.ace_level is 'Whether the presenter is part of an ace program. The common values are No, Oracle Ace, Oracle Ace Director, Oracle Ace Associate.';
comment on column ks_sessions.video_link is 'Link to a video for furth info about the session.';
comment on column ks_sessions.contains_demo_ind is 'Whether a demo is included. Correct values or Y or N.';
comment on column ks_sessions.webinar_willing_ind is 'Whether the presenter is willing to do the session as a webinar. Correct values are Y or N.';
comment on column ks_sessions.presenter_biography is 'The biography of this session''s presenter.';
comment on column ks_sessions.external_sys_ref is 'Unique "ID" for external system.';
comment on column ks_sessions.presenter_user_id is 'External System User ID of the presenter';
comment on column ks_sessions.co_presenter_user_id is 'External System User ID of the co-presenter';


alter table ks_sessions modify tags varchar2(1000);





-- =============================================================================
-- adding event-types
@../install/ks_event_types.sql
@../conversion/seed_ks_event_types.sql

alter table ks_events add
  event_type varchar2(20);

comment on column ks_events.event_type is 'type of event';

update ks_events
  set event_type = 'KSCOPE';

-- add foreign key constraint from events to event-types
alter table ks_events add constraint ks_events_event_type_fk foreign key (event_type) references ks_event_types (code);
alter table ks_events modify event_type not null;





-- =============================================================================

-- modifications for voting by community and committee
alter table ks_session_votes add (
    vote_type varchar2(10)  -- COMMITTEE | BLIND
  , username  varchar2(60)
)
/

comment on column ks_session_votes.vote_type is 'Identifies the type of vote recorded: COMMITTEE or BLIND';
comment on column ks_session_votes.username is 'User that casted the vote.';


alter table ks_session_votes modify vote_type not null;
alter table ks_session_votes modify username not null;


--Now Add users that are existent in ks_session_voter but not in ks_users
merge into ks_users u
  using (select distinct username, voter from ks_session_votes) v
  on (u.username = v.username)
  when not matched
    then
      insert (username, first_name, active_ind, admin_ind) values (v.username, v.voter, 'Y', 'N')
/

--Finally drop the voter column
alter table ks_session_votes drop column voter
/

-- one vote per user per session
create unique index ks_session_votes_u01 on ks_session_votes(username, session_id);


-- =============================================================================
-- Seed ks_parameters
delete from ks_parameters where name_key = 'DEFAULT_BLIND_VOTING_HELP';
insert into ks_parameters(category, name_key, value, description)
                   values('Messages',
                          'DEFAULT_BLIND_VOTING_HELP'
                        , 'Vote on all sessions to the best of your ability.<br>'
                       || '1 is the lowest rating and 5 is the highest. Use 1 or 2 for sessions you have no interest in.'
                        , 'The default help message for blind voters viewed while voting on a track.');

delete from ks_parameters where name_key = 'DEFAULT_COMMITTEE_VOTING_HELP';
insert into ks_parameters(category, name_key, value, description)
                   values('Messages'
                        , 'DEFAULT_COMMITTEE_VOTING_HELP'
                        , 'Vote on all sessions to the best of your ability.<br>'
                       || '1 is the lowest rating and 5 is the highest. Use 1 or 2 for sessions you have no interest in.'
                        , 'The default help message for blind voters viewed while voting on a track.');

delete from ks_parameters where name_key = 'REVIEW_PRIVACY_NOTICE';
insert into ks_parameters(category, name_key, value, description)
                   values('Messages',
                          'REVIEW_PRIVACY_NOTICE',
                          'Remember, all the votes and comments are private information and can only be discussed with other members of the committee.',
                          'This message is viewed once by anyone using the review app.');

delete from ks_parameters where name_key = 'VOTING_PRIVACY_NOTICE';
insert into ks_parameters(category, name_key, value, description)
                   values('Messages',
                          'VOTING_PRIVACY_NOTICE',
                          'Remember, all the votes and comments are private information and can only be discussed with the content committee.',
                          'This message is viewed once by anyone using the voting app.');


-- 
delete from ks_parameters where name_key = 'ANONYMIZE_EXTRA_TOKENS';
insert into ks_parameters(category, name_key, value, description)
                   values('Sessions'
                        , 'ANONYMIZE_EXTRA_TOKENS'
                        , ''
                        , 'Case-insensitive, space-delimited list of words to anonymize. E.g. "Word1 Word2 Word3"');

-- 
delete from ks_parameters where name_key in ('EMAIL_FROM_ADDRESS', 'FEEDBACK_EMAIL', 'EMAIL_OVERRIDE', 'EMAIL_PREFIX');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'EMAIL_FROM_ADDRESS', 'info@noname.com', 'Email addresses used to send emails.');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'FEEDBACK_EMAIL', 'info@noname.com', 'Email addresses that will receive system feedback.');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'EMAIL_OVERRIDE', '', 'Comma delimited list of emails that will be used to override all emails from the system.  For use during dev and test.');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'EMAIL_PREFIX', '[VOTEAPP] ', 'Prefix used when sending emails');

delete from ks_parameters where name_key in ('VOTING_APP_ID');
insert into ks_parameters(category, name_key, value, description) values ('SYSTEM', 'VOTING_APP_ID', '120124', 'ID of voting app');

-- =============================================================================

@../conversion/seed_constraint_lookup.sql




-- =============================================================================

@../views/ks_users_v.sql
@../views/ks_events_tracks_v.sql




-- =============================================================================
PRO PACKAGES
PRO .Specs
--install .xlsx reader
PRO .package_read_xlsx_clob
@../plsql/package_read_xlsx_clob.pks
PRO .ks_log
@../plsql/ks_log.pls
PRO .ks_user_dml
@../plsql/ks_user_dml.pls
PRO .ks_util
@../plsql/ks_util.pls
PRO .ks_session_load_api
@../plsql/ks_session_load_api.pls
PRO .ks_users_api
@../plsql/ks_users_api.pls
PRO .ks_session_api
@../plsql/ks_session_api.pls
PRO .ks_user_event_track_roles_dml
@../plsql/ks_user_event_track_roles_dml.pls

PRO .Body
PRO .ks_log
@../plsql/ks_log.plb
PRO ks_user_dml
@../plsql/ks_user_dml.plb
PRO package_read_xlsx_clob
@../plsql/package_read_xlsx_clob.pkb
PRO ks_util
@../plsql/ks_util.plb
PRO ks_session_load_api
@../plsql/ks_session_load_api.plb
PRO ks_users_api
@../plsql/ks_users_api.plb
PRO .ks_session_api
@../plsql/ks_session_api.plb
PRO ks_user_event_track_roles_dml
@../plsql/ks_user_event_track_roles_dml.plb


