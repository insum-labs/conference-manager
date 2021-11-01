declare
  s number;
begin
  -- shift all the sequences before the update and avoid the unique error
  for i in 1..apex_application.g_f01.count loop
    update ks_load_mapping
       set display_seq = 10000 + display_seq
    where id = to_number(apex_application.g_f01(i));
  end loop;
  
  for i in 1..apex_application.g_f01.count loop
   s := i * 10;
   update ks_load_mapping
      set display_seq = s
    where id = to_number(apex_application.g_f01(i));
  end loop;
  htp.prn('{"result":"OK"}');
  exception
    when OTHERS then
      apex_json.open_object;
      apex_json.write('result', 'ERROR');
      apex_json.write('message', SQLERRM);
      apex_json.close_object;
end;
