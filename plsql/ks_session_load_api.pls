create or replace package ks_session_load_api
is

--------------------------------------------------------------------------------
--*
--* 
--*
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
procedure load_sessions(
    p_app_user       in ks_users.username%TYPE
  , p_into_event_id  in ks_event_tracks.event_id%TYPE
  , p_into_track_id  in ks_event_tracks.id%TYPE);


end ks_session_load_api;
/
