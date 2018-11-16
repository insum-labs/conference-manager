create or replace package ks_notification_api
is

-- TYPES
type t_WordList is table of varchar2(32000) index by varchar(30);


-- CONSTANTS
g_blank_sub_strings t_WordList; -- Leave blank
------------------------------------------------------------------------------
procedure fetch_user_substitions (
  p_id in ks_users.id%type
 ,p_substrings in out nocopy t_WordList
);

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
);

procedure notify_track_session_load (    
    p_notify_owner in varchar2
  , p_notify_voter in varchar2
);

procedure notify_reset_pwd_request (
    p_id in ks_users.id%type
   ,p_password in ks_users.password%type
   ,p_app_id in ks_parameters.value%type
);

procedure notify_reset_pwd_done (
    p_id in ks_users.id%type
);

end ks_notification_api;
/