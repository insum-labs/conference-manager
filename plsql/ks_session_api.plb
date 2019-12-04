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



/**
 * Private function, checks if the speaker/presenter is comped, i.e. is added to the list of comped users for the event
 *
 * @example
 *
 * @issue #36
 *
 * @author Ramona Birsan
 * @created October 8, 2019
 * @param p_presenter_user_id
 * @return 1 if speaker/presenter is comped
 */
function is_speaker_comped (
    p_event_id in ks_sessions.event_id%type
  , p_presenter_user_id in ks_sessions.presenter_user_id%type
) return number
is
  pragma UDF;
  l_scope  ks_log.scope := gc_scope_prefix || 'is_speaker_comped';
  -- l_params logger.tab_param; 
  l_is_comped number(1) := 0;
begin
  -- logger.append_param(l_params, 'p_event_id', p_event_id);
  -- logger.append_param(l_params, 'p_presenter_user_id', p_presenter_user_id);
  $IF $$VERBOSE_OUTPUT $THEN
  ks_log.log('START', l_scope);
  $END
 
  select 1 into l_is_comped
    from ks_event_comp_users cu 
    join ks_users u on (u.id = cu.user_id)
   where cu.event_id = p_event_id
     and u.external_sys_ref = p_presenter_user_id;
     
  return l_is_comped;
  
  exception 
    when no_data_found then
      return 0;
    when others then
      ks_log.log('Unhandled Exception ', l_scope);
      raise;
end is_speaker_comped;






------------------------------------------------------------------------------
/**
 *  Output of the form:
 *    apex_json.open_object;
 *    apex_json.write('p_presenter_user_id', p_presenter_user_id);
 *    apex_json.write('trackList', '<ul><li>Track 1</li></ul>');
 *    apex_json.close_object;
 *
 * @example
 *
 * @issue #36 - use presenter_user_id to fetch the list of tracks
 *
 * @author Jorge Rimblas
 * @created September 9, 2016
 * @param p_event_id
 * @param p_presenter_user_id
 * @return
 */
procedure presenter_tracks_json(
    p_event_id  in ks_events.id%TYPE
  , p_presenter_user_id in ks_sessions.presenter_user_id%TYPE)
is
  -- l_scope logger_logs.scope%type := gc_scope_prefix || 'presenter_tracks_json';
  -- l_params logger.tab_param;

  list_cur sys_refcursor;
