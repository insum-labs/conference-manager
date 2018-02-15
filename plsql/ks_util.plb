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



end ks_util;
/
