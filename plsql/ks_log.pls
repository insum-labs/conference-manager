create or replace package ks_log
is

--------------------------------------------------------------------------------
--*
--*
--*
--------------------------------------------------------------------------------

subtype scope is varchar2(61);
-- logger_logs.scope%type

--------------------------------------------------------------------------------
procedure log(p_msg  in varchar2, p_scope  in varchar2);

procedure log_error(p_msg  in varchar2, p_scope  in varchar2);


end ks_log;
/
