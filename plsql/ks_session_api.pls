create or replace package ks_session_api
is

--------------------------------------------------------------------------------
--*
--* 
--*
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
procedure presenter_tracks_json(
    p_event_id  in ks_events.id%TYPE
  , p_presenter_user_id in ks_sessions.presenter_user_id%TYPE);
  
procedure switch_votes (
	p_event_id    in ks_sessions.event_id%TYPE
  , p_track_id    in ks_sessions.event_track_id%TYPE
  , p_username 	  in ks_session_votes.username%TYPE
  , p_voting_role in ks_user_event_track_roles.voting_role_code%TYPE
);


function html_whitelist_tokenize (p_string in varchar2,
                                  p_session_id in number,
                                  p_anonymize in varchar2 default 'N',
                                  p_escape_html in varchar2 default 'Y')
  return varchar2;


procedure session_id_navigation (
   p_id in ks_sessions.id%type
  ,p_region_static_id in varchar2
  ,p_page_id in number
  ,p_previous_id out ks_sessions.event_track_id%type
  ,p_next_id out ks_sessions.event_track_id%type
  ,p_total_rows out number
  ,p_current_row out number
);


function is_session_owner (
  p_session_id in ks_sessions.id%type
 ,p_username   in varchar2
)
return varchar2;


function parse_video_link (
  p_video_link in ks_sessions.video_link%type
)
return varchar2;

end ks_session_api;
/
