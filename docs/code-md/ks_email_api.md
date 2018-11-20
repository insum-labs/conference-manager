# KS_EMAIL_API



- [Constants](#constants)



- [SEND Procedure](#send)





## Constants<a name="constants"></a>

Name | Code | Description
--- | --- | ---
gc_scope_prefix | <pre>gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';</pre> | Standard logger package name
gc_email_override_key | <pre>gc_email_override_key constant ks_parameters.name_key%type := 'EMAIL_OVERRIDE';</pre> | 






 
## SEND Procedure<a name="send"></a>


<p>
<p>Send an email to the original email accounts or<br />     to the ones specified on email_override on the table ks_parameters.<br />     The parameter &quot;EMAIL_PREFIX&quot; is added to the subject.<br />     If p_to, p_cc and p_bcc are null, the procedure exists.</p>
</p>

### Syntax
```plsql
procedure send (
     p_to in varchar2
    ,p_cc in varchar2 default null
    ,p_bcc in varchar2 default null
    ,p_from in varchar2 default null
    ,p_replyto in varchar2 default null
    ,p_subj in varchar2
    ,p_body in clob
    ,p_body_html in clob
)
```

### Parameters
Name | Description
--- | ---
` p_to
 p_from
 p_replyto
 p_subj
 p_body
 p_body_html` | 
 
 





 
