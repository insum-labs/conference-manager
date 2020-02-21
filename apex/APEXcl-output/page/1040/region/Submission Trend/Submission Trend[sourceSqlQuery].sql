select  to_char(s.submission_date, 'YYYY') submission_year
      , to_char(s.submission_date, 'IW') submission_week
      , 'Week: ' || to_char(s.submission_date, 'YYYY') || to_char(s.submission_date, 'IW') submission_date
      , count(*) sessions
  from ks_events_allowed_v e
     , ks_sessions s
where e.id = s.event_id
  and s.event_id = :P1040_EVENT_ID
group by to_char(s.submission_date, 'YYYY') 
      , to_char(s.submission_date, 'IW') 
      , 'Week: ' || to_char(s.submission_date, 'YYYY') || to_char(s.submission_date, 'IW')

