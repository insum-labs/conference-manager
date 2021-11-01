select u.full_name_extended || nvl2(u.external_sys_ref, '', ' [Missing External Ref ID]') as d,
       u.id as r
  from ks_users_v u
where u.active_ind = 'Y'
  and u.id not in (select cu.user_id 
                   from ks_event_comp_users cu 
                  where cu.event_id = to_number(:P5170_EVENT_ID) )
union all
select u.full_name_extended || nvl2(u.external_sys_ref, '', ' [Missing External Ref ID]') as d,
       id as r
  from ks_users_v u
where u.id = to_number (:P5170_USER_ID)
order by 1