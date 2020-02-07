declare 
  l_admin_app_id ks_parameters.value%type;
begin
  l_admin_app_id := ks_util.get_param ('ADMIN_APP_ID');
  
  ks_sec.request_reset_password (
      p_username => :P5115_EMAIL
    , p_app_id => l_admin_app_id
  );
end;