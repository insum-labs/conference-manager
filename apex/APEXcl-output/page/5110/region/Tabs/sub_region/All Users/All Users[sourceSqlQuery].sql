select uetr.id,
       u.first_name,
       u.last_name,
       u.full_name,
       u.email,
       u.username,
       u.expired_passwd_flag,
       u.login_attempts,
       u.last_login_date,
       u.active_ind,
       et.name as track_name,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.selection_role_code,'-')),' ') as selection_role,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.voting_role_code,'-')),' ') as voting_role
from ks_user_event_track_roles uetr
    join ks_users_v u on (uetr.username = u.username)
    join ks_event_tracks et on (uetr.event_track_id = et.id)
where et.event_id = :P5110_EVENT_ID
