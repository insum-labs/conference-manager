with session_counts_records as (
 select  s.event_id
       , s.event_track_id
       , count(*) loaded_sessions
       , count(distinct s.presenter_user_id) speakers
       , sum(decode(s.status_code, 'ACCEPTED', 1, 0)) accepted_sessions
       , (select count(distinct ss.presenter_user_id) from ks_sessions ss where ss.event_track_id = s.event_track_id and ss.status_code = 'ACCEPTED') as accepted_speakers
       , sum(decode(s.status_code, null, 1, 0)) sessions_no_status
    from ks_sessions s
   where s.event_id = :P1_SELECT_EVENT_ID
   group by s.event_id, s.event_track_id
)
, event_comps as (
  select c.event_track_id
       , sum(c.presenter_comp) comps_speakers
    from ks_events_comps_v c 
   where c.event_id = to_number(:P1_SELECT_EVENT_ID)
   group by c.event_track_id
)
select /*+ qb_name (community) */ 
        null as view_btn
      , '' hide_class
      , 'showTracks' link_class
      , ctv.event_community_id id
      , ctv.community_name
      , sum (ctv.max_sessions) max_sessions
      , sum (ctv.max_comps) max_comps
      , sum (scr.loaded_sessions) loaded_sessions
      , (select count(distinct ss.presenter_user_id) 
           from ks_sessions ss join ks_event_tracks t on (t.id = ss.event_track_id) 
          where ss.event_id = to_number (:P1_SELECT_EVENT_ID)
            and ss.event_track_id in ( select t.track_id 
                                         from ks_event_community_tracks t
                                        where t.community_id = ctv.event_community_id)
            and t.active_ind = 'Y') speakers
      , sum (scr.accepted_sessions) accepted_sessions
      , (select count(distinct ss.presenter_user_id) 
           from ks_sessions ss join ks_event_tracks t on (t.id = ss.event_track_id) 
          where ss.event_id = to_number (:P1_SELECT_EVENT_ID)
            and ss.event_track_id in ( select t.track_id 
                                         from ks_event_community_tracks t
                                        where t.community_id = ctv.event_community_id)
            and t.active_ind = 'Y'
            and ss.status_code = 'ACCEPTED') accepted_speakers
      
      , sum (scr.sessions_no_status) sessions_no_status
      , sum (c.comps_speakers) comps
  from ks_events_communities_tracks_v ctv
  left outer join session_counts_records scr on (ctv.track_id = scr.event_track_id )
  left outer join event_comps c on (ctv.track_id = c.event_track_id )
 where ctv.event_id = to_number (:P1_SELECT_EVENT_ID)
   and ctv.track_active_ind = 'Y'
 group by ctv.event_community_id, ctv.community_name
 union all
  select /*+ qb_name (single_tracks) */ 
        null as view_btn
      , 'disabled hide' hide_class
      , 'redirectToSessions' link_class
      , t.id
      , nvl(t.alias, t.name) as community_name
      , t.max_sessions as max_sessions
      , t.max_comps as max_comps
      , scr.loaded_sessions loaded_sessions
      , scr.speakers speakers
      , scr.accepted_sessions accepted_sessions
      , scr.accepted_speakers accepted_speakers
      , scr.sessions_no_status sessions_no_status
      , c.comps_speakers comps
  from session_counts_records scr 
  right outer join ks_event_tracks t on (t.id = scr.event_track_id)
  left outer join event_comps c on (t.id = c.event_track_id) 
 where t.event_id = to_number(:P1_SELECT_EVENT_ID)
   and t.active_ind = 'Y'
   and not exists ( select 1 
                      from ks_event_community_tracks ct
                     where ct.track_id = t.id )
order by hide_class nulls first, community_name