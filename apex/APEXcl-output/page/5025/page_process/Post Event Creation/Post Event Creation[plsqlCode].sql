declare
 l_current_event_id   ks_events.id%type := to_number(:P5025_ID);
 l_current_event_type ks_events.event_type%type := :P5025_EVENT_TYPE;
begin
 if :P5025_SEED_TRACKS = 'Y' then
   insert into ks_event_tracks (event_id, display_seq, name, alias, active_ind)
     select l_current_event_id, t.display_seq, t.name, t.alias, t.active_ind
       from ks_tracks t
      where t.active_ind = 'Y';
 end if;
 
 if :P5025_COPY_COMMUNITIES = 'Y' then
  insert into ks_event_communities (event_id, name)
   select l_current_event_id event_id, c.name name
     from ks_events e join ks_event_communities c on (e.id = c.event_id)
    where e.begin_date = (select max(ee.begin_date) 
                            from ks_events ee 
                           where ee.id not in (l_current_event_id)
                             and ee.event_type in (l_current_event_type));
 end if;
 
 if :P5025_COPY_TAGS = 'Y' then
  -- need to implement
  null;
 end if;
end; 