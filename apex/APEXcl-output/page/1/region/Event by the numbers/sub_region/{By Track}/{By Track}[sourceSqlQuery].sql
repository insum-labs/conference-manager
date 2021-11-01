with session_counts as (
  select s.event_track_id
       , count(*) sessions_loaded
       , sum(decode(s.status_code, 'ACCEPTED', 1, 0)) sessions_accepted
       , sum(decode(s.status_code, null, 1, 0)) sessions_no_status 
  from ks_sessions s
 where s.event_id = to_number(:P1_SELECT_EVENT_ID)
 group by s.event_id, s.event_track_id
)
, event_comps as (
  select c.event_track_id
       , sum(c.presenter_comp) comps
    from ks_events_comps_v c 
   where c.event_id = to_number(:P1_SELECT_EVENT_ID)
   group by c.event_track_id
)
select et.id
     , et.event_id
     , et.display_seq
     , nvl(et.alias, et.name) track_name
     , (select listagg(u.full_name, ', ') within group (order by u.full_name)
          from ks_user_event_track_roles uetr
             , ks_users_v u
      where u.username = uetr.username
        and uetr.selection_role_code = 'OWNER'
        and uetr.event_track_id = et.id
       ) owner
     , et.max_sessions
     , et.max_comps
     , s.sessions_loaded
     , (select count(distinct ss.presenter) from ks_sessions ss where ss.event_track_id = et.id) all_speakers
     , s.sessions_accepted
     , (select count(distinct ss.presenter) from ks_sessions ss where ss.event_track_id = et.id and ss.status_code = 'ACCEPTED') accepted_speakers
     , c.comps
     , sessions_no_status
 from ks_event_tracks et
    , session_counts s
    , event_comps c
where et.event_id = to_number(:P1_SELECT_EVENT_ID) 
  and et.id = s.event_track_id
  and et.id = c.event_track_id (+)
  and (
      (:G_ADMIN = 'YES')
   or exists (select 1
                from ks_user_event_track_roles ut
               where ut.event_track_id = et.id 
                 and ut.selection_role_code is not null
                 and ut.username = :APP_USER
                 and :P1_SELECT_EVENT_ID is not null
             )
   or exists (select 1
                from ks_event_admins a
               where a.username = :APP_USER
                 and :P1_SELECT_EVENT_ID is not null
             )
   )
  and et.active_ind = 'Y'
