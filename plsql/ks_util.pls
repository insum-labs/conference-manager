create or replace package ks_util
as

type gc_clob_arr_type is table of clob;

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


---------------------------------------------------------------------------------
function blob2clob(
  p_blob in blob,
  p_blob_csid in integer default dbms_lob.default_csid)
  return clob;

function replace_tokens (p_string in varchar2,
                         p_tokens in varchar2,
                         p_token_exceptions in varchar2)
 return varchar2;

function clob_to_varchar2_table (p_clob in out nocopy clob)
  return gc_clob_arr_type;


end ks_util;
/
