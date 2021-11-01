declare
 l_id  ks_sessions.id%type := to_number (:P6_ID);
 l_old_event_track_id ks_sessions.event_track_id%type := to_number (:P6_OLD_EVENT_TRACK_ID);
 l_event_track_id ks_sessions.event_track_id%type := to_number (:P6_EVENT_TRACK_ID);
begin
 ks_notification_api.notify_session_move(
       p_id                 => l_id
     , p_event_track_id     => l_event_track_id
     , p_old_event_track_id => l_old_event_track_id  
     , p_notify_owners_ind  => :P6_NOTIFY_OWNERS_IND
     , p_notify_voters_ind  => :P6_NOTIFY_VOTERS_IND );
end;