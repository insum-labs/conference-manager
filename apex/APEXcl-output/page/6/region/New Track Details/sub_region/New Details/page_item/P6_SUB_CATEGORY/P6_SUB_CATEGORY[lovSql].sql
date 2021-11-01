select distinct sub_category d, sub_category r
from ks_sessions
where event_id = :P6_EVENT_ID
  and event_track_id = :P6_EVENT_TRACK_ID
order by 1