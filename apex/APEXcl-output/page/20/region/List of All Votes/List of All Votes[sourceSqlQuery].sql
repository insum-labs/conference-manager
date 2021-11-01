select
    v.id session_vote_id,
    s.id session_id,
    u.full_name voter,
    s.sub_category,
    s.session_type,
    s.title,
    s.presenter,
    s.company,
    s.co_presenter,
    v.vote_type,
    v.vote,
    v.decline_vote_flag,
    v.comments
from
    ks_event_tracks t,
    ks_events e,
    ks_sessions s,
    ks_session_votes v,
    ks_users_v u
where 1=1
    and e.id = t.event_id
    and e.id = s.event_id
    and t.id = s.event_track_id
    and s.id = v.session_id
    and v.username = u.username 
    and t.active_ind = 'Y'
    and e.active_ind = 'Y'
    and s.event_track_id = :P1_TRACK_ID