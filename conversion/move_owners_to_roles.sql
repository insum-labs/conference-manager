PRO seed ks_user_event_track_roles

SET DEFINE OFF;

-- Insert track owners in ks_user_event_track_roles (All Owners for Kscope16, Kscope17 and Kscope18)
insert into ks_user_event_track_roles (username,event_track_id,selection_role_code,voting_role_code)
select owner,id,'OWNER','COMMITTEE'
from ks_event_tracks
where owner is not null
/