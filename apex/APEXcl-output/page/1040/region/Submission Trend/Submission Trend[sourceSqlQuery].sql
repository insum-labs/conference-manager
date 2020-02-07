select  to_char(submission_date, 'YYYY') submission_year
      , to_char(submission_date, 'IW') submission_week
      , 'Week: ' || to_char(submission_date, 'YYYY') || to_char(submission_date, 'IW') submission_date
      , count(*) sessions
from ks_sessions
where event_id = :P1040_EVENT_ID
group by to_char(submission_date, 'YYYY') 
      , to_char(submission_date, 'IW') 
      , 'Week: ' || to_char(submission_date, 'YYYY') || to_char(submission_date, 'IW')

