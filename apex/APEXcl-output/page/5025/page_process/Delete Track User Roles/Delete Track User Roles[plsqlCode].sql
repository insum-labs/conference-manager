delete from ks_user_event_track_roles
where event_track_id in (
    select id
      from ks_event_tracks
     where event_id = to_number(:P5025_ID)
);