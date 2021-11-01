select 1
from ks_users
where username = :APP_USER
  and admin_ind = 'Y'
union
select 1
  from ks_user_event_track_roles
 where event_track_id =  to_number(:P1_TRACK_ID)
   and username = :APP_USER
   and selection_role_code = 'OWNER'
union
select 1
  from ks_event_admins
 where event_id = to_number(:P1_EVENT_ID)
   and username = :APP_USER