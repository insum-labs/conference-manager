select max_sessions
     , max_comps
     , nvl(alias, name)
from ks_event_tracks
where id = to_number(:P1_TRACK_ID);