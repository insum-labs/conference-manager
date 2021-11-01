declare 
 l_total_available number(3);
 l_current_assigned number(3);
 l_community_id number(32) :=  to_number (:P5165_COMMUNITY_ID);
 l_event_id number(32) :=  to_number (:P5165_EVENT_ID);
begin
 :P5165_DISPLAY_MESSAGE := null;
 select listagg( ct.track_id, ':') within group (order by (select t.display_seq from ks_event_tracks t where t.id = ct.track_id)) into :P5165_TRACK_LIST
   from ks_event_community_tracks ct
  where community_id = l_community_id;
  
 select count(1) into l_current_assigned
   from ks_event_community_tracks
  where community_id = l_community_id;
  
 select count(1) into l_total_available
   from ks_event_tracks t
  where t.event_id =l_event_id
    and not exists ( select 1
                       from ks_event_community_tracks ct
                      where ct.community_id not in (l_community_id )
                        and ct.track_id = t.id );
  if l_current_assigned = 0 and l_total_available = 0
  then
    :P5165_DISPLAY_MESSAGE := 'Y';
  end if;
end;  