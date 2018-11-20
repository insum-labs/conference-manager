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



procedure fetch_user_substitions (
  p_id in ks_users.id%type
 ,p_substrings in out nocopy t_WordList
)
is 
  l_scope logger_logs.scope%type := gc_scope_prefix || 'fetch_user_substitions';
begin
  ks_log.log('BEGIN', l_scope);

  select  u.id
         ,u.username
         ,u.first_name
         ,u.last_name
         ,u.full_name
         ,u.email
         ,u.active_ind
         ,u.admin_ind
         ,u.external_sys_ref
         ,u.expired_passwd_flag
         ,u.login_attempts
         ,u.last_login_date
  into    p_substrings ('USER_ID')
         ,p_substrings ('USERNAME')
         ,p_substrings ('USER_FIRST_NAME')
         ,p_substrings ('USER_LAST_NAME')
         ,p_substrings ('USER_FULL_NAME')
         ,p_substrings ('USER_EMAIL')
         ,p_substrings ('USER_ACTIVE_IND')
         ,p_substrings ('USER_ADMIN_IND')
         ,p_substrings ('USER_EXTERNAL_SYS_REF')
         ,p_substrings ('USER_EXPIRED_PASSWD_FLAG')
         ,p_substrings ('USER_LOGIN_ATTEMPTS')
         ,p_substrings ('USER_LAST_LOGIN_DATE')
  from    ks_users_v u
  where   u.id = p_id;

  ks_log.log('END', l_scope);
  
end fetch_user_substitions;



/**
 * Get ready all the parameters to notify by email.
 * If the procedure receives a template name the p_body and p_body_html are ignored and only the template is used.
 * The p_substrings values will be used to merge with the template.
 * Leave p_template_name empty to use the p_body and p_body_html parameters.
 * If p_to, p_cc and p_bcc are null, the procedure exists.
 *
 *
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
  l_body_html clob;
begin
  ks_log.log('BEGIN', l_scope);

  if trim (p_to) is null 
      and trim (p_cc) is null
      and trim (p_bcc) is null then 
    return;
  end if;

  if p_template_name is not null then 
    l_body := replace_substr_template (
      p_template_name => p_template_name
     ,p_substrings => p_substrings
    );

    l_body_html := replace (l_body, chr(10), '<br>');
  else 
    l_body := p_body;
    l_body_html := p_body_html;
  end if;

  ks_email_api.send (
     p_to => p_to
    ,p_cc => p_cc
    ,p_bcc => p_bcc
    ,p_from => p_from
    ,p_replyto => null
    ,p_subj => p_subject
    ,p_body => l_body
    ,p_body_html => l_body_html
  );

  ks_log.log('END', l_scope);
exception
  when OTHERS then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end send_email;




/**
 * 
 * Notify users of newly loaded sessions. The loaded sessions are found in `ks_session_load_coll_v`
 * Only the users for the tracks marked during the Load Session Wizard (`ks_session_load_coll_v.notify_ind`) will be notified.
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/08/2019
 * @param p_notify_owner Notify "Track Owners", ie Track Leads (OWNER) and Track Observers (VIEWER). Those where `selection_role_code is not null`
 * @param p_notify_voter Notify "Voters": those where `voting_role_code is not null`
 */
procedure notify_track_session_load (
    p_notify_owner in varchar2
  , p_notify_voter in varchar2
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'notify_track_session_load';

  l_substrings t_WordList;
  l_from ks_parameters.value%type;
  l_subject ks_parameters.value%type;
  l_template_name ks_parameters.value%type;
  l_voting_app_link ks_parameters.value%type;
  l_admin_app_link ks_parameters.value%type;
begin
  ks_log.log('START', l_scope);

  l_from := ks_util.get_param('EMAIL_FROM_ADDRESS');
  l_template_name := ks_util.get_param('LOAD_NOTIFICATION_TEMPLATE');
  l_voting_app_link := ks_util.get_param('SERVER_URL') || ks_util.get_param('VOTING_APP_ID');
  l_admin_app_link := ks_util.get_param('SERVER_URL') || ks_util.get_param('ADMIN_APP_ID');

  l_substrings('VOTING_APP_LINK') := l_voting_app_link;
  l_substrings('ADMIN_APP_LINK') := l_admin_app_link;

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

    l_subject := ' New sessions for: ' || rec.track_name;

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



/**
 * 
 * Send a notification of type Password Reset Request 
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/08/2019
 * @param p_username
 * @param p_password
 * @param p_app_id
 */
procedure notify_reset_pwd_request (
    p_id in ks_users.id%type
   ,p_password in ks_users.password%type
   ,p_app_id in ks_parameters.value%type
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'notify_reset_pwd_request';

  c_subject_notification constant varchar2(30) := 'Reset Password Request';

  l_substrings t_WordList;
  l_from ks_parameters.value%type;
  l_subject ks_parameters.value%type;
  l_template_name ks_parameters.value%type;
  l_admin_app_link ks_parameters.value%type;
  l_voting_app_link ks_parameters.value%type;
begin
  ks_log.log('START', l_scope);

  l_from := ks_util.get_param('EMAIL_FROM_ADDRESS');
  l_template_name := ks_util.get_param('RESET_PASSWORD_REQUEST_NOTIFICATION_TEMPLATE');
  l_admin_app_link := ks_util.get_param('SERVER_URL') || ks_util.get_param('ADMIN_APP_ID');
  l_voting_app_link := ks_util.get_param('SERVER_URL') || ks_util.get_param('VOTING_APP_ID');

  fetch_user_substitions (
    p_id => p_id
   ,p_substrings => l_substrings
  );
  
  l_substrings('ADMIN_APP_LINK') := l_admin_app_link;
  l_substrings('VOTING_APP_LINK') := l_voting_app_link;
  l_substrings('TEMP_PASSWORD') := p_password;

  l_subject := c_subject_notification;

  send_email (
     p_to => l_substrings('USER_EMAIL')
    ,p_from => l_from
    ,p_cc => null
    ,p_bcc => null
    ,p_subject => l_subject 
    ,p_body => null
    ,p_body_html => null
    ,p_template_name =>  l_template_name
    ,p_substrings => l_substrings
  );

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end notify_reset_pwd_request;



/**
 * 
 * Send a notification of type Password Reset Done to the user
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/13/2019
 * @param p_username
 */
procedure notify_reset_pwd_done (
    p_id in ks_users.id%type
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'notify_reset_pwd_done';

  c_subject_notification constant varchar2(30) := 'Reset Password Done';

  l_substrings t_WordList;
  l_from ks_parameters.value%type;
  l_subject ks_parameters.value%type;
  l_template_name ks_parameters.value%type;
begin
  ks_log.log('START', l_scope);

  l_from := ks_util.get_param('EMAIL_FROM_ADDRESS');
  l_template_name := ks_util.get_param('RESET_PASSWORD_DONE_NOTIFICATION_TEMPLATE');
  l_subject := c_subject_notification;

  fetch_user_substitions (
    p_id => p_id
   ,p_substrings => l_substrings
  );

  send_email (
     p_to => l_substrings('USER_EMAIL')
    ,p_from => l_from
    ,p_cc => null
    ,p_bcc => null
    ,p_subject => l_subject 
    ,p_body => null
    ,p_body_html => null
    ,p_template_name =>  l_template_name
    ,p_substrings => l_substrings
  );

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end notify_reset_pwd_done;

end ks_notification_api;
/