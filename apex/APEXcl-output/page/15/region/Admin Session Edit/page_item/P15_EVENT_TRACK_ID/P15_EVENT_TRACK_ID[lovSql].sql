select track_name d, event_track_id
from ks_events_tracks_v
where event_id = :P15_EVENT_ID
order by 1