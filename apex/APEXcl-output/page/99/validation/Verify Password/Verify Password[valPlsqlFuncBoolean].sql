if :P99_PASSWORD_ORIG is null then
  return false;
else
  return ks_sec.is_valid_user(:APP_USER, :P99_PASSWORD_ORIG);
end if;