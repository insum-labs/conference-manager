select 1
from ks_users
where username = :APP_USER
  and active_ind = 'Y'
  and admin_ind = 'Y'
