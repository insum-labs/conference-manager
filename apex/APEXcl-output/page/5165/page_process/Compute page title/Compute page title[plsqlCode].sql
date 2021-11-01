begin
  select concat ('Add Tracks for ', name) into :P5165_PAGE_TITLE
    from ks_event_communities
   where id = to_number(:P5165_COMMUNITY_ID);

  exception 
    when others then
     :P5165_PAGE_TITLE:= 'Add Tracks';
 end;