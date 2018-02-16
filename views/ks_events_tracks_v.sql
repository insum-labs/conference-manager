create or replace view ks_events_tracks_v
as
  select e.id event_id
       , t.id event_track_id
       , e.name event_name
       , t.display_seq
       , t.name track_name
       , nvl(t.alias, t.name) track_alias
       , nvl(t.blind_vote_begin_date , e.blind_vote_begin_date ) blind_vote_begin_date
       , nvl(t.committee_vote_begin_date, e.committee_vote_begin_date) committee_vote_begin_date
       , nvl(nvl(t.blind_vote_end_date   , e.blind_vote_end_date ), sysdate) blind_vote_end_date
       , nvl(nvl(t.committee_vote_end_date  , e.committee_vote_end_date), sysdate) committee_vote_end_date
       , case when sysdate between nvl(t.blind_vote_begin_date , e.blind_vote_begin_date)
                               and nvl(nvl(t.blind_vote_end_date, e.blind_vote_end_date), trunc(sysdate))+.99999 then 'Y' else 'N' end blind_voting_current_ind
       , case when sysdate between nvl(t.committee_vote_begin_date, e.committee_vote_begin_date)
                               and nvl(nvl(t.committee_vote_end_date, e.committee_vote_end_date), trunc(sysdate))+.99999 then 'Y' else 'N' end committee_voting_current_ind
       , case when sysdate between e.begin_date and nvl(e.end_date, e.begin_date) then 'Y' else 'N' end event_current_ind
       , e.begin_date begin_date
       , nvl(e.end_date, e.begin_date) end_date
       , e.active_ind event_active_ind
       , t.active_ind track_active_ind
       , t.blind_vote_help
       , t.committee_vote_help
       , (case
            when sysdate < nvl(t.blind_vote_begin_date,e.blind_vote_begin_date ) then
              'Opens ' || to_char(nvl(t.blind_vote_begin_date,e.blind_vote_begin_date ), 'fmDay, fmMonth fmDD, YYYY')
            when sysdate >= nvl(t.blind_vote_begin_date,e.blind_vote_begin_date )
                        and nvl(t.blind_vote_end_date,e.blind_vote_end_date ) is null then
              'Opened Indefinately'
            when sysdate >= nvl(t.blind_vote_begin_date,e.blind_vote_begin_date )
             and sysdate < nvl(t.blind_vote_end_date,e.blind_vote_end_date )+.99999 then
              'Closes ' || to_char(nvl(t.blind_vote_end_date,e.blind_vote_end_date), 'fmDay, fmMonth fmDD, YYYY')
            when sysdate >= nvl(t.blind_vote_end_date,e.blind_vote_end_date)
             and sysdate <= (nvl(t.blind_vote_end_date,e.blind_vote_end_date) + 7 + .99999) then
              'Closed ' || to_char(nvl(t.blind_vote_end_date,e.blind_vote_end_date), 'fmDay, fmMonth fmDD, YYYY')
            else ''
          end) blind_vote_date_desc
       , (case
            when sysdate < nvl(t.committee_vote_begin_date,e.committee_vote_begin_date ) then
              'Opens ' || to_char(nvl(t.committee_vote_begin_date,e.committee_vote_begin_date ), 'fmDay, fmMonth fmDD, YYYY')
            when sysdate >= nvl(t.committee_vote_begin_date,e.committee_vote_begin_date )
                        and nvl(t.committee_vote_end_date,e.committee_vote_end_date ) is null then
              'Open Indefinately'
            when sysdate >= nvl(t.committee_vote_begin_date,e.committee_vote_begin_date )
             and sysdate < nvl(t.committee_vote_end_date,e.committee_vote_end_date )+.99999 then
              'Closes ' || to_char(nvl(t.committee_vote_end_date,e.committee_vote_end_date), 'fmDay, fmMonth fmDD, YYYY')
            when sysdate >= nvl(t.committee_vote_end_date,e.committee_vote_end_date)
             and sysdate <= (nvl(t.committee_vote_end_date,e.committee_vote_end_date) + 7 + .99999) then
              'Closed ' || to_char(nvl(t.committee_vote_end_date,e.committee_vote_end_date), 'fmDay, fmMonth fmDD, YYYY')
            else ''
          end) committee_vote_date_desc
       , t.max_comps
       , t.max_sessions
  from ks_events e
     , ks_event_tracks t
 where 1=1
   and t.event_id = e.id
/
