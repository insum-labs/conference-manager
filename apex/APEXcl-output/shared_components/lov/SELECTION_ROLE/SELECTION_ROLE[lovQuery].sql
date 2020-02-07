select name as d,
       code as r
  from ks_roles
  where role_type = 'SELECTION'
  and active_ind = 'Y'
 order by display_seq asc