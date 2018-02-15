set define off
create or replace PACKAGE BODY ks_error_handler
AS
--============================================================================
-- B A S I C   E R R O R   D U M P
--============================================================================
FUNCTION basic_error_dump(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result
AS
  l_result apex_error.t_error_result;
  l_test varchar2(32767);
BEGIN
  -- The first thing we need to do is initialize the result variable.
  l_result := apex_error.init_error_result ( p_error => p_error );
  
        l_result.message := 'Here''s the full error details:<p/>'||
                            '<PRE>'||
                            '<BR/><B>          MESSAGE:</B> '||p_error.message||
                            '<BR/><B>  Additional Info:</B> '||p_error.additional_info||
                            '<BR/><B> Display Location:</B> '||p_error.display_location||
                            '<BR/><B> Association_Type:</B> '||p_error.Association_type||
                            '<BR/><B>   Page Item Name:</B> '||p_error.page_item_name||
                            '<BR/><B>        Region ID:</B> '||p_error.region_id||
                            '<BR/><B>     Column Alias:</B> '||p_error.column_alias||
                            '<BR/><B>          Row Num:</B> '||p_error.row_num||
                            '<BR/><B>Is Internal Error:</B> '||case when p_error.is_internal_error = TRUE 
                                                        THEN 'True'
                                                        ELSE 'False'
                                                   end||
                            '<BR/><B>  APEX ERROR CODE:</B> '||p_error.apex_error_code||
                            '<BR/><B>      ora_sqlcode:</B> '||p_error.ora_sqlcode||
                            '<BR/><B>      ora_sqlerrm:</B> '||p_error.ora_sqlerrm||
                            '<BR/><B>  Error Backtrace:</B><BR/>'||p_error.error_backtrace||
                            '<BR/><B>   Component.type:</B> '||p_error.component.type||
                            '<BR/><B>     Component.id:</B> '||p_error.component.id||
                            '<BR/><B>   Component.name:</B> '||p_error.component.name||
                            '<BR/><B>  First Error Text:</B> '||apex_error.get_first_ora_error_text ( p_error => p_error )||
                            '<BR/><B>   Application ID:</B> '||v('APP_ID')||
                            '<BR/><B>          Page ID:</B> '||v('APP_PAGE_ID')||'<P/><pre/>' ;
             
-- Now return the result record to the caller.
  
  RETURN l_result;
END basic_error_dump;
--============================================================================
-- B A S I C   E R R O R   H A N D L E R
--============================================================================
FUNCTION basic_error_handler(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result
AS
  l_result apex_error.t_error_result;
BEGIN
  -- The first thing we need to do is initialize the result variable.
  l_result := apex_error.init_error_result ( p_error => p_error );
  
  -- Look at the error that was encountered. Is it an "internal" error?
  IF p_error.is_internal_error then
     -- If it is, then it may contain information that could give away clues to the 
     -- database structure.
     -- 
     -- However the errors for Authorization Checks should be fine... So if it's 
     -- anything BUT an authroization Check, we need to re-write the error 
     IF p_error.apex_error_code <> 'APEX.AUTHORIZATION.ACCESS_DENIED' then
 
     
        -- We'll try to construct an error that has good information 
        -- but doesn't give away any info into the DB Structure
        --
        l_result.message := 'We''re Sorry. An unexpected error has occurred. '||
                            'Please note the following information and contact the help desk:<p/>'||
                            '<PRE/>'||
                            '<BR/> Application ID: '||v('APP_ID')||
                            '<BR/>        Page ID: '||v('APP_PAGE_ID')||
                            '<BR/>APEX ERROR CODE: '||p_error.apex_error_code||
                            '<BR/>    ora_sqlcode: '||p_error.ora_sqlcode||
                            '<BR/>    ora_sqlerrm: '||p_error.ora_sqlerrm||
                            '</PRE>' ;
     END IF;
  ELSE 
    -- It's NOT an internal error, so we need to handle it.
    --
    -- First lets reset the place where it's going to display
    -- If at all possible we want to get away from the ugly error page scenario.
    -- 
    l_result.display_location :=
      CASE 
         -- If the error is supposed to be displayed on an error page
         WHEN l_result.display_location = apex_error.c_on_error_page 
           -- Then let's put it back inline
           THEN apex_error.c_inline_in_notification
         -- Otherwise keep it as defined.
         ELSE l_result.display_location
      END;
 
      -- If it was an ORA error that was raised
      -- we'll present the error text of to the end user in a nicer format.
      -- 
      -- To do this we'll get the "First Error Text" using the APEX_ERROR API
        
      IF p_error.ora_sqlcode IS NOT NULL then
            l_result.message := apex_error.get_first_ora_error_text (
                                    p_error => p_error );
      END IF;
      
      -- We can also use the APEX_ERROR API to automatically find the 
      -- item the error was associated with, IF they're not already set.
      if l_result.page_item_name is null and l_result.column_alias is null then
            apex_error.auto_set_associated_item (
                p_error        => p_error,
                p_error_result => l_result );
        end if;
      
      
   END IF;      
                            
-- Now return the result record to the caller.
  
  RETURN l_result;
END basic_error_handler;
--============================================================================
-- B A S I C   E R R O R   H A N D L E R   W I T H   L O O K U P
--============================================================================
FUNCTION basic_error_lookup(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result
AS
  l_result apex_error.t_error_result;
  l_constraint_name varchar2(255);
BEGIN
  -- The first thing we need to do is initialize the result variable.
  l_result := apex_error.init_error_result ( p_error => p_error );
  
  -- Look at the error that was encountered. Is it an "internal" error?
  IF p_error.is_internal_error then
     -- If it is, then it may contain information that could give away clues to the 
     -- database structure.
     -- 
     -- However the errors for Authorization Checks should be fine... So if it's 
     -- anything BUT an authroization check, we need to re-write the error 
     IF p_error.apex_error_code <> 'APEX.AUTHORIZATION.ACCESS_DENIED' then
     
        
        -- We'll try to construct an error that has good information 
        -- but doesn't give away any info into the DB Structure
        --
        l_result.message := 'We''re Sorry. An unexpected error has occurred. '||
                            'Please note the following information and contact the help desk:<p/>'||
                            '<PRE/>'||
                            '<BR/> Application ID: '||v('APP_ID')||
                            '<BR/>        Page ID: '||v('APP_PAGE_ID')||
                            '<BR/>APEX ERROR CODE: '||p_error.apex_error_code||
                            '<BR/>    ora_sqlcode: '||p_error.ora_sqlcode||
                            '<BR/>    ora_sqlerrm: '||p_error.ora_sqlerrm||
                            '</PRE>';
     END IF;
  ELSE 
    -- It's NOT an internal error, so we need to handle it.
    --
    -- First lets reset the place where it's going to display
    -- If at all possible we want to get away from the ugly error page scenario.
    -- 
    l_result.display_location :=
      CASE 
         -- If the error is supposed to be displayed on an error page
         WHEN l_result.display_location = apex_error.c_on_error_page 
           -- Then let's put it back inline
           THEN apex_error.c_inline_in_notification
         -- Otherwise keep it as defined.
         ELSE l_result.display_location
      END;
 
      -- If it is an ORA error that was raised lets do our best to figure it out
      -- and present the error text of to the end user in a nicer format.
      -- 
      -- To do this we'll get the "First Error Text" using the APEX_ERROR API
        
      IF p_error.ora_sqlcode IS NOT NULL then
      
            -- If it's a constraint violation then we'll try to get a matching "friendly" message from our 
            -- Lookup table. Below is a reference of common constraint violations you may want to handle.
            --
            --   -) ORA-00001: unique constraint violated
            --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
            --   -) ORA-02290: check constraint violated
            --   -) ORA-02291: integrity constraint violated - parent key not found
            --   -) ORA-02292: integrity constraint violated - child record found
            --
            IF p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
            -- Get the contraint name 
            l_constraint_name := apex_error.extract_constraint_name ( p_error => p_error );
            -- Use that constraint name to see if we have a translation for it in our table.
            begin
                select message
                  into l_result.message
                  from constraint_lookup
                 where constraint_name = l_constraint_name;
            exception 
                 when no_data_found 
                 then null; 
            end;
            ELSE
               -- Lets check some common error codes here... 
             l_result.message :=
              case 
                  when p_error.ora_sqlcode = -1407
                  then 'Trying to insert a null value into a not null column.'
                  --WHEN p_error.ora_sqlcode =  -12899
                  --THEN 'The value you entered was to large for the field. Please try again.'
               else
                  apex_error.get_first_ora_error_text (p_error => p_error )
               end;
            end if;
      
      ELSE
            --l_result.message := apex_error.get_first_ora_error_text (p_error => p_error );
            null;
      END IF;
      
      -- We can also use the APEX_ERROR API to automatically find the 
      -- item the error was associated with, IF they're not already set.
      if l_result.page_item_name is null and l_result.column_alias is null then
            apex_error.auto_set_associated_item (
                p_error        => p_error,
                p_error_result => l_result );
        end if;
      
      
   END IF;   
                            
