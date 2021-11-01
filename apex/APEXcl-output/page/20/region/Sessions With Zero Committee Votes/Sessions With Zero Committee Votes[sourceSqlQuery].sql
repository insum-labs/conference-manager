select ks.id
     , ks.title 
  from ks_sessions ks 
 where ks.id not in 
   (select s.id session_id
      from ks_sessions s
         , ks_session_votes kv
     where kv.session_id = s.id
       and kv.vote_type = 'COMMITTEE'
       and kv.vote is not null
       and s.event_track_id = ks.event_track_id
    )
  and ks.event_track_id = :P1_TRACK_ID;