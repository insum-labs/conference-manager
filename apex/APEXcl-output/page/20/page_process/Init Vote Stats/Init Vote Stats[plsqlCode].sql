declare
    l_tens_column number;
    l_ones_column number;
    l_total_sessions number;
begin
  --The user is most likely logged out, and will already receive an error message(s)
  if :P1_TRACK_ID is null
  then
      return;
  end if;
    
    
  --Calculate Committe vote stats
  select count(*) 
    into l_total_sessions
    from ks_sessions s
   where s.event_track_id = :P1_TRACK_ID;
  
  select count(*) * l_total_sessions
    into :P20_COMMITTEE_VOTE_TOTAL
    from ks_user_event_track_roles r
   where r.event_track_id = :P1_TRACK_ID
     and r.voting_role_code = 'COMMITTEE';
      
    
  select count(*)
    into :P20_COMMITTEE_VOTE_COUNT
    from ks_session_votes v
       , ks_sessions s
   where v.session_id = s.id
     and s.event_track_id = :P1_TRACK_ID
     and v.vote_type = 'COMMITTEE'
     and v.vote is not null;

  :P20_COMMITTEE_COUNT_OF_TOTAL := :P20_COMMITTEE_VOTE_COUNT || ' of ' || :P20_COMMITTEE_VOTE_TOTAL;

  if :P20_COMMITTEE_VOTE_COUNT = :P20_COMMITTEE_VOTE_TOTAL then
    :P20_COMMITTEE_PERCENT_VOTED := 100;
    :P20_COMMITTEE_PERCENT_FULL := 'full';
  else
    :P20_COMMITTEE_PERCENT_FULL := '';
      
    if :P20_COMMITTEE_VOTE_TOTAL = 0 then
      :P20_COMMITTEE_PERCENT_VOTED := 0;
    else
      :P20_COMMITTEE_PERCENT_VOTED := round((:P20_COMMITTEE_VOTE_COUNT * 100) / :P20_COMMITTEE_VOTE_TOTAL,2);
    end if;

  end if;

  --Now give Blind votes the same treatment
  select count(*) * l_total_sessions
    into :P20_BLIND_VOTE_TOTAL
    from ks_user_event_track_roles r
   where r.event_track_id = :P1_TRACK_ID
     and r.voting_role_code = 'BLIND';
     
   
  select count(*)
    into :P20_BLIND_VOTE_COUNT
    from ks_session_votes v
       , ks_sessions s
   where v.session_id = s.id
     and s.event_track_id = :P1_TRACK_ID
     and v.vote_type = 'BLIND'
     and v.vote is not null;

  :P20_BLIND_COUNT_OF_TOTAL := :P20_BLIND_VOTE_COUNT || ' of ' || :P20_BLIND_VOTE_TOTAL;

  if :P20_BLIND_VOTE_COUNT = :P20_COMMITTEE_VOTE_TOTAL then
    :P20_BLIND_PERCENT_VOTED := 100;
    :P20_BLIND_PERCENT_FULL := 'full';
  else
    :P20_BLIND_PERCENT_FULL := '';
     
    if :P20_BLIND_VOTE_TOTAL = 0 then
      :P20_BLIND_PERCENT_VOTED := 0;
    else
      :P20_BLIND_PERCENT_VOTED := round((:P20_BLIND_VOTE_COUNT * 100) / :P20_BLIND_VOTE_TOTAL,2);
    end if;

  end if;
    

end;