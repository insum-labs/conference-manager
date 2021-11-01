with presenters as (
  select distinct s.presenter_user_id, min(s.presenter) presenter
    from ks_sessions s
       , ks_events_sec_v e
   where e.id = s.event_id
     and s.event_id = :P1030_EVENT_ID
  group by s.presenter_user_id
)
, multiple_session as (
  select presenter_user_id, count(*) sessions
    from ks_sessions s
   where event_id = :P1030_EVENT_ID
  having count(*) > :P1030_COUNT
  group by presenter_user_id
)
select p.presenter_user_id id, p.presenter, s.sessions
  from presenters p
     , multiple_session s
 where p.presenter_user_id = s.presenter_user_id