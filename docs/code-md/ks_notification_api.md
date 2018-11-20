# KS_NOTIFICATION_API



- [Constants](#constants)



- [REPLACE_SUBSTR_TEMPLATE Function](#replace_substr_template)
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
 
 





 
## SEND_EMAIL Procedure<a name="send_email"></a>


<p>
<p>Get ready all the parameters to notify by email.<br />If the procedure receives a template name the p_body and p_body_html are ignored and only the template is used.<br />The p_substrings values will be used to merge with the template.<br />Leave p_template_name empty to use the p_body and p_body_html parameters.<br />If p_to, p_cc and p_bcc are null, the procedure exists.</p>
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
`` | 
 
 





 
## NOTIFY_TRACK_SESSION_LOAD Procedure<a name="notify_track_session_load"></a>


<p>
<p>Notify the users of the tracks marked during the Load Session wizard.</p>
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
`p_notify_owner` | 
`p_notify_voter` | 
 
 





 
## NOTIFY_RESET_PWD_REQUEST Procedure<a name="notify_reset_pwd_request"></a>


<p>
<p>Send a notification of type Password Reset Request </p>
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
<p>Send a notification of type Password Reset Done to the user</p>
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
`p_username` | 
 
 





 
