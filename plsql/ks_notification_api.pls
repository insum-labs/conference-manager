create or replace package ks_notification_api
is

-- TYPES
type t_WordList is table of varchar2(32000) index by varchar(30);


-- CONSTANTS

------------------------------------------------------------------------------
procedure send_email;

procedure notify_track_session_load (    
    p_notify_owner in varchar2
  , p_notify_voter in varchar2
);

end ks_notification_api;
/