select uetr.id,
       u.first_name,
       u.last_name,
       u.full_name,
       u.email,
       u.username,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.selection_role_code,'-')),'') as selection_role,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.voting_role_code,'-')),'') as voting_role
from ks_user_event_track_roles uetr
    join ks_users_v u on (uetr.username = u.username)
where uetr.event_track_id = :P8_EVENT_TRACK_ID
