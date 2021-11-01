declare 
  l_error_msg varchar2(4000);
begin   
  ks_sec.reset_password (
     p_username => :P102_USERNAME
    ,p_new_password => :P102_PASSWORD
    ,p_new_password_2 => :P102_PASSWORD_VERIFY
    ,p_error_msg => l_error_msg
  );
  
  if l_error_msg is not null then
      raise_application_error( -20001, l_error_msg);
  end if;
end;