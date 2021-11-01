select uetr.id,
       e.begin_date event_date,
       e.name event_name,
       et.name as track_name,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.selection_role_code,'-')),' ') as selection_role,
       nvl((select r.name from ks_roles r where r.code = nvl(uetr.voting_role_code,'-')),' ') as voting_role
from ks_user_event_track_roles uetr
    join ks_event_tracks et on (uetr.event_track_id = et.id)
    join ks_events e on (e.id = et.event_id)
where uetr.username = :P5105_USERNAME