create or replace package body ks_util
as

--------------------------------------------------------------------------------
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';


--------------------------------------------------------------------------------
function get_param(
  p_name_key  in ks_parameters.name_key%TYPE
)
return varchar2
is
  l_value ks_parameters.value%TYPE;
begin

  select value
    into l_value
    from ks_parameters
   where name_key = p_name_key;

  return l_value;

exception
  when NO_DATA_FOUND then
    return null;

end get_param;



--------------------------------------------------------------------------------
procedure set_param(
    p_name_key      in ks_parameters.name_key%TYPE
  , p_value         in ks_parameters.value%TYPE
)
is
begin

  update ks_parameters
     set value = p_value
   where name_key = p_name_key;

  if sql%rowcount = 0 then
    raise_application_error(
        -20001
      , 'Parameter ' || p_name_key || ' does not exist.'
    );
  end if;

end set_param;


--------------------------------------------------------------------------------
function get_email(
    p_username  in ks_users.username%TYPE
)
return varchar2
is
  -- l_scope   logger_logs.scope%type := gc_scope_prefix || 'get_email';
  -- l_params  logger.tab_param;

  l_email ks_users.email%TYPE;
begin
  -- logger.append_param(l_params, 'p_username', p_username);
  -- logger.log('START', l_scope, null, l_params);

  select email
    into l_email
    from ks_users
   where username = p_username;

  return l_email;

exception
  when NO_DATA_FOUND then
    -- logger.log_error('Probably an invalid user.');
    return null;

end get_email;




function format_full_name
(
   p_first_name      IN      ks_users.first_name%TYPE,
   p_last_name       IN      ks_users.last_name%TYPE
)  RETURN VARCHAR2
IS
  -- l_scope logger_logs.scope%type := gc_scope_prefix || 'format_full_name';
  -- l_params logger.tab_param;
begin
--  logger.append_param(l_params, 'p_text', p_text);

  RETURN rtrim(p_first_name || ' ' || p_last_name);

exception
    when OTHERS then
      -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
      raise;
end format_full_name;






function is_number
(
  p_value        in         varchar2
) return boolean
is
  -- l_scope             logger_logs.scope%type := gc_scope_prefix || 'is_number';
  -- l_params            logger.tab_param;

  non_numeric      exception;
  pragma exception_init (non_numeric, -06502);

  l_number     number;
begin
   l_number := p_value;

   return true;

exception
  when non_numeric then
    return false;
end is_number;





function string_to_coll (p_string in VARCHAR2) return sys.ODCIVarchar2List
is
  l_table wwv_flow_global.vc_arr2;
  l_list  sys.ODCIVarchar2List := new sys.ODCIVarchar2List();
begin
  l_table := apex_util.string_to_table(p_string);
  l_list.extend(l_table.count());
  for i in 1..l_table.count()
  loop
    l_list(i) := l_table(i);
  end loop;
  return l_list;
end string_to_coll;




function get_ir_order_by(p_ir_query    in varchar2
                       , p_default_pk  in varchar2 default '"ID"'
         )
  return varchar2
is
  -- l_scope             logger_logs.scope%type := gc_scope_prefix || 'get_ir_order_by';
  -- l_params            logger.tab_param;

  l_order_by          varchar2(32000);
  l_instr             number;
begin
  -- logger.log('START', l_scope, null, l_params);

  l_instr := instr (p_ir_query, 'order by', -1);

  if l_instr > 0
  then
     -- grab the final order by from the IR query and trim off any trailing ")"
     l_order_by := rtrim (substr (p_ir_query, l_instr), ')');

  else -- add default order by for use by analytics lead/gag functions
    l_order_by := 'order by ' || p_default_pk; -- Use a column that's always present
  end if;

  -- logger.log('order by:' || l_order_by, l_scope, null, l_params);
  return l_order_by;

exception
  when others then
    null;
end get_ir_order_by;





function get_ir_report(p_page_id   in number
                     , p_static_id in varchar2)
  return apex_ir.t_report
