select first_name || nvl2(last_name, ' ' || last_name, '') as d,
       username as r
  from ks_users
where active_ind = 'Y'
 order by 1