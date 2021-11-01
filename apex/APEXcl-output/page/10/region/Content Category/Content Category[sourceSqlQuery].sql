select s.sub_category, count(*) totals
  from ks_sessions s
 where s.status_code = 'ACCEPTED'
   and s.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
group by s.sub_category
