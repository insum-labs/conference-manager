PRO ks_events_sec_v
create or replace view ks_events_sec_v
as
with p as (select sys_context('APEX$SESSION','app_user') app_user from sys.dual)
select e.id
     , e.name
     , e.alias
     , e.location
     , e.event_type
     , e.begin_date
     , e.end_date
     , e.blind_vote_begin_date
     , e.blind_vote_end_date
     , e.committee_vote_begin_date
     , e.committee_vote_end_date
     , e.blind_vote_flag
     , e.active_ind
     , e.created_by
     , e.created_on
     , e.updated_by
     , e.updated_on
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
 )
/
