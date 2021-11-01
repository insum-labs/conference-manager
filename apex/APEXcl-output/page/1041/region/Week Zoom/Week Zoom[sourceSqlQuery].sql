select  trunc(submission_date) submission_date
      , count(*) sessions
from ks_sessions
where event_id = :P1041_EVENT_ID
  and to_char(submission_date, 'YYYY') = :P1041_YEAR
  and to_char(submission_date, 'IW') = :P1041_WEEK
group by trunc(submission_date)