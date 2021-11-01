with all_members as (
    select ur.event_track_id
         , sum(decode(ur.voting_role_code, 'COMMITTEE', 1,0)) total_committee_members
         , sum(decode(ur.voting_role_code, 'BLIND', 1,0)) total_blind_members
      from ks_user_event_track_roles ur
     group by ur.event_track_id
),
stats as (
  select s.id
       , count(decode(v.vote_type, 'COMMITTEE' , v.vote, null)) total_committee_votes
       , round(avg  (decode(v.vote_type, 'COMMITTEE' , v.vote, null)), 2) avg_committee_vote
       , count(decode(v.vote_type, 'BLIND', v.vote, null)) total_blind_votes
       , round(avg  (decode(v.vote_type, 'BLIND', v.vote, null)), 2) avg_blind_vote
    from ks_sessions s
       , ks_session_votes v
   where s.id = v.session_id
     and s.event_track_id = :P1_TRACK_ID
   group by s.id
)
select s.id
     , s.title
     , st.total_committee_votes
     , st.total_blind_votes
     , st.avg_committee_vote
     , st.avg_blind_vote
     , m.total_committee_members
     , decode(m.total_committee_members, 0, 0, round(st.total_committee_votes * 100 / m.total_committee_members,2)) percent_committee_complete
     , decode(m.total_committee_members, 0, '', st.total_committee_votes, 'full', '') committee_full_class
     , m.total_blind_members
     , decode(m.total_blind_members, 0, 0, round(st.total_blind_votes * 100 / m.total_blind_members,2)) percent_blind_complete
     , decode(m.total_blind_members, 0, '', st.total_blind_votes, 'full', '') blind_full_class
  from ks_sessions s
     , all_members m
     , stats st
 where s.event_track_id = m.event_track_id
   and s.id = st.id
   and s.event_track_id = :P1_TRACK_ID
