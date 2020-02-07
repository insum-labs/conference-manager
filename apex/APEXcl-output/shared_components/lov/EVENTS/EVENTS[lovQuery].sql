select nvl(alias, name) as d,
       id as r
  from ks_events
 where active_ind = 'Y'
 order by begin_date desc