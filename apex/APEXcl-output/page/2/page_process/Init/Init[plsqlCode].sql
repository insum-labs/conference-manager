-- If we made it here, the user hopefully found the "view session" botton on the home page
apex_util.set_preference('VIEW_SESSION_BUTTON_USED', 'YES');

-- Default the left sidebar to open or the latest user preference
:P2_BODY_SIDE_STATE := nvl(apex_util.get_preference('BODY_SIDE_STATE'), 'open');


select max_sessions
     , max_comps
  into :P2_MAX_SESSIONS
     , :P2_MAX_COMPS
from ks_event_tracks
where id = to_number(:P1_TRACK_ID);

-- Refresh MV in case it's out of sync
dbms_mview.refresh('KS_SESSION_VOTES_MV');