-- Now return the result record to the caller.
  
  RETURN l_result;
END basic_error_lookup;
--============================================================================
-- E R R O R   H A N D L E R  -  L O G G I N G
--============================================================================
FUNCTION error_handler_logging(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result
AS
  l_result apex_error.t_error_result;
  l_constraint_name varchar2(255);
  l_logger_message varchar2(4000);
  l_logger_scope   varchar2(1000);
BEGIN
  -- The first thing we need to do is initialize the result variable.
  l_result := apex_error.init_error_result ( p_error => p_error );
  
  -- Look at the error that was encountered. Is it an "internal" error?
  IF p_error.is_internal_error then
     -- If it is, then it may contain information that could give away clues to the 
     -- database structure.
     -- 
     -- However the errors for Authorization Checks should be fine... So if it's 
     -- anything BUT an authroization check, we need to re-write the error 
     IF p_error.apex_error_code <> 'APEX.AUTHORIZATION.ACCESS_DENIED' then
     
        
        -- We'll try to construct an error that has good information 
        -- but doesn't give away any info into the DB Structure
        --
        l_result.message := 'We''re Sorry. An unexpected error has occurred. '||
                            'Please note the following information and contact the help desk:<p/>'||
                            '<PRE/>'||
                            '<BR/> Application ID: '||v('APP_ID')||
                            '<BR/>        Page ID: '||v('APP_PAGE_ID')||
                            '<BR/>APEX ERROR CODE: '||p_error.apex_error_code||
                            '<BR/>    ora_sqlcode: '||p_error.ora_sqlcode||
                            '<BR/>    ora_sqlerrm: '||p_error.ora_sqlerrm||
                            '</PRE>';
     END IF;
  ELSE 
    -- It's NOT an internal error, so we need to handle it.
    --
    -- First lets reset the place where it's going to display
    -- If at all possible we want to get away from the ugly error page scenario.
    -- 
    l_result.display_location :=
      CASE 
         -- If the error is supposed to be displayed on an error page
         WHEN l_result.display_location = apex_error.c_on_error_page 
           -- Then let's put it back inline
           THEN apex_error.c_inline_in_notification
         -- Otherwise keep it as defined.
         ELSE l_result.display_location
      END;
 
      -- If it is an ORA error that was raised lets do our best to figure it out
      -- and present the error text of to the end user in a nicer format.
      -- 
      -- To do this we'll get the "First Error Text" using the APEX_ERROR API
        
      IF p_error.ora_sqlcode IS NOT NULL then
      
            -- If it's a constraint violation then we'll try to get a matching "friendly" message from our 
            -- Lookup table. Below is a reference of common constraint violations you may want to handle.
            --
            --   -) ORA-00001: unique constraint violated
            --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
            --   -) ORA-02290: check constraint violated
            --   -) ORA-02291: integrity constraint violated - parent key not found
            --   -) ORA-02292: integrity constraint violated - child record found
            --
            IF p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
              -- Get the contraint name 
              l_constraint_name := apex_error.extract_constraint_name ( p_error => p_error );
              -- Use that constraint name to see if we have a translation for it in our table.
              begin
                  select message
                    into l_result.message
                    from constraint_lookup
                   where constraint_name = l_constraint_name;
              exception 
                   when no_data_found 
                   then null; 
              end;
            ELSE
               -- Lets check some common error codes here... 
             l_result.message :=
              CASE 
                  WHEN p_error.ora_sqlcode = -1407
                  THEN 'Trying to insert a null value into a not null column.'
                  --WHEN p_error.ora_sqlcode =  -12899
                  --THEN 'The value you entered was too large for the field. Please try again.'
               ELSE 
                  apex_error.get_first_ora_error_text (
                                    p_error => p_error )
               end;
            end if;
      
      ELSE
            --l_result.message := apex_error.get_first_ora_error_text (p_error => p_error );
            null;
      END IF;
      
      -- We can also use the APEX_ERROR API to automatically find the 
      -- item the error was associated with, IF they're not already set.
      if l_result.page_item_name is null and l_result.column_alias is null then
            apex_error.auto_set_associated_item (
                p_error        => p_error,
                p_error_result => l_result );
        end if;
      
      
   END IF;   
   
