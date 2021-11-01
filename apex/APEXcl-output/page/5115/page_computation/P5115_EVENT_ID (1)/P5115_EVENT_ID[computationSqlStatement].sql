select et.event_id
  from ks_event_tracks et
 where et.id = to_number(:P5115_TRACK_ID)
union all
select to_number(:P5110_EVENT_ID)
  from dual
 where :P5115_TRACK_ID is null