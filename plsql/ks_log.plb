alter session set PLSQL_CCFLAGS='LOGGER:FALSE';
create or replace package body ks_log
is

--------------------------------------------------------------------------------
-- TYPES
/**
 * @type
 */

-- CONSTANTS
/**
 * @constant gc_scope_prefix Standard logger package name
 */
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';



------------------------------------------------------------------------------
/**
 * Description
 *
 *
 * @example
 *
 * @issue
 *
 * @author Jorge Rimblas
 * @created October 11, 2017
 * @param
 * @return
 */
procedure log(p_msg in varchar2, p_scope  in varchar2)
is
begin

  $IF $$LOGGER $THEN
  logger.log(p_msg, p_scope);
  $ELSE
  apex_debug.message(p_scope || ':' || substr(p_msg,1,3000));
  $END

end log;


procedure log_error(p_msg in varchar2, p_scope  in varchar2)
is
begin

  $IF $$LOGGER $THEN
  logger.log_error(p_msg, p_scope);
  $ELSE
  apex_debug.message(p_scope || ': ' || p_msg);
  $END

end log_error;




end ks_log;
/
