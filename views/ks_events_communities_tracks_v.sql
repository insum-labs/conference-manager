PRO ks_events_communities_tracks_v
create or replace force editionable view ks_events_communities_tracks_v
as
  select e.id event_id
       , c.id event_community_id
       , c.name community_name
       , e.name event_name
       , e.begin_date begin_date
       , e.active_ind event_active_ind
       , ct.id community_track_id
       , ct.track_id
       , et.display_seq track_display_seq
       , et.name track_name
       , et.alias track_alias
       , et.active_ind track_active_ind
       , et.max_sessions
       , et.max_comps
  from ks_events e
  join ks_event_communities c on ( c.event_id = e.id)
  join ks_event_community_tracks ct on (c.id = ct.community_id)
  join ks_event_tracks et on (ct.track_id = et.id)
/
