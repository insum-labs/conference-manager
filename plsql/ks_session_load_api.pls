create or replace package ks_session_load_api
is

--------------------------------------------------------------------------------
--*
--*
--*
--------------------------------------------------------------------------------

-- CONSTANTS
/**
 * @gc_loaded_session_coll: Name of the collection created during the load session wizard
*/
gc_loaded_session_coll constant varchar2 (30) := 'LOADED_SESSIONS';

--------------------------------------------------------------------------------


procedure load_xlsx_data (
    p_xlsx      in blob
  , p_username  in varchar2 default v('APP_USER')
);

function validate_data(
    p_into_event_id in ks_event_tracks.event_id%TYPE
) return boolean;

procedure load_sessions (
    p_event_id   in ks_events.id%TYPE
  , p_username   in varchar2 default v('APP_USER')
  , x_load_count in out number
);

procedure purge_event(
	p_event_id			in ks_sessions.event_id%TYPE
  , p_track_id			in ks_sessions.event_track_id%TYPE default null
  , p_votes_only_ind	in varchar2
  , p_force_ind			in varchar2
);

procedure create_coll_loaded_session (
    p_event_id   in ks_events.id%TYPE
  , p_username   in varchar2 default v('APP_USER')
);

end ks_session_load_api;
/
