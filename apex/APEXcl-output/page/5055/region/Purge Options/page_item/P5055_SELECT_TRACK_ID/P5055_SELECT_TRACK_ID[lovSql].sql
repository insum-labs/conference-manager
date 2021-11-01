select nvl(t.alias, t.name) d, t.id
from ks_event_tracks t
where t.event_id = to_number(:P5055_SELECT_EVENT_ID)
  and t.active_ind = 'Y'
order by t.display_seq