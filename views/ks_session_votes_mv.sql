PRO ks_session_votes_mv
create materialized view log on ks_session_votes
  with primary key
  including new values
/
create materialized view ks_session_votes_mv
  build immediate
  refresh on commit
  enable query rewrite
as
select d.vote_type
     , d.session_id
     , sum(d.vote) votes_total
     , avg(d.vote) votes_average
     , count(*) votes_count
 from ks_session_votes d
group by d.vote_type
       , d.session_id
/
create unique index ks_session_votes_mv_u01 on ks_session_votes_mv(session_id, vote_type);
