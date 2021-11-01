select et.id
     , et.event_id
     , et.display_seq
     , et.name
     , et.alias
     , (select u.full_name
            from ks_users_v u
        where u.username = (select uetr.username
                                from ks_user_event_track_roles uetr
                            where uetr.selection_role_code = 'OWNER'
                                and uetr.event_track_id = et.id
                            fetch first 1 rows only)) owner
     , decode(et.blind_vote_begin_date, null, '', 'Y') blind_voting_exception_ind
     , decode(et.committee_vote_begin_date, null, '', 'Y') committee_voting_exception_ind
     , nvl2(et.blind_vote_end_date
          , to_char(et.blind_vote_begin_date, :DATE_FORMAT_MASK) || ' to ' || to_char(et.blind_vote_end_date, :DATE_FORMAT_MASK)
          , to_char(et.blind_vote_begin_date, :DATE_FORMAT_MASK)
           )  blind_voting
     , nvl2(et.committee_vote_end_date
          , to_char(et.committee_vote_begin_date, :DATE_FORMAT_MASK) || ' to ' || to_char(et.committee_vote_end_date, :DATE_FORMAT_MASK)
          , to_char(et.committee_vote_begin_date, :DATE_FORMAT_MASK)
           )  committee_voting
     , etd.blind_voting_current_ind
     , etd.committee_voting_current_ind
     , et.max_sessions
     , et.max_comps
     , (select count(*) from ks_sessions s where s.event_track_id = et.id) sessions_loaded
     , et.active_ind
 from ks_event_tracks et
    , ks_events_tracks_v etd
where et.event_id = to_number(:P5025_ID) 
  and et.id = etd.event_track_id