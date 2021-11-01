select u.full_name
     , v.vote
     , decode(v.decline_vote_flag, 'Y', apex_lang.message('DECLINED_VOTE') ||  v.comments, v.comments) comments
 from ks_session_votes v
    , ks_users_v u
where v.session_id = to_number(:P3_ID)
  and v.username = u.username
  and (v.vote is not null or v.decline_vote_flag is not null)
  and v.vote_type = 'COMMITTEE'
