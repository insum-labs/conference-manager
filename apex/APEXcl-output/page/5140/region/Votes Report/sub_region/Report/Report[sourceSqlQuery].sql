select s.external_sys_ref
, s.session_num
, u.external_sys_ref "UID"
, u.full_name voter
, s.title
, v.vote_type
, v.vote
, v.decline_vote_flag
, v.comments
from ks_users_v u
, ks_session_votes v
, ks_sessions s
where u.username = v.username
and v.session_id = s.id
and (v.vote is not null or v.decline_vote_flag is not null)
and s.event_id = :P5140_EVENT_ID;