-- LAST thing we do before returning is log the error     
--
-- LOG THE UNKNOWN ERROR IN THE LOGGER TABLES
--
-- First build the log message
l_logger_message  := 'Here''s the full error details:<p/>'||
            '<PRE>'||
            '<BR/><B>          MESSAGE:</B> '||p_error.message||
            '<BR/><B>  Additional Info:</B> '||p_error.additional_info||
            '<BR/><B> Display Location:</B> '||p_error.display_location||
            '<BR/><B> Association_Type:</B> '||p_error.Association_type||
            '<BR/><B>   Page Item Name:</B> '||p_error.page_item_name||
            '<BR/><B>        Region ID:</B> '||p_error.region_id||
            '<BR/><B>     Column Alias:</B> '||p_error.column_alias||
            '<BR/><B>          Row Num:</B> '||p_error.row_num||
            '<BR/><B>Is Internal Error:</B> '||case when p_error.is_internal_error = TRUE 
                                        THEN 'True'
                                        ELSE 'False'
                                   end||
            '<BR/><B>  APEX ERROR CODE:</B> '||p_error.apex_error_code||
            '<BR/><B>      ora_sqlcode:</B> '||p_error.ora_sqlcode||
            '<BR/><B>      ora_sqlerrm:</B> '||p_error.ora_sqlerrm||
            '<BR/><B>  Error Backtrace:</B><BR/>'||p_error.error_backtrace||
            '<BR/><B>   Component.type:</B> '||p_error.component.type||
            '<BR/><B>     Component.id:</B> '||p_error.component.id||
            '<BR/><B>   Component.name:</B> '||p_error.component.name||
            '<BR/><B> First Error Text:</B> '||apex_error.get_first_ora_error_text ( p_error => p_error )||
            '<BR/><B>   Application ID:</B> '||v('APP_ID')||
            '<BR/><B>          Page ID:</B> '||v('APP_PAGE_ID')||'<P/><pre/>' ;
