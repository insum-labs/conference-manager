declare
 l_event_id ks_events.id%type := to_number (:P6_EVENT_ID);
begin
 :P6_OLD_EVENT_TRACK_ID := :P6_EVENT_TRACK_ID;
 
 --By default, Track Owners chekboc is checked.
 :P6_NOTIFY_OWNERS_IND := 'Y';
 
 --If we are in the voting window, then All voters checkbox is also checked.
 begin
   select 'Y' into :P6_NOTIFY_VOTERS_IND
     from ks_events
    where id = l_event_id
      and trunc(committee_vote_begin_date) <= trunc(sysdate) 
      and trunc(sysdate) <= trunc (committee_vote_end_date);
 exception 
   when no_data_found then 
     :P6_NOTIFY_VOTERS_IND := null;     
 end;    
end; 