is
  -- l_scope             logger_logs.scope%type := gc_scope_prefix || 'get_ir_report';
  -- l_params            logger.tab_param;

  l_region_id          number;
begin
  -- logger.append_param(l_params, 'p_page_id', p_page_id);
  -- logger.append_param(l_params, 'p_static_id', p_static_id);
  -- logger.log('START', l_scope, null, l_params);

  select region_id
    into l_region_id
    from apex_application_page_regions
   where static_id = p_static_id
     and page_id   = p_page_id
     and application_id = (select v('APP_ID') from dual);

  return apex_ir.get_report
         (
            p_page_id   => p_page_id
          , p_region_id => l_region_id
         );

exception
    when OTHERS then
      -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
      raise;
end get_ir_report;


/**
  * Converts blob to clob
  *
  * Notes:
  *  - Copied from OOS Utils https://github.com/OraOpenSource/oos-utils/blob/master/source/packages/oos_util_lob.pkb
  *
  */
 function blob2clob(
   p_blob in blob,
   p_blob_csid in integer default dbms_lob.default_csid)
   return clob
 as
   l_clob clob;
   l_dest_offset integer := 1;
   l_src_offset integer := 1;
   l_lang_context integer := dbms_lob.default_lang_ctx;
   l_warning integer;
 begin
   if p_blob is null then
     return null;
   end if;

   dbms_lob.createtemporary(
     lob_loc => l_clob,
     cache => false);

   dbms_lob.converttoclob(
     dest_lob => l_clob,
     src_blob => p_blob,
     amount => dbms_lob.lobmaxsize,
     dest_offset => l_dest_offset,
     src_offset => l_src_offset,
     blob_csid => p_blob_csid,
     lang_context => l_lang_context,
     warning => l_warning);

   return l_clob;
 end blob2clob;



--==============================================================================
-- Function: clob_to_varchar2_table
-- Purpose: takes a clob and returns it as a table of varchar2s with size 4000
--
-- Inputs:  p_clob - the clob to be passed in
-- Output:
-- Scope: Publicly accessible
-- Errors: Logged and Raised.
-- Notes:  Some of this code taken from https://stackoverflow.com/questions/11647041/reading-clob-line-by-line-with-pl-sql
-- Author: Ben Shumway (Insum Solutions) - Oct/26/2017
--==============================================================================
function clob_to_varchar2_table (p_clob in out nocopy clob)
  return gc_clob_arr_type
is
  l_scope varchar2(255) := gc_scope_prefix || 'clob_to_varchar2_table';
  l_varchar2s gc_clob_arr_type;
  l_varchar2 varchar2(4000);
  l_offset number := 1;
  l_amount number := 3000;
  len    number;
  i number := 1;
begin

  ks_log.log('START', l_scope);

  l_varchar2s := gc_clob_arr_type();

  if p_clob is null
  then
    return l_varchar2s;
  end if;

  if ( dbms_lob.isopen(p_clob) != 1 ) then
    dbms_lob.open(p_clob,0);
  end if;

  len := dbms_lob.getlength(p_clob);

  while(l_offset < len)
  loop
    -- ks_log.log('inside main loop "while(l_offset < len)"', l_scope);
    dbms_lob.read(p_clob, l_amount, l_offset, l_varchar2);
    l_offset := l_offset + l_amount;
    l_varchar2s.extend;
    -- ks_log.log('len: ' || len || ', l_offset: ' || l_offset || ', l_varchar2: ' || l_varchar2, 'l_scope');
    l_varchar2s(i) := l_varchar2;
    i := i + 1;
  end loop;

  if ( dbms_lob.isopen(p_clob) = 1 ) then
    dbms_lob.close(p_clob);
  end if;


  return l_varchar2s;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end  clob_to_varchar2_table;


--==============================================================================
-- Function: tokenize_string
-- Purpose: helper function for html_whitelist_tokenize
--
-- Inputs:  p_string - the to have its tokens replaced
--          p_tokens - a string containing the tokens
-- Output:
-- Scope: Publicly accessible
-- Errors: logged and raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/27/2017
--==============================================================================
function replace_tokens (p_string in varchar2,
                         p_tokens in varchar2,
                         p_token_exceptions in varchar2)
 return varchar2
