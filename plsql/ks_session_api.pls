create or replace package ks_session_api
is

--------------------------------------------------------------------------------
--*
--* 
--*
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
procedure presenter_tracks_json(
    p_event_id  in ks_events.id%TYPE
  , p_presenter in ks_sessions.presenter%TYPE);


end ks_session_api;
/
