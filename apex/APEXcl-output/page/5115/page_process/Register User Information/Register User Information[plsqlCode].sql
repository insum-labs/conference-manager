declare
begin
    ks_users_api.set_user_information(
        p_existing_user => :P5115_EXISTING_USER,
        p_first_name => :P5115_FIRST_NAME,
        p_last_name => :P5115_LAST_NAME,
        p_email => :P5115_EMAIL,
        p_password => null, -- Password will be set via Password Reset process
        p_is_admin => 'N',
        p_event_id => :P5115_EVENT_ID,
        p_track_id => :P5115_TRACK_ID,
        p_selection_code => :P5115_SELECTION_ROLE,
        p_voting_code => :P5115_VOTING_ROLE,
        p_external_sys_ref => :P5115_EXTERNAL_SYS_REF
    );
end;