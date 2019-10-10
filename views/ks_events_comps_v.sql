PRO ks_events_comps_v
create or replace view ks_events_comps_v as
  select  s.event_id
        , s.event_track_id
        , s.presenter_user_id
        , ks_session_api.get_presenter_comp(s.event_id, s.event_track_id , s.presenter_user_id) as presenter_comp
     from ks_sessions s
    where s.status_code = 'ACCEPTED'
  group by s.event_id, s.event_track_id, s.presenter_user_id
  order by s.event_id, s.event_track_id, s.presenter_user_id
  /