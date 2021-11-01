declare
    l_is_valid boolean;
begin
    l_is_valid := ks_session_load_api.validate_data(p_into_event_id => :P5040_EVENT_ID);
    if not l_is_valid
    then
        :P5041_VALID_DATA := 'TRUE';
    else 
        :P5041_VALID_DATA := 'FALSE';        
    end if;
    
end;
