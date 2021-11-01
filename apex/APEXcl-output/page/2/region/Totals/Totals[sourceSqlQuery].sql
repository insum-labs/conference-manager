with region as (
    select  region_id
    from    apex_application_page_regions
    where   application_id = :APP_ID
    and     page_id = :APP_PAGE_ID
    and     static_id = 'sessionsIR'
)
,report as (
    select apex_ir.get_last_viewed_report_id (
            p_page_id => :APP_PAGE_ID
           ,p_region_id => r.region_id
        ) report_id
    from region r 
)
,report_alias as (
    select  rpt.report_alias
    from    apex_application_page_ir_rpt rpt
    join    report r
    on      r.report_id = rpt.report_id
)
select st.display_seq
      , st.name status, s.status_code
      , '<a href="'
         || apex_page.get_url (
                p_request => 'IR[sessionsIR]' || nvl2 (ra.report_alias, '_' || ra.report_alias, '')
              , p_clear_cache => 'RIR'
              , p_items => 'IREQ_STATUS_CODE'
              , p_values => apex_escape.html(st.name)) || '">'
         || count(*)
         || '</a>' totals
  from ks_sessions s
     , ks_session_status st
     , report_alias ra
 where s.status_code = st.code
   and s.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
 group by st.display_seq, st.name, s.status_code, ra.report_alias
union all
select 15 display_seq
     , 'Comps' status
     , '-NULL-' status_code
     , '<a href="'
         || apex_util.prepare_url (
                p_url => 'f?p=' || :APP_ID || ':9:' || :APP_SESSION || '::' || :DEBUG || ':RP:P9_EVENT_ID,P9_EVENT_TRACK_ID:' || c.event_id || ',' || c.event_track_id
            )|| '">'
         || to_char(sum(c.presenter_comp)) 
         || '</a>'
     totals
  from ks_events_comps_v c
 where c.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or c.event_track_id = to_number(:P1_TRACK_ID))
 group by c.event_id, c.event_track_id     
union all
select 15.1 display_seq
     , 'Speakers' status, s.status_code
     , to_char(count(distinct s.presenter)) totals
  from ks_sessions s
 where s.status_code = 'ACCEPTED'
   and s.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
group by s.status_code
union all
select 998 display_seq
     , '- Pending -' status, '-NULL-' status_code
     , '<a href="'
        || apex_page.get_url(
               p_clear_cache => 'RIR'
             , p_items => 'IRN_STATUS_CODE'
             , p_values => '') || '">'
        || count(*)
        || '</a>' totals
  from ks_sessions s
 where s.event_id = to_number(:P1_EVENT_ID)
   and s.status_code is null
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
union all
select 999 display_seq
     , '- All Sessions -' status, '-ALL-' status_code
     , to_char(count(*)) totals
  from ks_sessions s
 where s.event_id = to_number(:P1_EVENT_ID)
   and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
order by 1
