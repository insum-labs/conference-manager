select nvl(t.alias, t.name) d, t.id
from ks_event_tracks t
   , ks_events_allowed_v e
where e.id = t.event_id
  and t.event_id = to_number(:P1_SELECT_EVENT_ID)
  and ((:G_ADMIN = 'YES')
   or exists (select 1
                from ks_user_event_track_roles ut
               where ut.event_track_id = t.id 
                 and ut.selection_role_code is not null
                 and ut.username = :APP_USER)
    or exists (select 1 
                 from ks_event_admins a
                where a.username = :APP_USER
                  and event_id = :P1_SELECT_EVENT_ID)
   )
  and t.active_ind = 'Y'
order by t.display_seq