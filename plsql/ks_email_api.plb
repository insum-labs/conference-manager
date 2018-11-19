create or replace package body ks_email_api
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
gc_email_override_key constant ks_parameters.name_key%type := 'EMAIL_OVERRIDE';

------------------------------------------------------------------------------
/**
 *      Send an email to the original email accounts or 
 *      to the ones specified on email_override on the table ks_parameters.
 *      The parameter "EMAIL_PREFIX" is added to the subject.
 *      If p_to, p_cc and p_bcc are null, the procedure exists.
 * @example
 *
 * @issue
 *
 * @author Juan Wall
 * @created November 6, 2018
 * @param
 *  p_to
 *  p_from
 *  p_replyto
 *  p_subj
 *  p_body
 *  p_body_html 
 */
procedure send (
     p_to in varchar2
    ,p_cc in varchar2 default null
    ,p_bcc in varchar2 default null
    ,p_from in varchar2 default null
    ,p_replyto in varchar2 default null
    ,p_subj in varchar2
    ,p_body in clob
    ,p_body_html in clob
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'send';
  
  c_original_emails_notification constant varchar2(100) := 'This email was originally sent as follows ';

  l_email_override ks_parameters.value%type;
  l_to varchar2(4000);
  l_cc varchar2(4000);
  l_bcc varchar2(4000);
  l_body clob;
  l_body_html clob;
  l_subject_prefix ks_parameters.value%type;
  l_subject varchar2(4000);
begin
  ks_log.log('BEGIN', l_scope);

  if trim (p_to) is null 
      and trim (p_cc) is null
      and trim (p_bcc) is null then 
    return;
  end if;

  l_email_override := ks_util.get_param (p_name_key => gc_email_override_key);
  l_subject_prefix := ks_util.get_param ('EMAIL_PREFIX');
  l_subject := l_subject_prefix || p_subj;

  if l_email_override is not null then 
    l_to := l_email_override;
    l_cc := null;
    l_bcc := null;
    l_body :=  c_original_emails_notification || chr(10) || chr(13) 
      || 'TO: ' || nvl (p_to, '-') || chr(10) || chr(13) 
      || 'CC: ' || nvl (p_cc, '-') || chr(10) || chr(13) 
      || 'BCC: ' || nvl (p_bcc, '-') || chr(10) || chr(13) 
      || p_body;
    l_body_html := '<p>' || c_original_emails_notification || '<br>'
      || 'TO: ' || nvl (p_to, '-') || '<br>'
      || 'CC: ' || nvl (p_cc, '-') || '<br>'
      || 'BCC: ' || nvl (p_bcc, '-') || '</p>'
      || '<hr>'
      || p_body_html;
  else 
    l_to := p_to;
    l_cc := p_cc;
    l_bcc := p_bcc;
    l_body := p_body;
    l_body_html := p_body_html;
  end if;

  ks_log.log ('l_to: ' || l_to, l_scope);
  ks_log.log ('p_from: ' || p_from, l_scope);
  ks_log.log ('l_body: ' || l_body, l_scope);
  ks_log.log ('l_body_html: ' || l_body_html, l_scope);
  ks_log.log ('l_subject: ' || l_subject, l_scope);
  ks_log.log ('l_cc: ' || l_cc, l_scope);
  ks_log.log ('l_bcc: ' || l_bcc, l_scope);
  ks_log.log ('p_replyto: ' || p_replyto, l_scope);

  apex_mail.send (
     p_to => l_to
    ,p_from => p_from
    ,p_body => l_body
    ,p_body_html => l_body_html
    ,p_subj => l_subject
    ,p_cc => l_cc
    ,p_bcc => l_bcc
    ,p_replyto => p_replyto
  );

  ks_log.log('END', l_scope);
exception
  when OTHERS then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end send;

end ks_email_api;
/