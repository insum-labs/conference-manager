select count(*)
from ks_sessions
where event_id = to_number(:P1_EVENT_ID)
  and presenter_user_id = :P3_PRESENTER_USER_ID
  and event_track_id <> to_number(:P3_EVENT_TRACK_ID)