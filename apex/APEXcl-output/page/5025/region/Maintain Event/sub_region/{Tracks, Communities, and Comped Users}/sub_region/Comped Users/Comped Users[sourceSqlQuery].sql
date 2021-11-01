select  cu.id
      , cu.event_id
      , cu.user_id
      , u.full_name_extended user_full_name
      , cu.reason
      , decode(u.external_sys_ref, null, 'show', 'hide') warning_class
  from ks_event_comp_users cu
     , ks_users_v u
 where cu.user_id = u.id
   and cu.event_id = to_number(:P5025_ID);