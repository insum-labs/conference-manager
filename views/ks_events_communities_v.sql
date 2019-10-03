create or replace force editionable view ks_events_communities_v
as
  select e.id event_id
       , c.id event_community_id
       , c.name community_name
       , c.active_ind community_active_ind
       , e.name event_name
       , e.begin_date begin_date
       , e.active_ind event_active_ind
       , (
           select listagg( t.name, ', ') within group (order by t.display_seq)
             from ks_event_community_tracks ct join ks_event_tracks t on (ct.track_id = t.id and t.event_id = e.id)
            where ct.community_id =  c.id
         ) track_list
  from ks_events e
  join ks_event_communities c on ( c.event_id = e.id);
