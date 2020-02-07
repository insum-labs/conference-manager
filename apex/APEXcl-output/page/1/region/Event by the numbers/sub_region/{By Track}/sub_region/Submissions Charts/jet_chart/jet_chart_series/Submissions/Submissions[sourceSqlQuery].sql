with session_counts as (
  select s.event_id
       , count(*) sessions_loaded
       , count(distinct s.presenter) all_speakers
       , sum(decode(s.status_code, 'ACCEPTED', 1, 0)) sessions_accepted
  from ks_sessions s
 where s.event_id = to_number(:P1_SELECT_EVENT_ID)
 group by s.event_id
)
select e.name event_name
     , s.sessions_loaded
     , s.all_speakers
     , s.sessions_accepted
     , (select count(distinct ss.presenter) from ks_sessions ss where ss.event_id = e.id and ss.status_code = 'ACCEPTED') speakers_accepted
 from ks_events e
    , session_counts s
where e.id = s.event_id
  and e.id = to_number(:P1_SELECT_EVENT_ID) 
