select r.name || 's' name, count(*) members
from ks_user_event_track_roles tr
   , ks_roles r
where tr.voting_role_code = r.code
  and tr.event_track_id = :P1_TRACK_ID
group by r.name
order by 1