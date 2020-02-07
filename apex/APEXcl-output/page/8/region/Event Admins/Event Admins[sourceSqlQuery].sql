SELECT --e.username,
      -- u.first_name,
      -- u.last_name,
       listagg (u.full_name, ', ') within group (order by e.username)  event_admins
      -- u.email
from ks_event_admins e
    join ks_users_v u on (e.username = u.username)  
where e.event_id = :P1_EVENT_ID
