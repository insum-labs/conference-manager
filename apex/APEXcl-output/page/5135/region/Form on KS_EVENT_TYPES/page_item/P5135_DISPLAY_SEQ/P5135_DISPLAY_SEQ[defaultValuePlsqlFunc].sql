declare
  i number;
begin
  select nvl(max(display_seq), 0) + 10
    into i
  from ks_event_types;

  return i;
end;