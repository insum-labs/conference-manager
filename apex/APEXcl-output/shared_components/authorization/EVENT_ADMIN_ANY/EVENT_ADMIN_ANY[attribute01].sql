with p as (select sys_context('APEX$SESSION','app_user') app_user from sys.dual)
select e.id
  from ks_events e
 where (
  -- Global Admin
  exists (select 1 
            from ks_users u, p 
           where u.admin_ind = 'Y' and u.active_ind = 'Y'
             and u.username = p.app_user
         )
    or e.id in (
     -- Event Admin
     select a.event_id
       from ks_event_admins a, p
      where a.username = p.app_user
    )
);