-- Generate a SCOPE string for logger so we can get a handle back on it
-- Format   YYYY-MM-DD HH24.MI.SS:USER:APP:PAGE:SESSION
--
l_logger_scope := to_char(sysdate,'YYYY-MM-DD HH24.MI.SS')||':'||v('APP_USER')||':'||v('APP_ID')||':'||v('APP_PAGE_ID')||':'||v('APP_SESSION');
-- Now create the log entry as an error so it captures the error stack.
-- but remove the HTML
l_logger_message := replace(l_logger_message, '<BR/>', chr(10));
-- logger.log_error(p_text => l_logger_message, p_scope => l_logger_scope);
                            
-- Now return the result record to the caller.
 
  RETURN l_result;
END error_handler_logging;
--============================================================================
-- E R R O R   H A N D L E R  -  L O G G I N G  &  S E S S I O N   S T A T E
--============================================================================
FUNCTION error_handler_logging_session(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result
AS
  l_result apex_error.t_error_result;
  l_constraint_name varchar2(255);
  l_logger_message varchar2(4000);
  l_logger_scope   varchar2(1000);
BEGIN
  -- The first thing we need to do is initialize the result variable.
  l_result := apex_error.init_error_result ( p_error => p_error );
  
  -- Look at the error that was encountered. Is it an "internal" error?
  IF p_error.is_internal_error then
     -- If it is, then it may contain information that could give away clues to the 
     -- database structure.
     -- 
     -- However the errors for Authorization Checks should be fine... So if it's 
     -- anything BUT an authroization check, we need to re-write the error 
     -- Oh and if the session expired, don't report it as an error.
     IF p_error.apex_error_code = 'APEX.SESSION.EXPIRED' then -- added for APEX5
        -- Keep the error, but add more to it. And capture with logger below (for now).
        -- Redirect to Home Page after 1.5 second.
        l_result.message := p_error.message
            || '<script>setTimeout(function(){location.href="f?p=' || v('APP_ID') || '";},1500);</script>';
        -- leave the additional_info alone.
        -- l_result.additional_info := '';
     ELSIF p_error.apex_error_code <> 'APEX.AUTHORIZATION.ACCESS_DENIED' then
     
        
        -- We'll try to construct an error that has good information 
        -- but doesn't give away any info into the DB Structure
        --
        l_result.message := 'We''re Sorry. An unexpected error has occurred. '||
                            'Please note the following information and contact the help desk:<p/>'||
                            '<PRE/>'||
                            '<BR/> Application ID: '||v('APP_ID')||
                            '<BR/>        Page ID: '||v('APP_PAGE_ID')||
                            '<BR/>APEX ERROR CODE: '||p_error.apex_error_code||
                            '<BR/>    ora_sqlcode: '||p_error.ora_sqlcode||
                            '<BR/>    ora_sqlerrm: '||p_error.ora_sqlerrm||
                            '</PRE>';
     END IF;
  ELSE 
    -- It's NOT an internal error, so we need to handle it.
    --
    -- First lets reset the place where it's going to display
    -- If at all possible we want to get away from the ugly error page scenario.
    -- 
    l_result.display_location :=
      CASE 
         -- If the error is supposed to be displayed on an error page
         WHEN l_result.display_location = apex_error.c_on_error_page 
           -- Then let's put it back inline
           THEN apex_error.c_inline_in_notification
         -- Otherwise keep it as defined.
         ELSE l_result.display_location
      END;
 
      -- If it is an ORA error that was raised lets do our best to figure it out
      -- and present the error text of to the end user in a nicer format.
      -- 
      -- To do this we'll get the "First Error Text" using the APEX_ERROR API
        
      IF p_error.ora_sqlcode IS NOT NULL then
      
            -- If it's a constraint violation then we'll try to get a matching "friendly" message from our 
            -- Lookup table. Below is a reference of common constraint violations you may want to handle.
            --
            --   -) ORA-00001: unique constraint violated
            --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
            --   -) ORA-02290: check constraint violated
            --   -) ORA-02291: integrity constraint violated - parent key not found
            --   -) ORA-02292: integrity constraint violated - child record found
            --
            IF p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
              -- Get the contraint name 
              l_constraint_name := apex_error.extract_constraint_name ( p_error => p_error );
              -- Use that constraint name to see if we have a translation for it in our table.
              begin
                  select message
                    into l_result.message
                    from constraint_lookup
                   where constraint_name = l_constraint_name;
              exception 
                   when no_data_found 
                   then null;
              end;
            ELSE
               -- Lets check some common error codes here... 
             l_result.message :=
              case 
                  when p_error.ora_sqlcode = -1407 THEN
                   'Trying to insert a null value into a not null column.'
                  --WHEN p_error.ora_sqlcode =  -12899
                  --THEN 'The value you entered was to large for the field. Please try again.'
               else 
                  apex_error.get_first_ora_error_text (
                                    p_error => p_error )
               end;
            end if;
      
      ELSE
            --l_result.message := apex_error.get_first_ora_error_text (p_error => p_error );
            null;
      END IF;
      
      -- We can also use the APEX_ERROR API to automatically find the 
      -- item the error was associated with, IF they're not already set.
      if l_result.page_item_name is null and l_result.column_alias is null then
            apex_error.auto_set_associated_item (
                p_error        => p_error,
                p_error_result => l_result );
        end if;
      
      
   END IF;   
   
  -- LAST thing we do before returning is log the error     
  --
  -- LOG THE UNKNOWN ERROR IN THE LOGGER TABLES
  --
  -- First build the log message
  l_logger_message  := 'Here''s the full error details:<p/>'||
              '<PRE>'||
              '<BR/><B>          MESSAGE:</B> '||p_error.message||
              '<BR/><B>  Additional Info:</B> '||p_error.additional_info||
              '<BR/><B> Display Location:</B> '||p_error.display_location||
              '<BR/><B> Association_Type:</B> '||p_error.Association_type||
              '<BR/><B>   Page Item Name:</B> '||p_error.page_item_name||
              '<BR/><B>        Region ID:</B> '||p_error.region_id||
              '<BR/><B>     Column Alias:</B> '||p_error.column_alias||
              '<BR/><B>          Row Num:</B> '||p_error.row_num||
              '<BR/><B>Is Internal Error:</B> '||case when p_error.is_internal_error = TRUE 
                                          THEN 'True'
                                          ELSE 'False'
                                     end||
              '<BR/><B>  APEX ERROR CODE:</B> '||p_error.apex_error_code||
              '<BR/><B>      ora_sqlcode:</B> '||p_error.ora_sqlcode||
              '<BR/><B>      ora_sqlerrm:</B> '||p_error.ora_sqlerrm||
              '<BR/><B>  Error Backtrace:</B><BR/>'||p_error.error_backtrace||
              '<BR/><B>   Component.type:</B> '||p_error.component.type||
              '<BR/><B>     Component.id:</B> '||p_error.component.id||
              '<BR/><B>   Component.name:</B> '||p_error.component.name||
              '<BR/><B> First Error Text:</B> '||apex_error.get_first_ora_error_text ( p_error => p_error )||
              '<BR/><B>   Application ID:</B> '||v('APP_ID')||
              '<BR/><B>          Page ID:</B> '||v('APP_PAGE_ID')||'<P/><pre/>' ;
  -- Generate a SCOPE string for logger so we can get a handle back on it
  -- Format   YYYY-MM-DD HH24.MI.SS:USER:APP:PAGE:SESSION
  --
  l_logger_scope := to_char(sysdate,'YYYY-MM-DD HH24.MI.SS')||':'||v('APP_USER')||':'||v('APP_ID')||':'||v('APP_PAGE_ID')||':'||v('APP_SESSION');
  -- Now create the log entry as an error so it captures the error stack.
  -- but remove the HTML
  l_logger_message := replace(l_logger_message, '<BR/>', chr(10));
  l_logger_message := replace(replace(l_logger_message, '<B>', '*'), '</B>', '*');
  -- logger.log_apex_items(p_text => l_logger_message, p_scope => l_logger_scope);
                              
  -- Now return the result record to the caller.
 
  RETURN l_result;
END error_handler_logging_session;


--============================================================================
-- F O R C E   P L / S Q L   E R R O R   
--============================================================================
PROCEDURE force_plsql_error
AS
    l_NUMBER number;
BEGIN
  l_number := 1/0;
END force_plsql_error;


end ks_error_handler;
/
