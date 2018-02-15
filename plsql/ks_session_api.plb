create or replace package body ks_session_api
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
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';



------------------------------------------------------------------------------
/**
 * Description
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created September 9, 2016
 * @param p_event_id
 * @param p_presenter
 * @return
 */
procedure presenter_tracks_json(
    p_event_id  in ks_events.id%TYPE
  , p_presenter in ks_sessions.presenter%TYPE)
is
  -- l_scope logger_logs.scope%type := gc_scope_prefix || 'presenter_tracks_json';
  -- l_params logger.tab_param;

  list_cur sys_refcursor;
begin
  -- logger.append_param(l_params, 'p_event_id', p_event_id);
  -- logger.append_param(l_params, 'p_presenter', p_presenter);
  -- logger.log('BEGIN', l_scope, null, l_params);

  -- open list_cur for 
  -- select p_presenter "presenter", '<ul><li>' || listagg(nvl(t.alias, t.name), '</li><li>') within group (order by t.display_seq) || '</li></ul>' "trackList"
  --   from ks_event_tracks t
  --      , ks_sessions s
  --  where t.id s.event_track_id
  --    and s.event_id = to_number(p_event_id)
  --    and s.presenter = p_presenter
  -- );

  open list_cur for 
    select p_presenter "presenter"
         , '<ul><li>' ||listagg(n || ' in ' || p || ' (' || status || ')', '</li><li>') within group (order by display_seq) || '</li></ul>' "trackList"
    from (
      select t.display_seq, nvl(t.alias, t.name) p, count(*) n
           , listagg(nvl(st.name, '?'), ',') within group (order by st.display_seq) status
        from ks_event_tracks t
           , ks_sessions s
           , ks_session_status st
       where t.id = s.event_track_id
         and s.event_id = to_number(p_event_id)
         and s.presenter = p_presenter
         and s.status_code = st.code (+)
       group by t.display_seq, nvl(t.alias, t.name)
    );

  apex_json.write(list_cur);

  -- apex_json.open_object;
  -- apex_json.write('presenter', p_presenter);
  -- apex_json.write('trackList', '<ul><li>Track 1</li></ul>');
  -- apex_json.close_object;


  -- logger.log('END', l_scope, null, l_params);

exception
  when OTHERS then
    -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
    apex_json.open_array;
    apex_json.open_object;
    apex_json.write('presenter', p_presenter);
    apex_json.write('trackList', 'Unable to fetch list:<br>' || sqlerrm || '<br>');
    apex_json.close_object;
    apex_json.close_array;
end presenter_tracks_json;




end ks_session_api;
/
