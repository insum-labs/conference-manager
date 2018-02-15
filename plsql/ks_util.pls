create or replace package ks_util
as

--------------------------------------------------------------------------------
function get_param(
  p_name_key  in ks_parameters.name_key%TYPE
)
return varchar2;

--------------------------------------------------------------------------------
procedure set_param(
    p_name_key  in ks_parameters.name_key%TYPE
  , p_value     in ks_parameters.value%TYPE
);


--------------------------------------------------------------------------------
function get_email(
    p_username  in ks_users.username%TYPE
)
return varchar2;


--------------------------------------------------------------------------------
function format_full_name 
(
   p_first_name      IN      ks_users.first_name%TYPE,
   p_last_name       IN      ks_users.last_name%TYPE
)  RETURN VARCHAR2;


--------------------------------------------------------------------------------
function is_number
(
  p_value        in         varchar2
) return boolean;

--------------------------------------------------------------------------------
function string_to_coll (p_string in varchar2) return sys.ODCIVarchar2List;

--------------------------------------------------------------------------------
function get_ir_order_by(p_ir_query    in varchar2
                       , p_default_pk  in varchar2 default '"ID"'
         ) 
  return varchar2;

--------------------------------------------------------------------------------
function get_ir_report(p_page_id   in number
                     , p_static_id in varchar2)
  return apex_ir.t_report;


end ks_util;
/
