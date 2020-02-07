begin
    select count(*)
        into :P5041_NUM_ROWS
        from ks_full_session_load;
end;