select st.display_seq
      , st.name status, s.status_code
      , '<a href="'
         || apex_page.get_url(
                p_request => :P10_IR_REQUEST
              , p_page => '2'
              , p_clear_cache => 'RIR'
              , p_items => 'IREQ_STATUS_CODE'
              , p_values => apex_escape.html(st.name)) || '">'
         || count(*)
         || '</a>' totals
  from ks_sessions s
     , ks_session_status st
 where s.status_code = st.code
   and s.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
 group by st.display_seq, st.name, s.status_code
union all
select 15 display_seq
     , 'Speakers' status, s.status_code
     , to_char(count(distinct s.presenter)) totals
  from ks_sessions s
 where s.status_code = 'ACCEPTED'
   and s.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
group by s.status_code
order by 1
