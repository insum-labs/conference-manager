delete 
 from ks_session_votes 
where session_id in (select id from ks_sessions where event_track_id = to_number(:P5026_ID));
delete from ks_sessions where event_track_id = to_number(:P5026_ID);