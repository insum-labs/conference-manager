select nvl(alias, name) as d,
       id as r
  from ks_events_sec_v
 where active_ind = 'Y'
 order by begin_date desc