select et.id,
       '' VIEW_BTN, 
       et.name track,
       (select count(1)
        from ks_user_event_track_roles uetr
        where uetr.event_track_id = et.id) as Users,
        '' ADD_BTN
from ks_event_tracks et
where event_id = :P5110_EVENT_ID