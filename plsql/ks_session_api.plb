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
 * @constant gc_html_whitelist_tags a list of strings to NOT escape from. Same as the apex version but includes span and em
 * @constant gc_token_exceptions is a "|" separated list that gets passed into ks_util. It contains the tokens which we want to ommit from escaping.
 */
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';

gc_html_whitelist_tags constant varchar2(500) := '<h1>,</h1>,<h2>,</h2>,<h3>,</h3>,<h4>,</h4>,<p>,<span>,</span>,</p>,<b>,</b>,<strong>,</strong>,<i>,</i>,<ul>,</ul>,<ol>,</ol>,<li>,</li>,<br />,<hr/>,<em>,</em>';
gc_token_exceptions constant varchar2(4000) := 'oracle|apex|epm|and|its|it|of';
gc_parameter_tokens_name constant ks_parameters.name_key%type := 'ANONYMIZE_EXTRA_TOKENS';


------------------------------------------------------------------------------
/**
 * Description
 *  Output of the form:
 *    apex_json.open_object;
 *    apex_json.write('presenter', p_presenter);
 *    apex_json.write('trackList', '<ul><li>Track 1</li></ul>');
 *    apex_json.close_object;
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






/**
 * Switch votes and voting role of an user for a selected event / track.
 *
 * @example
 *
 * @issue
 *
 * @author Guillermo Hernandez
 * @created October 26, 2017
 * @param p_event_id id of the specific event.
 * @param p_track_id id of a specific track.
 * @param p_username username of the user.
 * @param p_voting_role selected voting role for the user.
 */
procedure switch_votes (
  p_event_id    in ks_sessions.event_id%TYPE
  , p_track_id    in ks_sessions.event_track_id%TYPE
  , p_username    in ks_session_votes.username%TYPE
  , p_voting_role in ks_user_event_track_roles.voting_role_code%TYPE
)
is

begin

  -- Move all votes to new vote_type
  update ks_session_votes
     set vote_type = p_voting_role
   where id in (
      select sv.id
        from ks_session_votes sv
           , ks_sessions s
       where sv.username = p_username
         and s.event_id = p_event_id
         and s.event_track_id = p_track_id
         and sv.session_id = s.id);

  update ks_user_event_track_roles
     set voting_role_code = p_voting_role
   where username = p_username
     and event_track_id = p_track_id;

end switch_votes;







--==============================================================================
-- Function: html_whitelist_clob
-- Purpose: returns a varchar2 where every chunk of 4000 characters has been html_whitelisted and tokenized
--
-- Inputs:  p_string - the clob or varchar2 to be escaped/tokenized
--          p_session_id - the session id. We use this to get the name of the presenter/company/co-presenter
--          p_anonymize - whether to hide the info
-- Output:
-- Scope: Publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/26/2017
--==============================================================================
function html_whitelist_tokenize (p_string in varchar2,
                                  p_session_id in number,
                                  p_anonymize in varchar2 default 'N',
                                  p_escape_html in varchar2 default 'Y')
  return varchar2
is
  l_scope ks_log.scope := gc_scope_prefix || 'html_whitelist_tokenize';

  l_output varchar2(32767);

  l_presenter    ks_sessions.presenter%type;
  l_co_presenter ks_sessions.co_presenter%type;
  l_company      ks_sessions.company%type;
begin
  ks_log.log('START', l_scope);

  --The id is usually null when the user's session got reset
  --We don't want to create an ugly error on top of the page already showing errors
  --So silently exit.
  if p_session_id is null then
    return '';
  end if;

  if p_escape_html = 'Y' then
    l_output := apex_escape.html_whitelist(p_string, gc_html_whitelist_tags);
  else
    l_output := p_string;
  end if;
  l_output := regexp_replace(l_output, '_x000D_', '', 1, 0, 'i');

  if p_anonymize = 'Y' then
    select s.presenter, s.company, s.co_presenter
      into l_presenter, l_company, l_co_presenter
      from ks_sessions s
     where s.id = p_session_id;

     l_output := ks_util.replace_tokens(l_output 
                                      , l_presenter || ' ' || l_company || ' ' || l_co_presenter ||' ' || ks_util.get_param(gc_parameter_tokens_name)
                                      , gc_token_exceptions);


  end if;



  return l_output;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end  html_whitelist_tokenize;


end ks_session_api;
/
