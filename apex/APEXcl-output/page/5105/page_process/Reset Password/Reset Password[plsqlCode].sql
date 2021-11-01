declare 
  l_admin_app_id ks_parameters.value%type;
begin

  update  ks_users
  set     active_ind = 'Y'
         ,login_attempts = 0
  where   id = :P5105_ID;

  l_admin_app_id := ks_util.get_param('ADMIN_APP_ID');

  ks_sec.request_reset_password (
      p_username => :P5105_USERNAME
    , p_app_id => l_admin_app_id
  );
  
end;