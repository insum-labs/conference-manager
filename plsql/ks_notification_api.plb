set define off
create or replace package body ks_notification_api
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
-- gc_template_load_notif constant ks_parameters.name_key%type := 'LOAD_NOTIFICATION_TEMPLATE';


------------------------------------------------------------------------------
/**
 * Get ready all the parameters to notify by email.
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 6, 2018
 * @param
 */
function replace_substr_template (
   p_template_name in varchar2
  ,p_substrings in t_WordList default g_blank_sub_strings
)
return clob
is
  l_scope logger_logs.scope%type := gc_scope_prefix || 'replace_substr_template';

  l_msg clob;
  l_key varchar(30);
  l_substring varchar2(32000);
begin
  ks_log.log('BEGIN', l_scope);

  select  t.template_text 
  into    l_msg 
  from    ks_email_templates t
  where   t.name = p_template_name;

  l_key := p_substrings.first;

  while (l_key is not null)
  loop
    l_msg := replace (l_msg, '#' || upper (l_key) || '#', p_substrings(l_key) );
    l_key := p_substrings.next(l_key);
  end loop;

  ks_log.log('l_msg:' || l_msg, l_scope);
  ks_log.log('END', l_scope);
  return l_msg;
exception
  when OTHERS then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end replace_substr_template;



/**
 * Get ready all the parameters to notify by email.
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 6, 2018
 * @param
 */
procedure send_email (
   p_to in varchar2 default null
  ,p_from in varchar2
  ,p_cc in varchar2 default null
  ,p_bcc in varchar2 default null
  ,p_subject in varchar2
  ,p_body in clob
  ,p_body_html in clob default null
  ,p_template_name in varchar2 default null
  ,p_substrings in t_WordList default g_blank_sub_strings
)
is
  l_scope logger_logs.scope%type := gc_scope_prefix || 'send_email';

  l_body clob;
begin
  ks_log.log('BEGIN', l_scope);

  if p_template_name is not null then 
    l_body := replace_substr_template (
      p_template_name => p_template_name
     ,p_substrings => p_substrings
    );
  else 
    l_body := p_body;
  end if;

  ks_email_api.send (
     p_to => p_to
    ,p_cc => p_cc
    ,p_bcc => p_bcc
    ,p_from => p_from
    ,p_replyto => null
    ,p_subj => p_subject
    ,p_body => l_body
    ,p_body_html => p_body_html
  );

  ks_log.log('END', l_scope);
exception
  when OTHERS then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end send_email;




/**
 * 
 * Notify the users of the tracks marked during the Load Session wizard.
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/08/2019
 * @param p_notify_owner
 * @param p_notify_voter
 */
procedure notify_track_session_load (
    p_notify_owner in varchar2
  , p_notify_voter in varchar2
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'notify_track_session_load';

  l_substrings t_WordList;
  l_from ks_parameters.value%type;
  l_subject_prefix ks_parameters.value%type;
  l_subject ks_parameters.value%type;
  l_template_name ks_parameters.value%type;
  l_voting_app_link ks_parameters.value%type;
begin
  ks_log.log('START', l_scope);

  l_from := ks_util.get_param('EMAIL_FROM_ADDRESS');
  l_subject_prefix := ks_util.get_param('EMAIL_PREFIX');
  l_template_name := ks_util.get_param('LOAD_NOTIFICATION_TEMPLATE');
  l_voting_app_link := ks_util.get_param('SERVER_URL') || ks_util.get_param('VOTING_APP_ID');

  l_substrings('VOTING_APP_LINK') := l_voting_app_link;

  --TODO jwall: add a distinct on emails!!
  for rec in (
    with user_emails as (
      select  sl.track_name
             ,sl.session_count
             ,u.email 
      from    ks_user_event_track_roles uetr
      join    ks_users u 
      on      uetr.username = u.username
      join    ks_session_load_coll_v sl 
      on      sl.track_id = uetr.event_track_id
      where   sl.notify_ind = 'Y'
      and     u.email is not null
      and     (
        ('OWNER' = p_notify_owner 
          and uetr.selection_role_code is not null)
        or
        ('VOTER' = p_notify_voter
          and uetr.voting_role_code is not null)
      )
      group   by sl.track_name
             ,sl.session_count
             ,u.email
    )
    select    ue.track_name
             ,ue.session_count
             ,listagg (ue.email,',') within group (order by ue.email desc) as email
    from      user_emails ue 
    group     by ue.track_name
             ,ue.session_count
  )
  loop
    ks_log.log (rec.track_name || '-' || rec.session_count || '-' || rec.email, l_scope);
    
    l_substrings('SESSION_COUNT') := rec.session_count;
    l_substrings('TRACK_NAME') := rec.track_name;

    l_subject := l_subject_prefix || ' New sessions for: ' || rec.track_name;

    send_email (
       p_to => null
      ,p_from => l_from
      ,p_cc => null
      ,p_bcc => rec.email
      ,p_subject => l_subject 
      ,p_body => null
      ,p_body_html => null
      ,p_template_name =>  l_template_name
      ,p_substrings => l_substrings
    );
  end loop;

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end notify_track_session_load;

end ks_notification_api;
/