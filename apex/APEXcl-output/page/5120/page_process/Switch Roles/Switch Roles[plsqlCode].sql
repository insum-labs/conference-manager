declare
begin
   ks_session_api.switch_votes
        (p_event_id => :P5120_EVENT_ID
       , p_track_id => :P5120_TRACK_ID
       , p_username => :P5120_USERNAME
       , p_voting_role => :P5120_VOTING_ROLE);
end;