begin
  -- logger.append_param(l_params, 'p_event_id', p_event_id);
  -- logger.append_param(l_params, 'p_presenter_user_id', p_presenter_user_id);
  -- logger.log('BEGIN', l_scope, null, l_params);

  open list_cur for
    select p_presenter_user_id "presenter_user_id"
          ,'<ul><li>' ||listagg(n || ' in ' || p || ' (' || status || ')', '</li><li>') within group (order by display_seq) || '</li></ul>' "trackList"
    from (
      select t.display_seq, nvl(t.alias, t.name) p, count(*) n
           , listagg(nvl(st.name, '?'), ',') within group (order by st.display_seq) status
        from ks_event_tracks t
           , ks_sessions s
           , ks_session_status st
       where t.id = s.event_track_id
         and s.event_id = to_number(p_event_id)
         and s.presenter_user_id = p_presenter_user_id
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
    apex_json.write('p_presenter_user_id', p_presenter_user_id);
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
  $IF $$VERBOSE_OUTPUT $THEN
  ks_log.log('START', l_scope);
  $END

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

  if p_anonymize = 'Y' and nvl(ks_util.get_param('ANONYMIZE_TOKENS'), 'YES') = 'YES' then
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
 * Get the following data to allow navigation of the sessions:
 *    - Previous Session ID
 *    - Next Session ID
 *    - Current Row
 *    - Total Row
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
  l_alias varchar2(1);
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

  $IF wwv_flow_api.c_current >= 20180404 $THEN
    -- in 18.1 the alias changed from r to i
    l_alias := 'i';
  $ELSE
    l_alias := 'r';
  $END

  --l_report.sql_query selects the columns indicated on the option "menu Action > Select Columns" from the SQL Query indicated on the App Builder's IR Configuration.
  --The following line replaces the list of selected columns on l_report.sql_query by all the columns.
  --Ex: SESSION_NUM is not displayed on the IR, so it is not selected on l_report.sql_query.
  --Selecting all the columns with r.*, allows to order by any column indicated on the option "menu Action > Data > Sort" even if it is not included on "menu Action > Select Columns".
  --Also, the total number of rows is calculated at this level.
  l_sql := 'select count (id) over () as total_rows'
       || ',' || l_alias || '.*'
       || substr (l_sql, instr (l_sql, ' from '));

  l_order_by := ks_util.get_ir_order_by (p_ir_query => l_sql);
  $IF wwv_flow_api.c_current >= 20180404 $THEN
  -- in APEX 18.1 the order by construct changed and got an extra wrap ")i"
  if instr(l_order_by, ')i') > 0 then
    l_order_by := substr(l_order_by, 1, instr(l_order_by, ')i') -1);
  end if;
  $END

  $IF $$VERBOSE_OUTPUT $THEN
    ks_log.log ('order by:' || l_order_by, l_scope);
  $END

  if l_order_by is null then
    l_order_by := 'order by session_num';
  end if;

  l_sql := 'select next
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
    ks_log.log ('New l_sql:' || l_sql, l_scope);
  $END

  l_cur := dbms_sql.open_cursor;

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
 * For a given track session and user, indicate if the given user is the presenter 
 * or copresenter of the session.
 * The comparison is done against the ks_users.external_sys_ref which identifies users
 * in the external system.
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
 ,p_username   in varchar2
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
   where u.username = p_username;

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




/**
 * Parse the "video link" text returning one line per link and formatting the link as an html anchor tag when applied.
 *
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 15, 2018
 * @param p_video_link
 * @return parsed text containing the link as a html anchor tag.
 */
function parse_video_link (
  p_video_link in ks_sessions.video_link%type
)
return varchar2
is 
  l_scope ks_log.scope := gc_scope_prefix || 'parse_video_link';
  
  c_link_format constant varchar2(1000) := '<a id="VIDEO_URL" href="#LINK#" target="_blank" alt="Video" title="Video">#LINK#</a>';
  
  l_links apex_t_varchar2;
  l_key varchar2(1000);
  l_link varchar2(32000);
  l_return varchar2(32000);
  l_is_not_first_line boolean := FALSE;
begin
  ks_log.log ('START', l_scope);

  l_links := apex_string.split(p_video_link, '<br />');
  l_key := l_links.first;
  
  while (l_key is not null)
  loop
    l_link := l_links (l_key);

    if substr (trim (l_link), 1, 4) = 'http' then 
      l_link := replace (c_link_format, '#LINK#', l_link);
    end if;

    if l_is_not_first_line then 
      l_return := l_return || '<br>' || l_link;
    else 
      l_return := l_link;
      l_is_not_first_line := TRUE;
    end if;

    l_key := l_links.next (l_key);
  end loop;

  ks_log.log ('END', l_scope);
  return l_return;

exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end parse_video_link;






/**
 * The function returns presenter's comp per track - this is identical for all tracks 
 * for which the user has submitted sessions.
 * Assumes that it will be called from within a SQL query, hence no track validation.
 * And the UDF pragma
 * 
 * @example - Displays presenter's comp for each associated track
    select  s.event_track_id
          , s.presenter_user_id
          , ks_session_api.get_presenter_comp(s.event_id, s.event_track_id , s.presenter_user_id) as presenter_comp
       from ks_sessions s
      where s.event_id = :p_event_id
        and s.presenter_user_id = :p_presenter_user_id
   group by s.event_id, s.event_track_id, s.presenter_user_id
   order by s.event_track_id
 *
 * @issue #36
 *
 * @author Ramona Birsan
 * @created October 7, 2019
 * @param p_event_id   
 * @param p_event_track_id
 * @param p_presenter_user_id
 * @return number
 */
function get_presenter_comp (
    p_event_id in ks_sessions.event_id%type 
  , p_event_track_id in ks_sessions.event_track_id%type    
  , p_presenter_user_id in ks_sessions.presenter_user_id%type 
) return number
is 
  pragma UDF;

  l_scope  ks_log.scope := gc_scope_prefix || 'get_presenter_comp';
  -- l_params logger.tab_param;
  l_presenter_comp number(3,2) := 0;
begin
  -- logger.append_param(l_params, 'p_event_id', p_event_id);
  -- logger.append_param(l_params, 'p_event_track_id', p_event_track_id);
  -- logger.append_param(l_params, 'p_presenter_user_id', p_presenter_user_id);
  $IF $$VERBOSE_OUTPUT $THEN
  ks_log.log('START', l_scope);
  $END
  
  if is_speaker_comped (p_event_id, p_presenter_user_id) = 1 then 
    l_presenter_comp := 0;
  else
    -- "distinct event_track_id" is used because we calculate the total number of 
    -- tracks which have at least one session accepted
    with speaker_comp_track_ratio as (
      select  r.presenter_user_id
            , round(1/sum (r.track_comp),2) as speaker_comp_ratio
        from (
             select s.presenter_user_id
                  , count(distinct s.event_track_id) as track_comp
               from ks_sessions s
              where s.status_code = 'ACCEPTED' 
                and s.event_id = p_event_id 
              group by s.event_track_id, s.presenter_user_id 
         ) r
       group by r.presenter_user_id
      having r.presenter_user_id = p_presenter_user_id
    )
    select count (*) * tr.speaker_comp_ratio 
      into l_presenter_comp
      from speaker_comp_track_ratio tr
     where exists ( select 1
                      from ks_sessions ss
                     where ss.status_code = 'ACCEPTED'
                       and ss.event_id = p_event_id
                       and ss.event_track_id = p_event_track_id
                       and ss.presenter_user_id = p_presenter_user_id)
     group by tr.speaker_comp_ratio;
      
  end if;
  
  return l_presenter_comp;

  exception
    when no_data_found then
      return l_presenter_comp;
    when others then
      ks_log.log_error('Unhandled Exception ', l_scope);
      raise;
end get_presenter_comp;



end ks_session_api;
/