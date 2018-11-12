set define off
-- alter session set PLSQL_CCFLAGS='CRYPTO_AVAILABLE:TRUE';
create or replace package body ks_sec
is

-- CONSTANTS
/**
 * @constant gc_scope_prefix Standard logger package name
 * @constance c_max_attempts Maximumn number of invalid login attempts
 */
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
c_max_attempts  constant number := 5;

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
  l_user_id          ks_users.id%TYPE;
  l_active_ind       ks_users.active_ind%TYPE;
  l_login_attempts   ks_users.login_attempts%TYPE;
  l_expired_passwd_flag ks_users.expired_passwd_flag%TYPE;

begin

   select id, password, active_ind, expired_passwd_flag, nvl(login_attempts, 0)
     into l_user_id
        , l_old_pass_w_salt
        , l_active_ind
        , l_expired_passwd_flag
        , l_login_attempts
     from ks_users
    where username = upper(p_username);

   if l_active_ind = 'Y' and l_login_attempts < c_max_attempts then
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
        update ks_users
           set login_attempts = 0
             , last_login_date = sysdate
         where id = l_user_id;
      else
        apex_util.set_authentication_result (p_code => C_AUTH_PASSWORD_INCORRECT);
        update ks_users
           set login_attempts = nvl(login_attempts,0) + 1
             , active_ind = case when nvl(login_attempts,0) + 1 >= c_max_attempts then 'N' else active_ind end
         where id = l_user_id;
      end if;

   else
     apex_util.set_authentication_result (p_code => C_AUTH_ACCOUNT_LOCKED);
     update ks_users
        set active_ind = 'N'
      where id = l_user_id
        and active_ind = 'Y';
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


/**
 * Get the name for a given user
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created November 8, 2018
 * @param name
 * @return
 */
function get_name_from_user(p_username in varchar2) return varchar2
is
  l_scope  ks_log.scope := gc_scope_prefix || 'get_name_from_user';
begin
  ks_log.log('START', l_scope);

  for n in (select full_name from ks_users_v where username = p_username)
  loop
    return n.full_name;
  end loop;
  
  if instr(p_username, '@') > 0 then
      return regexp_replace ( initcap( replace( substr ( p_username, 1, instr(p_username, '@') - 1 ), '.', ' ' ) ), '\s\w+\s', ' ' );
  else
      return initcap(p_username);
  end if;


  exception
    when OTHERS then
      ks_log.log_error('Unhandled Exception', l_scope);
      raise;
end get_name_from_user;



end ks_sec;
/
