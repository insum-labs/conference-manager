ks_session_load_api.load_sessions(
    p_event_id   => :P5040_EVENT_ID
  , x_load_count => :P5041_ROW_COUNT
);

ks_session_load_api.create_loaded_session_coll (
    p_event_id   => :P5040_EVENT_ID
  , p_username   => :APP_USER
);