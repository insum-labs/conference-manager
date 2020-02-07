select t.name
     , t.id
 from ks_event_tracks t
where t.event_id = to_number(:P5165_EVENT_ID)
and not exists (
      select 1
        from ks_event_community_tracks ct
       where ct.community_id not in ( to_number (:P5165_COMMUNITY_ID) )
         and ct.track_id = t.id )
order by t.display_seq;