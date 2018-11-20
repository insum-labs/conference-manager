# KS_NOTIFICATION_API



- [Constants](#constants)



- [REPLACE_SUBSTR_TEMPLATE Function](#replace_substr_template)
- [FETCH_USER_SUBSTITIONS Procedure](#fetch_user_substitions)
- [FETCH_COMMON_LINKS Procedure](#fetch_common_links)
- [SEND_EMAIL Procedure](#send_email)
- [NOTIFY_TRACK_SESSION_LOAD Procedure](#notify_track_session_load)
- [NOTIFY_RESET_PWD_REQUEST Procedure](#notify_reset_pwd_request)
- [NOTIFY_RESET_PWD_DONE Procedure](#notify_reset_pwd_done)





## Constants<a name="constants"></a>

Name | Code | Description
--- | --- | ---
gc_scope_prefix | <pre>gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';</pre> | Standard logger package name






 
## REPLACE_SUBSTR_TEMPLATE Function<a name="replace_substr_template"></a>


<p>
<p>Get ready all the parameters to notify by email.</p>
</p>

### Syntax
```plsql
function replace_substr_template (
   p_template_name in varchar2
  ,p_substrings in t_WordList default g_blank_sub_strings
)
return clob
```

### Parameters
Name | Description
--- | ---
`` | 
 
 





 
## FETCH_USER_SUBSTITIONS Procedure<a name="fetch_user_substitions"></a>


<p>
<p>Populate all the substrings available for a given user so they can be used in<br />a template</p>
</p>

### Syntax
```plsql
procedure fetch_user_substitions (
  p_id in ks_users.id%type
 ,p_substrings in out nocopy t_WordList
)
```

### Parameters
Name | Description
--- | ---
`p_id` | <code>ks_users.id</code>
`p_substrings` | <code>t_WordList</code>
 
 





 
## FETCH_COMMON_LINKS Procedure<a name="fetch_common_links"></a>


<p>
<p>Fetch common substitution strings that can be used on a template.</p><ul>
<li>VOTING_APP_LINK</li>
<li>ADMIN_APP_LINK</li>
</ul>

</p>

### Syntax
```plsql
procedure fetch_common_links(p_substrings in out nocopy t_WordList)
```

### Parameters
Name | Description
--- | ---
`x_result_status` | 
 
 





 
## SEND_EMAIL Procedure<a name="send_email"></a>


<p>
<p>Get ready all the parameters to notify by email.<br />If the procedure receives a template name (in <code>p_template_name</code>) then the <code>p_body</code><br />and <code>p_body_html</code> parameters are ignored and only the template is used.<br />If present, the <code>p_substrings</code> &quot;word list&quot; values will be used to merge with the template.<br />Leave <code>p_template_name</code> empty to use the <code>p_body</code> and <code>p_body_html</code> parameters.<br />If all three destination <code>p_to</code>, <code>p_cc</code> and <code>p_bcc</code> are null, the procedure<br />exits without error.</p>
</p>

### Syntax
```plsql
procedure send_email (
   p_to in varchar2 default null
  ,p_from in varchar2
  ,p_cc in varchar2 default null
  ,p_bcc in varchar2 default null
  ,p_subject in varchar2
  ,p_body in clob
  ,p_body_html in clob default null
  ,p_template_name in varchar2 default null
  ,p_substrings in t_WordList default g_blank_sub_strings
)
```

### Parameters
Name | Description
--- | ---
`p_template_name` | optional template name as seen on <code>ks_email_templates</code>
 
 





 
## NOTIFY_TRACK_SESSION_LOAD Procedure<a name="notify_track_session_load"></a>


<p>
<p>Notify users of newly loaded sessions. The loaded sessions are found in <code>ks_session_load_coll_v</code><br />Only the users for the tracks marked during the Load Session Wizard (<code>ks_session_load_coll_v.notify_ind</code>) will be notified.</p>
</p>

### Syntax
```plsql
procedure notify_track_session_load (
    p_notify_owner in varchar2
  , p_notify_voter in varchar2
)
```

### Parameters
Name | Description
--- | ---
`p_notify_owner` | Notify &quot;Track Owners&quot;, ie Track Leads (OWNER) and Track Observers (VIEWER). Those where <code>selection_role_code is not null</code>
`p_notify_voter` | Notify &quot;Voters&quot;: those where <code>voting_role_code is not null</code>
 
 





 
## NOTIFY_RESET_PWD_REQUEST Procedure<a name="notify_reset_pwd_request"></a>


<p>
<p>Send a user an email/notification with their new temporary password after a<br />&quot;Reset Password&quot; (by an Admin) or a &quot;Forgot Password&quot; action (by a user)<br />The text of the email is defined by the template mentioned in the<br /><code>RESET_PASSWORD_REQUEST_NOTIFICATION_TEMPLATE</code> system parameter </p>
</p>

### Syntax
```plsql
procedure notify_reset_pwd_request (
    p_id in ks_users.id%type
   ,p_password in ks_users.password%type
   ,p_app_id in ks_parameters.value%type
)
```

### Parameters
Name | Description
--- | ---
`p_username` | 
`p_password` | 
`p_app_id` | 
 
 





 
## NOTIFY_RESET_PWD_DONE Procedure<a name="notify_reset_pwd_done"></a>


<p>
<p>Notify a user after their password has been successfully changed (Reset Password)<br />The text of the email is defined by the template mentioned in the<br /><code>RESET_PASSWORD_DONE_NOTIFICATION_TEMPLATE</code> system parameter </p>
</p>

### Syntax
```plsql
procedure notify_reset_pwd_done (
    p_id in ks_users.id%type
)
```

### Parameters
Name | Description
--- | ---
`p_id` | ks_users.id
 
 





 
