create or replace package ks_notification_api
is

-- TYPES
type t_WordList is table of varchar2(32000) index by varchar(30);


-- CONSTANTS
/**
 * @constant gc_scope_prefix Standard logger package name
 */
gc_template_load_notif constant ks_parameters.name_key%type := 'LOAD_NOTIFICATION_TEMPLATE';
g_blank_sub_strings t_WordList; -- Leave blank

------------------------------------------------------------------------------
procedure email;

procedure set_tracks_to_notify;

procedure notify_track_session_load (p_notify_to in varchar2);

end ks_notification_api;
/