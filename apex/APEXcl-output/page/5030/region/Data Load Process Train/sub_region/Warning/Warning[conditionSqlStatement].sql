select 1
from ks_sessions
where event_id = to_number(:P5030_EVENT_ID)
  and event_track_id = to_number(:P5030_TRACK_ID)