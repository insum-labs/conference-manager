select e.id
     , e.name
     , e.alias
     , et.name event_type
     , e.location
     , e.begin_date
     , e.end_date
     , case when sysdate between e.blind_vote_begin_date
                             and nvl(e.blind_vote_end_date, trunc(sysdate))+.99999 then 'Y' else 'N' end blind_voting_current_ind
     , case when sysdate between e.committee_vote_begin_date
                             and nvl(e.committee_vote_end_date, trunc(sysdate))+.99999 then 'Y' else 'N' end committee_voting_current_ind
     , e.blind_vote_begin_date
     , e.blind_vote_end_date
     , e.committee_vote_begin_date
     , e.committee_vote_end_date
     , (select count(*) from ks_event_tracks et where et.event_id = e.id) tracks
     , (select count(*) from ks_sessions s where s.event_id = e.id) sessions
     , e.active_ind
     , e.blind_vote_flag
     , e.created_by
     , e.created_on
     , e.updated_by
     , e.updated_on
from ks_events_sec_v e
   , ks_event_types et
where e.event_type = et.code

