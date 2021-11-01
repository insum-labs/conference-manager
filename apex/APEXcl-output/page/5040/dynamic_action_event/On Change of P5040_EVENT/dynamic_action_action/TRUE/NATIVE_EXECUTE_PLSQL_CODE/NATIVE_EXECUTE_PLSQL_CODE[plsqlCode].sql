declare
    l_exists number := 0;
begin
    select 1
      into l_exists
      from dual
     where exists (
       select 1
         from ks_sessions
         where event_id = to_number(:P5040_EVENT_ID)
     );

    if l_exists > 0 then
       :P5040_POPULATED_WARNING := 1;
    end if;

exception
  when NO_DATA_FOUND then
     :P5040_POPULATED_WARNING := 0;    

end;

