select 1
    from ks_session_votes sv,
         ks_sessions s
where sv.username = :P5115_USERNAME
    and s.event_id = :P5115_EVENT_ID
    and s.event_track_id = :P5115_TRACK_ID
    and sv.session_id = s.id