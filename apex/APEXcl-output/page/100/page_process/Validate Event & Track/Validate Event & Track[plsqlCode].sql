begin
:P1_EVENT_ID := :P100_EVENT_ID;

-- validate the user has right to the track (don't allow hacks!)
select :P100_TRACK_ID
  into :P1_TRACK_ID
  from ks_user_event_track_roles r
     , ks_users u
 where u.username = r.username (+)
   and u.username = :APP_USER
   and (r.selection_role_code is not null 
        or u.admin_ind = 'Y'
        or exists (select 1
                from ks_event_admins a
               where a.username = :APP_USER
                 and a.event_id = :P100_EVENT_ID
             )
       )
   and r.event_track_id (+) = :P100_TRACK_ID;
   
  -- save the new preferences now that they are validated
  apex_util.set_preference('DEFAULT_EVENT_ID', :P100_EVENT_ID);
  apex_util.set_preference('DEFAULT_TRACK_ID', :P100_TRACK_ID);
  
exception
  when NO_DATA_FOUND then
    raise_application_error(-20999, 'No track access');
end;