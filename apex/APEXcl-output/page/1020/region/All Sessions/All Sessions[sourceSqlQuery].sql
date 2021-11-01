select
    s.id
  , s.event_track_id track_id
  , nvl(t.alias, t.name) track_name
  , s.session_num
  , s.sub_category
  , s.session_type
  , s.title
  , s.session_length
  , s.ranking
  , s.session_summary
  , s.session_abstract
  , s.presenter
  , s.company
  , s.co_presenter
  , s.co_presenter_company
  , decode(s.co_presenter, null, '', 'Y') co_presenter_flag
  , decode(s.notes, null, '', 'Y') notes_flag
  , s.notes
  , s.room_size_code
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
  , s.status_code
  , s.video_link
  , decode(s.video_link, null, '', 'fa-file-video-o') video_icon
  , s.presented_before_ind
  , s.presented_before_where
  , s.presented_anything_ind
  , s.presented_anything_where
  , s.ace_level
  , case s.ace_level
     when 'Oracle ACE Director' then 'ACED.png'
     when 'Oracle ACE' then 'ACER.png'
     when 'Oracle ACE Associate' then 'ACEA.png'
     when 'Groundbreaker Ambassador' then 'groundbreaker-ambassador.png'
     else 'blank.gif'
   end ace_logo
  , s.submission_date
  , s.presenter_user_id
 from ks_events_allowed_v e
    , ks_sessions s
    , ks_event_tracks t
where e.id = t.event_id
  and t.event_id = s.event_id
  and s.event_track_id = t.id
  and s.event_id = to_number(:P1020_EVENT_ID)
