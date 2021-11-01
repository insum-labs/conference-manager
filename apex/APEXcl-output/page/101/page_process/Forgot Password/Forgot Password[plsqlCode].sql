declare
  l_admin_app_id ks_parameters.value%type;  
begin
  l_admin_app_id  := ks_util.get_param ('ADMIN_APP_ID');

  ks_sec.request_reset_password (
    p_username => :P101_USERNAME
   ,p_app_id => l_admin_app_id
  );
exception
  when ks_sec.user_not_found then
  --We don't want the UI show an error message to avoid a malicious user to know if a user is registered.
    null;
end;