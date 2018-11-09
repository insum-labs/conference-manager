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
 * Description
 *      Send an email to the original email accounts or 
 *      to the ones specified on email_override on the table ks_parameters.
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
    ,p_from in varchar2
    ,p_replyto in varchar2 default null
    ,p_subj in varchar2
    ,p_body in clob
    ,p_body_html in clob default null
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'send';
  
  c_original_emails_notification constant varchar2(100) := 'This email was originally sent to ';

  l_email_override ks_parameters.value%type;
  l_to varchar2(4000);
  l_body clob;
  l_body_html clob;
begin
  ks_log.log('BEGIN', l_scope);

  l_email_override := ks_util.get_param (p_name_key => gc_email_override_key);

  if l_email_override is not null then 
    l_to := l_email_override;
    l_body :=  c_original_emails_notification || p_to || chr(10) || chr(13) || p_body;
    l_body_html := '<p>' || c_original_emails_notification || p_to || '<br></p>' || p_body_html;
  else 
    l_to := p_to;
    l_body := p_body;
    l_body_html := p_body_html;
  end if;

  apex_mail.send (
     p_to => l_to
    ,p_from => p_from
    ,p_replyto => p_replyto
    ,p_subj => p_subj
    ,p_body => l_body
    ,p_body_html => l_body_html
  );

  ks_log.log('END', l_scope);
exception
  when OTHERS then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end send;

end ks_email_api;
/