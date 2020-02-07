select count(*)
  from ks_sessions 
 where event_track_id = to_number(:P5026_ID)