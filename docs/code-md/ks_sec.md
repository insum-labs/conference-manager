# KS_SEC



- [Constants](#constants)

- [Variables](#variables)

- [Exceptions](#exceptions)

- [IS_INVALID_PASSWORD Function](#is_invalid_password)
- [PASSWORD_MATCH Function](#password_match)
- [IS_VALID_USER Function](#is_valid_user)
- [PASSWORD_WITH_SALT Function](#password_with_salt)
- [POST_LOGIN Procedure](#post_login)
- [GET_NAME_FROM_USER Function](#get_name_from_user)
- [REQUEST_RESET_PASSWORD Procedure](#request_reset_password)
- [RESET_PASSWORD Procedure](#reset_password)
- [IS_PASSWORD_EXPIRED Function](#is_password_expired)



## Variables<a name="variables"></a>

Name | Code | Description
--- | --- | ---
g_salt | <pre>g_salt salt_type := 'rQ/PfG?Z8(C*4RP';</pre> | 

## Constants<a name="constants"></a>

Name | Code | Description
--- | --- | ---
gc_scope_prefix | <pre>gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';</pre> | Standard logger package name
c_max_attempts | <pre>c_max_attempts  constant number := 5;</pre> | 

## Exceptions<a name="exceptions"></a>

Name | Code | Description
--- | --- | ---
g_salt | <pre>g_salt salt_type := 'rQ/PfG?Z8(C*4RP';</pre> | 




 
## IS_INVALID_PASSWORD Function<a name="is_invalid_password"></a>


<p>
<p>Validate if the password respects the format rules</p>
</p>

### Syntax
```plsql
function is_invalid_password (
  p_password in ks_users.password%type  
)
return boolean
```

### Parameters
Name | Description
--- | ---
`p_password` | 
*return* | boolean
 
 





 
## PASSWORD_MATCH Function<a name="password_match"></a>


<p>
<p>Check if the given password match with the registered one.</p>
</p>

### Syntax
```plsql
function password_match (
  p_username in ks_users.username%type 
 ,p_password in ks_users.password%type
)
return boolean
```

### Parameters
Name | Description
--- | ---
`p_username` | 
`p_password` | 
*return* | boolean
 
 





 
## IS_VALID_USER Function<a name="is_valid_user"></a>


<p>
<p>Validate a given user and password</p>
</p>

### Syntax
```plsql
function is_valid_user (
       p_username IN varchar2
     , p_password IN varchar2
)
   return boolean
```

### Parameters
Name | Description
--- | ---
`p_username` | case insensitive username
`p_password` | case sensitive password for the user login in
*return* | true/false
 
 





 
## PASSWORD_WITH_SALT Function<a name="password_with_salt"></a>


<p>
<hr>

</p>

### Syntax
```plsql
function password_with_salt (p_password IN varchar2)
   return varchar2
```

 





 
## POST_LOGIN Procedure<a name="post_login"></a>


<p>
<p>Sets enrionmonet after user successfully logs in.</p>
</p>

### Syntax
```plsql
procedure post_login
```

### Parameters
Name | Description
--- | ---
`` | 
 
 





 
## GET_NAME_FROM_USER Function<a name="get_name_from_user"></a>


<p>
<p>Get the name for a given user</p>
</p>

### Syntax
```plsql
function get_name_from_user(p_username in varchar2) return varchar2
```

### Parameters
Name | Description
--- | ---
`name` | 
 
 





 
## REQUEST_RESET_PASSWORD Procedure<a name="request_reset_password"></a>


<p>
<p>Request a Password Reset for the user</p>
</p>

### Syntax
```plsql
procedure request_reset_password (
   p_username in ks_users.username%type
 , p_app_id in ks_parameters.value%type
)
```

### Parameters
Name | Description
--- | ---
`p_username` | 
`p_app_id` | 
 
 





 
## RESET_PASSWORD Procedure<a name="reset_password"></a>


<p>
<p>Reset the user&#39;s password</p>
</p>

### Syntax
```plsql
procedure reset_password (
   p_username in ks_users.username%type
 , p_new_password in ks_users.password%type
 , p_new_password_2 in ks_users.password%type
 , p_error_msg out varchar2
)
```

### Parameters
Name | Description
--- | ---
`p_username` | 
`p_new_password` | 
`p_new_password_2` | 
`p_error_msg` | 
 
 





 
## IS_PASSWORD_EXPIRED Function<a name="is_password_expired"></a>


<p>
<p>Check if the username&#39;s password is expired</p>
</p>

### Syntax
```plsql
function is_password_expired (p_username in ks_users.username%type)
return boolean
```

### Parameters
Name | Description
--- | ---
`p_username` | 
*return* | boolean
 
 





 
