-- alter session set PLSQL_CCFLAGS='VERBOSE_OUTPUT:TRUE';
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



/**
 * Description
 *    Get the following data to allow navigation of the sessions:
 *       - Previous Session Id
 *       - Next Session Id
 *       - Current Row
 *       - Total Row
 *
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 1, 2018
 * @param p_id
 * @param p_region_static_id
 * @param p_page_id
 * @return
 * @param p_previous_id
 * @param p_next_id
 * @param p_total_rows
 * @param p_current_row
 */
procedure session_id_navigation (
   p_id in ks_sessions.id%type
  ,p_region_static_id in varchar2
  ,p_page_id in number
  ,p_previous_id out ks_sessions.event_track_id%type
  ,p_next_id out ks_sessions.event_track_id%type
  ,p_total_rows out number
  ,p_current_row out number
)
is
  l_report apex_ir.t_report;
  l_sql clob;
  l_next_id number;
  l_previous_id number;
  l_order_by varchar2 (32000);
  l_cur number;
  l_res number;
  l_total_rows number;
  l_row_num number;
  l_scope ks_log.scope := gc_scope_prefix || 'session_id_navigation';

begin
  ks_log.log('START', l_scope);

    l_report := ks_util.get_ir_report (
        p_page_id => p_page_id
      , p_static_id => p_region_static_id
    );
            
    l_sql := l_report.sql_query;  
    $IF $$VERBOSE_OUTPUT $THEN
      ks_log.log ('l_sql:' || l_sql, l_scope);
    $END

    --l_report.sql_query selects the columns indicated on the option "menu Action > Select Columns" from the SQL Query indicated on the App Builder's IR Configuration.
    --The following line replaces the list of selected columns on l_report.sql_query by all the columns.
    --Ex: SESSION_NUM is not displayed on the IR, so it is not selected on l_report.sql_query.
    --Selecting all the columns with r.*, allows to order by any column indicated on the option "menu Action > Data > Sort" even if it is not included on "menu Action > Select Columns".
    --Also, the total number of rows is calculated at this level.
    l_sql := 'select count (id) over () as total_rows
      ,r.*'
     || substr (l_sql, instr (l_sql, ' from '));

    l_order_by := ks_util.get_ir_order_by (p_ir_query => l_sql);

    if l_order_by is null then
      l_order_by := 'order by session_num';
    end if;

    l_sql := 'select  next
      ,previous
      ,total_rows
      ,row_num
    from (' ||
        '   select    id
                    , lead (id) over ( ' || l_order_by || ') next ' ||
        '           , lag (id) over ( ' || l_order_by || ') previous ' ||
        '           , total_rows ' ||
        '           , row_number () over ( ' || l_order_by || ') as row_num ' ||
        '   from (' || l_sql || 
        ' ))  where id=:ID';
    $IF $$VERBOSE_OUTPUT $THEN
      ks_log.log ('l_sql:' || l_sql, l_scope);
    $END

    l_cur := dbms_sql.open_cursor;
    $IF $$VERBOSE_OUTPUT $THEN
      ks_log.log ('l_cur:' || l_cur, l_scope);
    $END

    dbms_sql.parse (l_cur, l_sql, dbms_sql.native);

    for i in 1..l_report.binds.count
    loop
      dbms_sql.bind_variable (l_cur, l_report.binds(i).name, l_report.binds(i).value);
      $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log (l_report.binds(i).name || ':' || l_report.binds(i).value, l_scope);
      $END
    end loop;

    dbms_sql.bind_variable (l_cur, 'ID', p_id);
    dbms_sql.define_column (l_cur, 1, p_next_id);
    dbms_sql.define_column (l_cur, 2, p_previous_id);
    dbms_sql.define_column (l_cur, 3, p_total_rows);
    dbms_sql.define_column (l_cur, 4, p_current_row);

    l_res := dbms_sql.execute(l_cur);

    if dbms_sql.fetch_rows (l_cur) > 0 then
      dbms_sql.column_value (l_cur, 1, p_next_id);
      dbms_sql.column_value (l_cur, 2, p_previous_id);
      dbms_sql.column_value (l_cur, 3, p_total_rows);
      dbms_sql.column_value (l_cur, 4, p_current_row);
    end if;

    $IF $$VERBOSE_OUTPUT $THEN
      ks_log.log('p_next_id:' || p_next_id, l_scope);
      ks_log.log('p_previous_id:' || p_previous_id, l_scope);
      ks_log.log('p_total_rows:' || p_total_rows, l_scope);
      ks_log.log('p_current_row:' || p_current_row, l_scope);
    $END

    dbms_sql.close_cursor (l_cur);
    ks_log.log('END', l_scope);
exception
  when others then
    if dbms_sql.is_open (l_cur) then
      dbms_sql.close_cursor (l_cur);
    end if;

    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end  session_id_navigation;




/**
 * Description
 *    Given a session and user, indicate if the given user is the presenter or copresenter
 *    of the session.
 *
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 5, 2018
 * @param p_id
 * @return 'Y','N'
 */
function is_session_owner (
  p_session_id in ks_sessions.id%type
 ,p_user in varchar2
)
return varchar2
is 
  l_scope ks_log.scope := gc_scope_prefix || 'is_session_owner';
  
  l_return varchar2(1) := 'N';
  l_external_sys_ref ks_users.external_sys_ref%type;
  l_presenter_user_id ks_sessions.presenter_user_id%type;
  l_co_presenter_user_id ks_sessions.co_presenter_user_id%type;
begin
  ks_log.log('START', l_scope);

  select s.presenter_user_id
       , s.co_presenter_user_id
    into l_presenter_user_id
       , l_co_presenter_user_id
    from ks_sessions s
   where s.id = p_session_id;

  select u.external_sys_ref
    into l_external_sys_ref
    from ks_users u
   where u.username = p_user;

  if l_external_sys_ref in (l_presenter_user_id, l_co_presenter_user_id) then
      l_return := 'Y';
  end if;

  ks_log.log('END', l_scope);
  return l_return;

exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end is_session_owner;


end ks_session_api;
/
