# KS_SEC



- [Constants](#constants)

- [Variables](#variables)

- [Exceptions](#exceptions)

- [IS_VALID_USER Function](#is_valid_user)
- [PASSWORD_WITH_SALT Function](#password_with_salt)
- [POST_LOGIN Procedure](#post_login)



## Variables<a name="variables"></a>

Name | Code | Description
--- | --- | ---
g_salt | <pre>g_salt salt_type := 'rQ/PfG?Z8(C*4RP';</pre> | 

## Constants<a name="constants"></a>

Name | Code | Description
--- | --- | ---
gc_scope_prefix | <pre>gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';</pre> | Standard logger package name

## Exceptions<a name="exceptions"></a>

Name | Code | Description
--- | --- | ---
g_salt | <pre>g_salt salt_type := 'rQ/PfG?Z8(C*4RP';</pre> | 




 
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
 
 





 
