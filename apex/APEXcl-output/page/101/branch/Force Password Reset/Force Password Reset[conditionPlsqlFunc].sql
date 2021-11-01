declare
  l_expired_passwd_flag ks_users.expired_passwd_flag%TYPE;
  l_old_pass_w_salt ks_sec.password_type;
begin

  if :REQUEST in ('LOGIN','P101_PASSWORD') 
         and :P101_USERNAME is not null 
         and :P101_PASSWORD is not null then
    if ks_sec.is_password_expired (:P101_USERNAME) then
         
      select  u.password
      into    l_old_pass_w_salt
      from    ks_users u
      where   u.username = upper (:P101_USERNAME);

      return ks_sec.password_match (
         p_username => :P101_USERNAME
        ,p_password => :P101_PASSWORD
      );

    end if;
  end if;

  return false;

end;