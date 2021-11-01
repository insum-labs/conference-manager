declare
l_number_id number ;
p_track_name varchar2(100) := apex_application.g_x01;

begin

select t.id
  into  l_number_id
from ks_event_tracks t
where nvl(upper(t.alias), upper(t.name)) like upper('%'||:l_test||'%')
  and ((:G_ADMIN = 'YES')
  and t.event_id = :P1_EVENT_ID
   or exists (select 1
                from ks_user_event_track_roles ut
               where ut.event_track_id = t.id 
                 and ut.selection_role_code is not null
                 and ut.username = :APP_USER)
   )
  and t.active_ind = 'Y'
  and rownum = 1;

:P1_SELECT_TRACK_ID := l_number_id;
:P1_EVENT_ID := :P1_SELECT_EVENT_ID;
logger.log('NEW TRACK ID: '||l_number_id);

-- validate the user has right to the track (don't allow hacks!)
select :P1_SELECT_TRACK_ID
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
                 and a.event_id = :P1_EVENT_ID
             )
       )
   and r.event_track_id (+) = :P1_SELECT_TRACK_ID;
   
exception
  when NO_DATA_FOUND then
    raise_application_error(-20999, 'No track access');
end;