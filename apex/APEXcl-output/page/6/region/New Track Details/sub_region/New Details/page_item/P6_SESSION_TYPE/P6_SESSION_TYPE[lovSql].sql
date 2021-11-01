select distinct session_type d, session_type r
from ks_sessions
where event_id = :P6_EVENT_ID
  and event_track_id = :P6_EVENT_TRACK_ID
union
select session_type d, session_type r
from ks_sessions
where id = :P6_ID
order by 1