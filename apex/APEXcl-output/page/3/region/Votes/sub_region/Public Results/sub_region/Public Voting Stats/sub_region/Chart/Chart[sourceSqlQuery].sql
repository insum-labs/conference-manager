select decode(vote, null, 'All Votes', vote) vote, cnt, t.total_votes
, decode(t.total_votes,0, 0, round(cnt * 100 / t.total_votes ))  percent_complete
, apex_util.html_pct_graph_mask(decode(t.total_votes,0, 0, round(cnt * 100 / t.total_votes,2))) bar
from (
    select vote, sum(cnt) cnt
    from (
    select level vote, 0 cnt from dual connect by level <= 5
    union all
    select v.vote, count(*) cnt
      from ks_session_votes v
         , ks_sessions s
     where s.id = v.session_id
       and v.vote is not null
        and s.id = :P3_ID
        and v.vote_type = 'BLIND'
        and v.vote is not null
    group by v.vote
    )
    group by vote
    order by vote
)
, (select count(*) total_votes from ks_session_votes v where v.session_id = :P3_ID and v.vote_type = 'BLIND' and v.vote is not null) t;