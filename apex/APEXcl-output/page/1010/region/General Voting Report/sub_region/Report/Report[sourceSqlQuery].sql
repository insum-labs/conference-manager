select d.id session_vote_id
	 , c.id session_id
     , c.session_num
	 , a.name event
	 , b.name track
	 , u.full_name voter
	 , u.external_sys_ref
	 , c.sub_category
	 , c.session_type
	 , c.title
	 , c.presenter
	 , c.company
	 , c.co_presenter
	 , d.vote_type
	 , d.vote
     , d.decline_vote_flag
--     , d.comments
     , decode(d.decline_vote_flag, 'Y', apex_lang.message('DECLINED_VOTE') || d.comments, d.comments) comments
     , d.created_on vote_created_on
     , d.updated_on vote_updated_on
from ks_events_allowed_v e,
    ks_events a,
	ks_event_tracks b,
	ks_sessions c,
	ks_session_votes d,
	ks_users_v u
where e.id = a.id
    and a.id = b.event_id
	and a.id = c.event_id
	and b.id = c.event_track_id
	and c.id = d.session_id
	and b.active_ind = 'Y'
	and u.active_ind = 'Y'
    -- all lines and let the report filter
	-- and d.vote is not null
	and d.username = u.username
    and a.id = :P1010_SELECT_EVENT_ID