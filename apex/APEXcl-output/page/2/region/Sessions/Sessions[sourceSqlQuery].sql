with collection as (select count(*) as tag_count from apex_collections where collection_name = 'SESSIONTAGFILTER')
select
    s.id
  , s.session_num
  , s.sub_category
  , s.session_type
  , s.title
  , s.session_summary
  , s.session_abstract
  , s.session_summary session_summary_icon
  , s.session_abstract session_abstract_icon
  , s.presenter
  , s.company
  , s.co_presenter
  , s.co_presenter_company
  , decode(s.co_presenter, null, '', 'Y') co_presenter_flag
  , decode(s.notes, null, '', 'Y') notes_flag
  , s.notes
  , s.room_size_code
  , s.target_audience
  , s.presented_before_ind
  , s.presented_before_where
  , s.ace_level
  , case s.ace_level
      when 'Oracle ACE Director' then 'ACED.png'
      when 'Oracle ACE' then 'ACER.png'
      when 'Oracle ACE Associate' then 'ACEA.png'
      when 'Groundbreaker Ambassador' then 'groundbreaker-ambassador.png'
      else 'blank.gif'
    end ace_logo
  , (select sum(d.vote) from ks_session_votes d where d.session_id=s.id and d.vote_type = 'COMMITTEE') total
  , (select round(avg(d.vote),2) from ks_session_votes d where d.session_id=s.id and d.vote_type = 'COMMITTEE') Average
  , (select sum(d.vote) from ks_session_votes d where d.session_id=s.id and d.vote_type = 'BLIND') total_blind
  , (select round(avg(d.vote),2) from ks_session_votes d where d.session_id=s.id and d.vote_type = 'BLIND') average_blind
  , decode((select count(*)
              from ks_event_tracks t_sub
                 , ks_sessions s_sub
             where t_sub.id = s_sub.event_track_id
               and t_sub.id <> s.event_track_id
               and s_sub.event_id = s.event_id
               and s_sub.presenter_user_id = s.presenter_user_id
             ), 0, '', 'Y') other_tracks_flag
  , (select count(*)
       from ks_event_tracks t_sub
          , ks_sessions s_sub
      where t_sub.id = s_sub.event_track_id
        and t_sub.id <> s.event_track_id
        and s_sub.event_id = s.event_id
        and s_sub.presenter_user_id = s.presenter_user_id
      ) other_tracks
  , s.tags
  , s.session_length
  , s.status_code
  , s.video_link
  , s.first_video_link
  , decode(s.first_video_link, null, '', 'fa-file-video-o') video_icon
  , s.submission_date
  , s.presented_anything_ind
  , s.presented_anything_where
  , s.technology_product
  , s.presenter_user_id
  , s.ranking
 from ks_sessions_v s
    , collection
where s.event_id = to_number(:P1_EVENT_ID)
  and (:P1_TRACK_ID is null or s.event_track_id = to_number(:P1_TRACK_ID))
  and
(
   (collection.tag_count = 0)
    or 
    s.session_num in
      (select t.content_id
         from ks_tags t
            , apex_collections tcoll
        where t.content_type = 'SESSION' || ':' || :P1_TRACK_ID
          and t.content_id = s.session_num
          and t.tag = tcoll.c001
          and tcoll.collection_name = 'SESSIONTAGFILTER'
          and collection.tag_count =
               (select count(*)
                from ks_tags t
                   , apex_collections tcoll
                  where t.content_type = 'SESSION' || ':' || :P1_TRACK_ID
                    and t.content_id = s.session_num
                    and t.tag = tcoll.c001
                    and tcoll.collection_name = 'SESSIONTAGFILTER') 
      )
)