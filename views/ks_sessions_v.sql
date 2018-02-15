
PRO ks_sessions_v
create or replace view ks_sessions_v
as
with totals as (
  select d.session_id
       , sum(d.vote) votes_total
       , avg(d.vote) votes_average
   from ks_session_votes d
  group by d.session_id
)
select s.id
     , s.event_id
     , s.event_track_id
     , s.session_num
     , s.sub_category
     , s.session_type
     , s.title
     , s.presenter
     , s.company
     , s.co_presenter
     , s.status_code
     , s.notes
     , s.tags
     , t.votes_total
     , t.votes_average
     , s.created_by
     , s.created_on
     , s.updated_by
     , s.updated_on
  from ks_sessions s
     , totals t
 where s.id = t.session_id (+)
/
