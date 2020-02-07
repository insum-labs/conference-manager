select  cv.event_id
      , cv.event_community_id
      , cv.community_name
      , nvl(cv.track_list, 'Add Track(s)') as tracks
  from ks_events_communities_v cv
 where cv.event_id = to_number(:P5025_ID);