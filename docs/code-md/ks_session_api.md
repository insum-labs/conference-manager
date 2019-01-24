# KS_SESSION_API



- [Constants](#constants)



- [PRESENTER_TRACKS_JSON Procedure](#presenter_tracks_json)
- [SWITCH_VOTES Procedure](#switch_votes)
- [SESSION_ID_NAVIGATION Procedure](#session_id_navigation)
- [IS_SESSION_OWNER Function](#is_session_owner)
- [PARSE_VIDEO_LINK Function](#parse_video_link)





## Constants<a name="constants"></a>

Name | Code | Description
--- | --- | ---
gc_scope_prefix | <pre>gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';</pre> | Standard logger package name
gc_html_whitelist_tags | <pre>gc_html_whitelist_tags constant varchar2(500) := '<h1>,</h1>,<h2>,</h2>,<h3>,</h3>,<h4>,</h4>,<p>,<span>,</span>,</p>,<b>,</b>,<strong>,</strong>,<i>,</i>,<ul>,</ul>,<ol>,</ol>,<li>,</li>,<br />,<hr/>,<em>,</em>';</pre> | a list of strings to NOT escape from. Same as the apex version but includes span and em
gc_token_exceptions | <pre>gc_token_exceptions constant varchar2(4000) := 'oracle|apex|epm|and|its|it|of';</pre> | is a &quot;|&quot; separated list that gets passed into ks_util. It contains the tokens which we want to ommit from escaping.
gc_parameter_tokens_name | <pre>gc_parameter_tokens_name constant ks_parameters.name_key%type := 'ANONYMIZE_EXTRA_TOKENS';</pre> | 






 
## PRESENTER_TRACKS_JSON Procedure<a name="presenter_tracks_json"></a>


<p>
<p>Output of the form:<br />   apex_json.open_object;<br />   apex_json.write(&#39;presenter&#39;, p_presenter);<br />   apex_json.write(&#39;trackList&#39;, &#39;<ul><li>Track 1</li></ul>&#39;);<br />   apex_json.close_object;</p>
</p>

### Syntax
```plsql
procedure presenter_tracks_json(
    p_event_id  in ks_events.id%TYPE
  , p_presenter in ks_sessions.presenter%TYPE)
```

### Parameters
Name | Description
--- | ---
`p_event_id` | 
`p_presenter` | 
 
 





 
## SWITCH_VOTES Procedure<a name="switch_votes"></a>


<p>
<p>Switch votes and voting role of an user for a selected event / track.</p>
</p>

### Syntax
```plsql
procedure switch_votes (
  p_event_id    in ks_sessions.event_id%TYPE
  , p_track_id    in ks_sessions.event_track_id%TYPE
  , p_username    in ks_session_votes.username%TYPE
  , p_voting_role in ks_user_event_track_roles.voting_role_code%TYPE
)
```

### Parameters
Name | Description
--- | ---
`p_event_id` | id of the specific event.
`p_track_id` | id of a specific track.
`p_username` | username of the user.
`p_voting_role` | selected voting role for the user.
 
 





 
## SESSION_ID_NAVIGATION Procedure<a name="session_id_navigation"></a>


<p>
<p>Get the following data to allow navigation of the sessions:</p><ul>
<li>Previous Session ID</li>
<li>Next Session ID</li>
<li>Current Row</li>
<li>Total Row</li>
</ul>

</p>

### Syntax
```plsql
procedure session_id_navigation (
   p_id in ks_sessions.id%type
  ,p_region_static_id in varchar2
  ,p_page_id in number
  ,p_previous_id out ks_sessions.event_track_id%type
  ,p_next_id out ks_sessions.event_track_id%type
  ,p_total_rows out number
  ,p_current_row out number
)
```

### Parameters
Name | Description
--- | ---
`p_id` | 
`p_region_static_id` | 
`p_page_id` | 
`p_previous_id` | 
`p_next_id` | 
`p_total_rows` | 
`p_current_row` | 
 
 





 
## IS_SESSION_OWNER Function<a name="is_session_owner"></a>


<p>
<p>For a given track session and user, indicate if the given user is the presenter<br />or copresenter of the session.<br />The comparison is done against the ks_users.external_sys_ref which identifies users<br />in the external system.</p>
</p>

### Syntax
```plsql
function is_session_owner (
  p_session_id in ks_sessions.id%type
 ,p_username   in varchar2
)
return varchar2
```

### Parameters
Name | Description
--- | ---
`p_id` | 
*return* | &#x27;Y&#x27;,&#x27;N&#x27;
 
 





 
## PARSE_VIDEO_LINK Function<a name="parse_video_link"></a>


<p>
<p>Parse the &quot;video link&quot; text returning one line per link and formatting the link as an html anchor tag when applied.</p>
</p>

### Syntax
```plsql
function parse_video_link (
  p_video_link in ks_sessions.video_link%type
)
return varchar2
```

### Parameters
Name | Description
--- | ---
`p_video_link` | 
*return* | parsed text containing the link as a html anchor tag.
 
 





 
