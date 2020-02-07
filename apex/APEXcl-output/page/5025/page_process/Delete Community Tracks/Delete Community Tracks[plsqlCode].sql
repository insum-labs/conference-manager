delete from ks_event_community_tracks
where track_id in (
    select id
      from ks_event_tracks
     where event_id = to_number(:P5025_ID)
);