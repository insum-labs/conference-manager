select 1
from ks_users
where username = :APP_USER
  and admin_ind = 'Y'
union
select 1
  from ks_user_event_track_roles
 where username = :APP_USER
   and selection_role_code is not null
union
select 1
  from ks_event_admins
 where username = :APP_USER