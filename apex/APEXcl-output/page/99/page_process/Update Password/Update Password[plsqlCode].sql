update ks_users
  set password = :P99_PASSWORD
    , login_attempts = 0
    , expired_passwd_flag = null
where username = :APP_USER;