select a.id, u.full_name || ' (' || u.username || ')' username
  from ks_users_v u
     , ks_event_admins a
 where a.username = u.username
   and a.event_id = :P5025_ID