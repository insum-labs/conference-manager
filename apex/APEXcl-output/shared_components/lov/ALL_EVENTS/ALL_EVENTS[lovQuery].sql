select nvl(alias, name) as d,
       id as r
  from ks_events
 order by begin_date desc