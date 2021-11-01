select full_name || ' (' || username || ')' d, username r 
from ks_users_v 
where username not in (
  select a.username from ks_event_admins a where a.event_id = :P5025_ID
)