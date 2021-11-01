select count(1)
    from ks_session_votes
where username = :P5120_USERNAME
    and session_id in (
        select id
            from ks_sessions
        where event_id = :P5120_EVENT_ID
            and event_track_id = :P5120_TRACK_ID
        )