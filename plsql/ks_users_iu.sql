create or replace trigger ks_users_iu
before insert or update
on ks_users
referencing old as old new as new
for each row
declare
  l_pass_w_salt ks_users.password%TYPE;
begin
  if updating then
    :new.updated_on := sysdate;
    :new.updated_by := coalesce(
                           sys_context('APEX$SESSION','app_user')
                         , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                         , sys_context('userenv','session_user')
                       );
  end if;

  if :new.password is not null AND nvl(:new.password,'~NA~') != nvl(:old.password,'~NA~') then
    l_pass_w_salt := ks_sec.password_with_salt(:new.password);
    :new.password := l_pass_w_salt;
  else
    :new.password := :old.password;
  end if;
end;
/
alter trigger ks_users_iu enable;
