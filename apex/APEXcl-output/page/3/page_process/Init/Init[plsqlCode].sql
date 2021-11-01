select sum(d.vote)
     , to_char(avg(d.vote),'99.90')
 into :P3_TOTAL
    , :P3_AVG
 from ks_session_votes d
where d.session_id= to_number(:P3_ID)
  and d.vote is not null
  and d.vote_type = 'COMMITTEE';
    
select sum(d.vote)
     , to_char(avg(d.vote),'99.90')
 into :P3_TOTAL_BLIND_VOTES
    , :P3_AVG_BLIND_VOTES
 from ks_session_votes d
where d.session_id= to_number(:P3_ID)
  and d.vote is not null
  and d.vote_type = 'BLIND';

:P3_ACE_LOGO := case
  when :P3_ACE_LEVEL = 'Oracle ACE Director' then 'ACED.png'
  when :P3_ACE_LEVEL = 'Oracle ACE' then 'ACER.png'
  when :P3_ACE_LEVEL = 'Oracle ACE Associate' then 'ACEA.png'
  when :P3_ACE_LEVEL = 'Groundbreaker Ambassador' then 'groundbreaker-ambassador.png'
  else 'blank.gif'
end;