select uetr.id,
       u.full_name,
       u.email,
       --u.username,
       --et.name as track_name,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.selection_role_code,'-')),' ') as selection_role
from ks_user_event_track_roles uetr
    join ks_users_v u on (uetr.username = u.username)
    join ks_event_tracks et on (uetr.event_track_id = et.id)
where uetr.event_track_id = :P5026_ID
 and uetr.selection_role_code is not null
