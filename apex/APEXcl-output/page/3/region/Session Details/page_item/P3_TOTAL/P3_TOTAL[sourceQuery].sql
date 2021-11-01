select sum(d.vote)
    from ks_session_votes d 
where d.session_id= to_number(:P3_ID)
    and d.vote_type = 'COMMITTEE'