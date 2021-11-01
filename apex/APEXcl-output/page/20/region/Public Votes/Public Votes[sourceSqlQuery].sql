select decode(vote, null, 'Total', vote) vote, cnt
, decode(:P20_BLIND_VOTE_TOTAL,0, 0, round(cnt * 100 / :P20_BLIND_VOTE_TOTAL))  percent_complete
, apex_util.html_pct_graph_mask(decode(:P20_BLIND_VOTE_TOTAL,0, 0, round(cnt * 100 / :P20_BLIND_VOTE_TOTAL,2))) bar
from (
    select vote, sum(cnt) cnt
    from (
    select level vote, 0 cnt from dual connect by level < 6
    union all
    select v.vote, count(*) cnt
      from ks_session_votes v
         , ks_sessions s
     where s.id = v.session_id
       and v.vote is not null
       and v.vote_type = 'BLIND'
       and s.event_track_id = :P1_TRACK_ID
    group by v.vote
    )
    group by vote
    order by vote
)
