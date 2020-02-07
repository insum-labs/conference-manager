select c.event_id
       , c.event_track_id
       , c.presenter_user_id
       , (  select distinct s.presenter 
               from ks_sessions s
              where s.event_id = c.event_id
                and s.event_track_id = c.event_track_id
                and s.presenter_user_id = c.presenter_user_id
                fetch first 1 row only
         ) as presenter
       , c.presenter_comp
       , case
             when c.presenter_comp = 0 then
               (select nvl(cu.reason, '- N/A -' )
                  from ks_event_comp_users cu 
                   join ks_users u on (u.id = cu.user_id) 
                  where cu.event_id = c.event_id 
                    and u.external_sys_ref = c.presenter_user_id)
             when c.presenter_comp = 1 then
               '- Accepted -'
             when c.presenter_comp < 1 then   
               '- Multiple -' 
             else
               null
       end as reason
  from ks_events_comps_v c
 where c.event_id = to_number(:P9_EVENT_ID)
   and c.event_track_id = to_number (:P9_EVENT_TRACK_ID);
