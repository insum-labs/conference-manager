create or replace package body ks_session_load_api
is

--------------------------------------------------------------------------------
-- TYPES
/**
 * @type
 */

-- CONSTANTS
/**
 * @constant gc_scope_prefix Standard logger package name
 */
gc_scope_prefix constant varchar2(31) := lower($$PLSQL_UNIT) || '.';



------------------------------------------------------------------------------
/**
 * Load rows from `ks_session_load` into `ks_sessions` and `ks_session_votes`.
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created September 2, 2016
 * @param p_app_user user loading data.
 * @param p_into_event_id event_id for the sessions being loaded.
 * @param p_into_track_id tracks_id for the sessions being loaded.
 */
procedure load_sessions(
    p_app_user       in ks_users.username%TYPE
  , p_into_event_id  in ks_event_tracks.event_id%TYPE
  , p_into_track_id  in ks_event_tracks.id%TYPE)
is
  -- l_scope logger_logs.scope%type := gc_scope_prefix || 'load_sessions';
  -- l_params logger.tab_param;

  l_session_id ks_sessions.id%type;

begin
  -- logger.append_param(l_params, 'p_app_user', p_app_user);
  -- logger.append_param(l_params, 'p_into_event_id', p_into_event_id);
  -- logger.append_param(l_params, 'p_into_track_id', p_into_track_id);
  -- logger.log('BEGIN', l_scope, null, l_params);


  for s in (
    with session_info as (
      select distinct l.app_user
           , l.session_num
           , l.sub_categorization
           , l.session_type
           , l."SESSION" title
           , l.primary_presenter
           , l.co_presenter
        from ks_session_load l
    )
    select l.session_num
         , l.sub_categorization
         , l.session_type
         , l.title
         -- , trim(regexp_replace(l.primary_presenter, '(.*)\((.*)\)','\1')) presenter
         , rtrim(substr(l.primary_presenter,1,instr(l.primary_presenter,'(',1,1)-1)) presenter
         , l.co_presenter
         -- , regexp_replace(l.primary_presenter, '(.*)\((.*)\)','\2') company
         , rtrim(substr(l.primary_presenter,instr(l.primary_presenter,'(',1,1)+1,length(substr(l.primary_presenter,instr(l.primary_presenter,'(',1,1)+1))-1)) company
     from session_info l
    where l.app_user = p_app_user
  )
  loop    

    insert into ks_sessions (
        event_id
      , event_track_id
      , session_num
      , sub_category
      , session_type
      , title
      , presenter
      , co_presenter
      , company
    )
    values (
        p_into_event_id
      , p_into_track_id
      , s.session_num
      , s.sub_categorization
      , s.session_type
      , s.title
      , s.presenter
      , s.co_presenter
      , s.company
    )
    returning id into l_session_id;

    -- Load votes for session
    insert into ks_session_votes (
        session_id
      , session_num
      , voter
      , vote
      , comments
    )
    select l_session_id
         , s.session_num
         , ld.voter
         , ld.total
         , ld."COMMENT" voter_comment
      from ks_session_load ld
     where ld.session_num = s.session_num;

  end loop;

  -- logger.log('END', l_scope, null, l_params);

exception
  when OTHERS then
    -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end load_sessions;




end ks_session_load_api;
/
