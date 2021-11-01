select et.event_id
from ks_user_event_track_roles tr
   , ks_event_tracks et
where tr.event_track_id = et.id
  and tr.id = :P5115_ID