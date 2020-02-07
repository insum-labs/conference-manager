-- should be empty, but delete all previous records loaded by this user
delete from ks_session_load
where app_user = :APP_USER;