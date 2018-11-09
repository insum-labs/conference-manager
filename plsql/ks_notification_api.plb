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

------------------------------------------------------------------------------
/**
 * Description
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 6, 2018
 * @param
 */
procedure email 
is
  l_scope logger_logs.scope%type := gc_scope_prefix || 'email';

begin
  ks_log.log('BEGIN', l_scope);

  --ks_email_api.send

  ks_log.log('END', l_scope);
exception
  when OTHERS then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end email;



/**
 * Description
 * Set the selected tracks to notify
 * on the collectionLOADED_SESSIONS.
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/08/2019
 * @param 
 */
procedure set_tracks_to_notify
is
  l_scope ks_log.scope := gc_scope_prefix || 'set_tracks_to_notify';

  l_loaded_session_coll varchar2(100);
  l_seq number;
begin
  ks_log.log('START', l_scope); 

  l_loaded_session_coll := ks_session_load_api.gc_loaded_session_coll;

  --Update the collection
  for i in 1..apex_application.g_f01.count loop 
    select  c.seq_id
    into    l_seq 
    from    apex_collections c
    where   c.collection_name = l_loaded_session_coll
    and     c.n001 = apex_application.g_f01(i);

    ks_log.log('l_seq:' || l_seq, l_scope);
    
    apex_collection.update_member_attribute  (
       p_collection_name => l_loaded_session_coll
      ,p_seq => l_seq
      ,p_attr_number => 2
      ,p_attr_value   => 'Y'
    );
  end loop;

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end set_tracks_to_notify;



/**
 * Description
 * Notify the users of the tracks marked during the Load Session wizard.
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/08/2019
 * @param 
 */
procedure notify_track_session_load (
  p_notify_to in varchar2
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'notify_track_session_load';

  l_substrings t_WordList;
  l_from ks_parameters.value%type;
  l_subject ks_parameters.value%type;
  l_template_name ks_parameters.value%type;
  l_voting_app_link ks_parameters.value%type;
begin
  ks_log.log('START', l_scope);

  l_from := ks_util.get_param('EMAIL_FROM_ADDRESS');
  l_subject := ks_util.get_param('EMAIL_PREFIX');
  l_template_name := ks_util.get_param('LOAD_NOTIFICATION_TEMPLATE');
  l_voting_app_link := ks_util.get_param('SERVER_URL')
    || ks_util.get_param('VOTING_APP_ID');

  l_substrings('VOTING_APP_LINK') := l_voting_app_link;

  --TODO jwall: review the query with JRimblas
  for rec in (
    select  sl.track_name
           ,sl.session_count
           ,listagg (u.email,',') within group (order by u.email desc) as email
    from    ks_user_event_track_roles uetr
    join    ks_users u 
    on      uetr.username = u.username
    join    ks_session_load_coll_v sl 
    on      sl.track_id = uetr.event_track_id
    where   sl.notify_ind = 'Y'
    and     (
      ('OWNER' = p_notify_to 
        and uetr.selection_role_code is not null
        and uetr.voting_role_code = 'COMMITTEE')
      or
      ('VOTER' = p_notify_to 
        and uetr.selection_role_code is not null
        and uetr.voting_role_code in ('COMMITTEE', 'BLIND'))
    )
    group   by sl.track_name
           ,sl.session_count
  )
  loop
    ks_log.log (rec.track_name || '-' || rec.session_count || '-' || rec.email, l_scope);
    
    l_substrings('SESSION_COUNT') := rec.session_count;
    l_substrings('TRACK_NAME') := rec.track_name;

    --TODO jwall: define the subject, should it contain the track name?
    l_subject := l_subject || '';

    --TODO jwall: call email
    --TODO jwall: if p_template_name is not null then calculate the body & body htmnl
    -- email (
    --    p_to => null
    --   ,p_from => l_from
    --   ,p_cc => null
    --   ,p_bcc => rec.email
    --   ,p_subject => l_subject 
    --   ,p_body => null
    --   ,p_body_html => null
    --   ,p_template_name =>  l_template_name
    --   ,p_substrings => l_substrings
    -- );
  end loop;

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end notify_track_session_load;

end ks_notification_api;
/