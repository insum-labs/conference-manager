
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
select  s.id
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
      , s.presenter_email
      , s.session_summary
      , s.session_abstract
      , s.target_audience
      , s.presented_before_ind
      , s.presented_before_where
      , s.technology_product
      , s.ace_level
      , s.video_link
      , trim (
        case
        when instr (s.video_link, 'http') > 0 
        then
          substr (
             s.video_link
            ,instr (s.video_link, 'http')
            ,case 
              when instr (s.video_link, ' ', instr (s.video_link, 'http', 1) + 1) < instr (s.video_link, '<', instr (s.video_link, 'http', 1) + 1)
                then instr (s.video_link, ' ', instr (s.video_link, 'http', 1) + 1)
              when instr (s.video_link, ' ', instr (s.video_link, 'http', 1) + 1) > instr (s.video_link, '<', instr (s.video_link, 'http', 1) + 1)
                then instr (s.video_link, '<', instr (s.video_link, 'http', 1) + 1) - 1
                else length (s.video_link)
            end
          )
        else null
        end
      ) as first_video_link
      , s.contains_demo_ind
      , s.webinar_willing_ind
      , s.external_sys_ref
      , s.presenter_user_id
      , s.co_presenter_user_id
      , s.presenter_biography
      , s.co_presenter_company
      , s.submission_date
      , s.room_size_code
      , s.presented_anything_ind
      , s.presented_anything_where
      , s.created_by
      , s.created_on
      , s.updated_by
      , s.updated_on
  from ks_sessions s
     , totals t
 where s.id = t.session_id (+)
/
