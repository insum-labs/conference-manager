# KS_ERROR_HANDLER




- [Variables](#variables)

- [Exceptions](#exceptions)




## Variables<a name="variables"></a>

Name | Code | Description
--- | --- | ---
l_test | <pre>  l_test varchar2(32767);</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
RETURN | <pre>  <br />  RETURN l_result;</pre> | 
END | <pre>END basic_error_dump;</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>        end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
RETURN | <pre>      <br /><br />  <br />  RETURN l_result;</pre> | 
END | <pre>END basic_error_handler;</pre> | 
l_constraint_name | <pre>  l_constraint_name varchar2(255);</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
end | <pre>            end if;</pre> | 
ELSE | <pre>      <br />      ELSE<br /><br />            null;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>        end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
RETURN | <pre>   <br /><br />  <br />  RETURN l_result;</pre> | 
END | <pre>END basic_error_lookup;</pre> | 
l_constraint_name | <pre>  l_constraint_name varchar2(255);</pre> | 
l_logger_message | <pre>  l_logger_message varchar2(4000);</pre> | 
l_logger_scope | <pre>  l_logger_scope   varchar2(1000);</pre> | 
c_process_error | <pre>  c_process_error number := -20999;</pre> | 
BEGIN | <pre> <br />BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
end | <pre>            end if;</pre> | 
ELSE | <pre>      <br />      ELSE<br /><br />            null;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>      end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
 | <pre>l_logger_scope := to_char(sysdate,'YYYY-MM-DD HH24.MI.SS')||':'||v('APP_USER')||':'||v('APP_ID')||':'||v('APP_PAGE_ID')||':'||v('APP_SESSION');</pre> | 
 | <pre>l_logger_message := replace(l_logger_message, '<BR/>', chr(10));</pre> | 
RETURN | <pre> <br />  RETURN l_result;</pre> | 
END | <pre>END error_handler_logging;</pre> | 
l_constraint_name | <pre>  l_constraint_name varchar2(255);</pre> | 
l_logger_message | <pre>  l_logger_message varchar2(4000);</pre> | 
l_logger_scope | <pre>  l_logger_scope   varchar2(1000);</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
end | <pre>            end if;</pre> | 
ELSE | <pre>      <br />      ELSE<br /><br />            null;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>        end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
 | <pre>  l_logger_scope := to_char(sysdate,'YYYY-MM-DD HH24.MI.SS')||':'||v('APP_USER')||':'||v('APP_ID')||':'||v('APP_PAGE_ID')||':'||v('APP_SESSION');</pre> | 
 | <pre>  l_logger_message := replace(l_logger_message, '<BR/>', chr(10));</pre> | 
 | <pre>  l_logger_message := replace(replace(l_logger_message, '<B>', '*'), '</B>', '*');</pre> | 
RETURN | <pre> <br />  RETURN l_result;</pre> | 
END | <pre>END error_handler_logging_session;</pre> | 
BEGIN | <pre>BEGIN<br />  l_number := 1/0;</pre> | 
END | <pre>END force_plsql_error;</pre> | 
end | <pre>end ks_error_handler;</pre> | 



## Exceptions<a name="exceptions"></a>

Name | Code | Description
--- | --- | ---
l_test | <pre>  l_test varchar2(32767);</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
RETURN | <pre>  <br />  RETURN l_result;</pre> | 
END | <pre>END basic_error_dump;</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>        end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
RETURN | <pre>      <br /><br />  <br />  RETURN l_result;</pre> | 
END | <pre>END basic_error_handler;</pre> | 
l_constraint_name | <pre>  l_constraint_name varchar2(255);</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
end | <pre>            end if;</pre> | 
ELSE | <pre>      <br />      ELSE<br /><br />            null;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>        end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
RETURN | <pre>   <br /><br />  <br />  RETURN l_result;</pre> | 
END | <pre>END basic_error_lookup;</pre> | 
l_constraint_name | <pre>  l_constraint_name varchar2(255);</pre> | 
l_logger_message | <pre>  l_logger_message varchar2(4000);</pre> | 
l_logger_scope | <pre>  l_logger_scope   varchar2(1000);</pre> | 
c_process_error | <pre>  c_process_error number := -20999;</pre> | 
BEGIN | <pre> <br />BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
end | <pre>            end if;</pre> | 
ELSE | <pre>      <br />      ELSE<br /><br />            null;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>      end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
 | <pre>l_logger_scope := to_char(sysdate,'YYYY-MM-DD HH24.MI.SS')||':'||v('APP_USER')||':'||v('APP_ID')||':'||v('APP_PAGE_ID')||':'||v('APP_SESSION');</pre> | 
 | <pre>l_logger_message := replace(l_logger_message, '<BR/>', chr(10));</pre> | 
RETURN | <pre> <br />  RETURN l_result;</pre> | 
END | <pre>END error_handler_logging;</pre> | 
l_constraint_name | <pre>  l_constraint_name varchar2(255);</pre> | 
l_logger_message | <pre>  l_logger_message varchar2(4000);</pre> | 
l_logger_scope | <pre>  l_logger_scope   varchar2(1000);</pre> | 
BEGIN | <pre>BEGIN<br /><br />  l_result := apex_error.init_error_result ( p_error => p_error );</pre> | 
END | <pre>     END IF;</pre> | 
end | <pre>            end if;</pre> | 
ELSE | <pre>      <br />      ELSE<br /><br />            null;</pre> | 
END | <pre>      END IF;</pre> | 
end | <pre>        end if;</pre> | 
END | <pre>      <br />      <br />   END IF;</pre> | 
 | <pre>  l_logger_scope := to_char(sysdate,'YYYY-MM-DD HH24.MI.SS')||':'||v('APP_USER')||':'||v('APP_ID')||':'||v('APP_PAGE_ID')||':'||v('APP_SESSION');</pre> | 
 | <pre>  l_logger_message := replace(l_logger_message, '<BR/>', chr(10));</pre> | 
 | <pre>  l_logger_message := replace(replace(l_logger_message, '<B>', '*'), '</B>', '*');</pre> | 
RETURN | <pre> <br />  RETURN l_result;</pre> | 
END | <pre>END error_handler_logging_session;</pre> | 
BEGIN | <pre>BEGIN<br />  l_number := 1/0;</pre> | 
END | <pre>END force_plsql_error;</pre> | 
end | <pre>end ks_error_handler;</pre> | 




 