is
  l_scope varchar2(255) := gc_scope_prefix || 'tokenize_string';

  l_output         varchar2(32767);
  l_tokens_table   apex_application_global.vc_arr2;
  l_tokens         varchar2(4000);
  found_match      boolean := true;
  l_index          number := -1;
  l_regex          varchar2(4000);
  l_infinite_check number := 0;
begin
  -- ks_log.log('BEGIN', l_scope);
  -- ks_log.log(p_tokens, l_scope);

  if trim(p_tokens) is null
  then
    return p_string;
  end if;


  --Cleanse p_tokens so that it only contains alphanumeric characters.
  --Get rid of all non-alphanumerics
  l_tokens := regexp_replace(p_tokens, '[^A-Za-z0-9]', ' ');
  --Remove from tokens the token exceptions
  l_tokens := regexp_replace(l_tokens, p_token_exceptions, '', 1, 0, 'i');
  --Get rid of all multiple spaces so that everything is only one space apart
  l_tokens := regexp_replace(l_tokens, '\s{2,}', ' ');

  l_tokens := trim(l_tokens);
  --Replace spaces with |
  l_tokens := regexp_replace(l_tokens, '\s', '|');

  -- ks_log.log(l_tokens, l_scope);

  --I wanted to use something like the oneliner below, but pl/sql doesn't support lookaheads (yet)
  --l_output := regexp_replace(p_string, '(\W)('|| l_tokens || ')(?=\W)', '\1XXXX', 1, 0, 'i');


  l_regex := '(^|\W)(' || l_tokens || ')(\W|$)';
  --ks_log.log('l_regex:' || l_regex, l_scope);


  l_output := p_string;
  --ks_log.log(l_output, l_scope);

  while(l_index != 0)
  loop

    l_index  := regexp_instr(l_output, l_regex, 1, 1, 0, 'i');

    if(l_index != 0)
    then
      --ks_log.log('Found match at index ' || l_index, l_scope);
      l_output := regexp_replace(l_output, l_regex, '\1💩\3', l_index, 1, 'i');

    end if;

    l_infinite_check := l_infinite_check + 1;
    if l_infinite_check > 9999
    then
      --Something's gone wrong
      raise_application_error(-20001, 'Error Tokenizing Data');
    end if;

  end loop;

  ks_log.log('> ' || l_output, l_scope);

  return l_output;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end replace_tokens;
/**
 * Given IR type, determine if there are any filters applied
 * Filters are identified by the precense of the :APXWS_EXPR_n and
 * :APXWS_SEARCH_STRING_n binds
 *
 * @author Jorge Rimblas
 * @created October 11, 2019
 * @param p_ir_t An IR type apex_ir.t_report
 * @return boolean
 */
function ir_has_filters(
    p_ir_t      in apex_ir.t_report
)
  return boolean
is
  l_scope             logger_logs.scope%type := gc_scope_prefix || 'ir_has_filters';
  l_params            logger.tab_param;
  l_bind     apex_plugin_util.t_bind;
  l_index    pls_integer;
  l_found    boolean;
begin
--  logger.log('START', l_scope, null, l_params);

  l_index := p_ir_t.binds.first;
  l_found := false;
  while (l_index is not null and not l_found)
  loop
--    logger.log('p_ir_t.binds(l_index):' || p_ir_t.binds(l_index).name || ':' || p_ir_t.binds(l_index).value, l_scope, null, l_params);
    -- Search for binds named APXWS_EXPR_n
    if  p_ir_t.binds(l_index).name like 'APXWS_EXPR%'
     or p_ir_t.binds(l_index).name like 'APXWS_SEARCH_STRING%' then
      l_found := true;
    end if;
    l_index := p_ir_t.binds.next(l_index);
  end loop;
  return l_found;
exception
    when OTHERS then
--      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      raise;
end ir_has_filters;
end ks_util;
/
