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
 * Validate if the password respects the format rules
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall
 * @created November 12, 2018
 * @param p_password
 * @return boolean
 */
function is_invalid_password (
  p_password in ks_users.password%type  
)
return boolean
is 
  l_scope ks_log.scope := gc_scope_prefix || 'is_invalid_password';
  
  l_password ks_users.password%type;
  l_char_repetead number;
begin
  ks_log.log('START', l_scope);


  if length (p_password) < 10 then 
    return true;
  end if;

  l_password := upper (p_password);

  if (instr (l_password, 'QUERTY') > 0)
    or (instr (l_password, 'ASDFG') > 0)
    or (instr (l_password, 'ZXCFV') > 0)
    or (instr (l_password, '12345') > 0)
    or (instr (l_password, 'GHJKL') > 0)
    or (instr (l_password, 'YUIOP') > 0)
  then
   return true;
  end if;

  --passwords with a character repeated more than 4 times are not valid (ex: 'ppppassword')
  begin
    select  1
    into    l_char_repetead
    from    dual 
    where   regexp_like (p_password, '(.)\1{3,}');
  
    return true;
  exception
    when no_data_found then
      null;
  end;

  ks_log.log('END', l_scope);
  return false;
exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end is_invalid_password;



/**
 * Check if the given password match with the registered one.
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created September 2, 2016
 * @param p_username
 * @param p_password
 * @return boolean
 */
function password_match (
  p_username in ks_users.username%type 
 ,p_password in ks_users.password%type
)
return boolean
is
  l_scope ks_log.scope := gc_scope_prefix || 'password_match';

  l_retval boolean;
  l_password_db ks_users.password%type;
  l_salt salt_type;
  l_old_pass_hash password_type;
  l_new_pass_hash password_type;
begin
  ks_log.log('START', l_scope);

  select  u.password
  into    l_password_db
  from    ks_users u
  where   u.username = upper (p_username);

  l_old_pass_hash := SUBSTR (l_password_db, 1, INSTR (l_password_db, ':') - 1);
  l_salt := SUBSTR (l_password_db, INSTR (l_password_db, ':') + 1);

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
  ks_log.log('l_retval:' || case l_retval when true then 'true' else 'false' end, l_scope);
  ks_log.log('END', l_scope);
  
  return l_retval;
exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end password_match;



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
    
      l_retval := password_match (
         p_username => p_username
        ,p_password => p_password
      );

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



/**
 * Request a Password Reset for the user
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall
 * @created November 13, 2018
 * @param p_username
 * @param p_app_id
 */
 procedure request_reset_password (
    p_username in ks_users.username%type
  , p_app_id in ks_parameters.value%type
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'request_reset_password';

  c_not_equal_passwords constant varchar2(50) := 'Password and Repeat Passowrd must be the same.';
  c_password_not_valid constant varchar2(50) := 'The password is not valid.';

  l_id ks_users.id%type;
  l_temp_password ks_users.password%type;
begin
  ks_log.log('START', l_scope);

  begin
    select  u.id 
    into    l_id
    from    ks_users u
    where   u.username = upper (p_username)
    and     u.active_ind = 'Y';
  exception
    when no_data_found then
      --if p_username does not exist, no error must be shown
      ks_log.log('user ' || p_username || ' not found', l_scope);
      raise_application_error(-20001,'User not found');
  end;
  
  ks_log.log('l_id:' || l_id, l_scope);

  l_temp_password := dbms_random.string (
    opt => 'X'
   ,len => 6
  );

  update  ks_users 
  set     password = l_temp_password
         ,expired_passwd_flag = 'Y'
  where   id = l_id;

  ks_notification_api.notify_reset_pwd_request (
    p_id => l_id
   ,p_app_id => p_app_id
   ,p_password => l_temp_password
  );

  ks_log.log('END', l_scope);
exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end request_reset_password;



/**
 * Reset the user's password
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall
 * @created November 12, 2018
 * @param p_username
 * @param p_new_password
 * @param p_new_password_2
 * @param p_error_msg
 * @return
 */
 procedure reset_password (
    p_username in ks_users.username%type
  , p_new_password in ks_users.password%type
  , p_new_password_2 in ks_users.password%type
  , p_error_msg out varchar2
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'reset_password';

  c_not_equal_passwords constant varchar2(50) := 'Password and Repeat Passowrd must be the same.';
  c_password_not_valid constant varchar2(50) := 'The password is not valid.';

  l_id ks_users.id%type;
begin
  ks_log.log('START', l_scope);

  select  u.id 
  into    l_id
  from    ks_users u
  where   u.username = upper (p_username);

  if p_new_password != p_new_password_2 then
    p_error_msg := c_not_equal_passwords;
    return;
  end if;

  if is_invalid_password (p_new_password) then
    p_error_msg := c_password_not_valid;
    return;
  end if;

  update  ks_users 
  set     password = p_new_password
         ,expired_passwd_flag = null
         ,login_attempts = 0
  where   id = l_id;

  ks_notification_api.notify_reset_pwd_done (
    p_id => l_id
  );

  ks_log.log('END', l_scope);
exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end reset_password;


/**
 * Check if the username's password is expired
 *
 *
 * @example
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created November 13, 2018
 * @param p_username
 * @return boolean
 */
function is_password_expired (p_username in ks_users.username%type)
return boolean
is
begin
  for u in (
    select  1 
    from    ks_users 
    where   username = upper (p_username) 
    and     expired_passwd_flag = 'Y'
  )
  loop
    return true;
  end loop;
  return false;
end is_password_expired;


end ks_sec;
/
