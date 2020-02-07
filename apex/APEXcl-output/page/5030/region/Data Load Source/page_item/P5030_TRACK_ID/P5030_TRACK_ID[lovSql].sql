select nvl(t.alias, t.name) d, t.id
from ks_event_tracks t
where t.event_id = to_number(:P5030_EVENT_ID)
  and (:G_ADMIN = 'YES' or t.owner = :APP_USER)
  and t.active_ind = 'Y'
order by t.display_seq