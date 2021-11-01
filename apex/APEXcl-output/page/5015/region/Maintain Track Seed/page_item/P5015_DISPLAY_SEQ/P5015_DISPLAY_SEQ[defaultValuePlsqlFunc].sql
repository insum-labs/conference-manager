declare
  i number;
begin
  select nvl(max(display_seq), 0) + 10
    into i
  from ks_tracks;

  return i;
end;