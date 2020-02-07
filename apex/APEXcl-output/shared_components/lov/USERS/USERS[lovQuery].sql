select full_name || nvl2(first_name || last_name, ' (','') || username || nvl2(first_name || last_name, ')','') as d,
       username as r
  from ks_users_v
where active_ind = 'Y'
 order by 1