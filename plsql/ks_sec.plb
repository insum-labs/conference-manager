set define off
-- alter session set PLSQL_CCFLAGS='CRYPTO_AVAILABLE:TRUE';
create or replace package body ks_sec
is

-- CONSTANTS
/**
 * @constant gc_scope_prefix Standard logger package name
 */
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';

/*****************************************************************************/
g_salt salt_type := 'rQ/PfG?Z8(C*4RP';
/*****************************************************************************/

/**
 * Validate a given user and password
 *
 * 
 *
 * @author Jorge Rimblas
 * @created September 2, 2016
 * @param p_username case insensitive username
 * @param p_password case sensitive password for the user login in
 * @return true/false
 */
function is_valid_user (
       p_username IN varchar2
     , p_password IN varchar2
)
   return boolean
is
  -- l_scope logger_logs.scope%type := gc_scope_prefix || 'load_sessions';
  -- l_params logger.tab_param;

  l_retval           boolean := FALSE;
  l_old_pass_w_salt  password_with_salt_type;
  l_old_pass_hash    password_type;
  l_new_pass_hash    password_type;
  l_salt             salt_type;
  l_active_ind       ks_users.active_ind%TYPE;

begin

   select password, active_ind
     into l_old_pass_w_salt
        , l_active_ind
     from ks_users
    where username = upper(p_username);

   if l_active_ind = 'Y' then
      l_old_pass_hash := SUBSTR(l_old_pass_w_salt, 1, INSTR(l_old_pass_w_salt, ':') - 1);
      l_salt := SUBSTR(l_old_pass_w_salt, INSTR(l_old_pass_w_salt, ':') + 1);

      $IF $$CRYPTO_AVAILABLE $THEN
      l_new_pass_hash := RAWTOHEX(dbms_crypto.hash(
         src => utl_raw.cast_to_raw(g_salt || p_password || l_salt),
         typ => dbms_crypto.HASH_SH512
      ));
      $ELSE
      -- old 
      -- 
      l_new_pass_hash := RAWTOHEX(dbms_obfuscation_toolkit.md5(
         input => utl_raw.cast_to_raw(g_salt || p_password || l_salt)
      ));
      $END

      l_retval := l_new_pass_hash = l_old_pass_hash;

      if l_retval then
        apex_util.set_authentication_result (p_code => C_AUTH_SUCCESS);
      else
        apex_util.set_authentication_result (p_code => C_AUTH_PASSWORD_INCORRECT);
      end if;

   else
     apex_util.set_authentication_result (p_code => C_AUTH_ACCOUNT_LOCKED);
   end if;

   return l_retval;

exception

  when NO_DATA_FOUND then
    -- Set APEX authentication Codes
    apex_util.set_authentication_result (p_code => C_AUTH_UNKNOWN_USER);
    return l_retval;

end is_valid_user;





/*****************************************************************************/
function password_with_salt (p_password IN varchar2)
   return varchar2
is
   l_retval password_with_salt_type;
   l_salt   salt_type;
begin

   l_salt := SUBSTR(SYS_GUID(), 1, 16);

   $IF $$CRYPTO_AVAILABLE $THEN
   l_retval := RAWTOHEX(dbms_crypto.hash(
      src => utl_raw.cast_to_raw(g_salt || p_password || l_salt),
      typ => dbms_crypto.HASH_SH512
   ));
   $ELSE
   l_retval := RAWTOHEX(dbms_obfuscation_toolkit.md5(
      input => utl_raw.cast_to_raw(g_salt || p_password || l_salt)
   ));
   $END

   l_retval := l_retval || ':' || l_salt;

   return l_retval;

end password_with_salt;




/**
 * Sets enrionmonet after user successfully logs in.
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created September 9, 2016
 * @param
 * @return
 */
procedure post_login
is
  -- l_scope  logger_logs.scope%type := gc_scope_prefix || 'post_login';
  -- l_params logger.tab_param;
begin
  -- logger.append_param(l_params, 'p_param1', p_param1);
  -- logger.log('BEGIN', l_scope, null, l_params);

  apex_util.set_session_state(
      p_name  => 'G_ADMIN'
    , p_value => case when apex_authorization.is_authorized('ADMIN') then 'YES' else 'NO' end
  );

  -- logger.log('END', l_scope, null, l_params);

  exception
    when OTHERS then
      -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
      raise;
end post_login;

end ks_sec;
/
