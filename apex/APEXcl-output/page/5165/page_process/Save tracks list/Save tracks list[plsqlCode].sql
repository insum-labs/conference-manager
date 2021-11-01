declare
  l_tracks     varchar2(4000) := :P5165_TRACK_LIST;
  l_tracks_arr apex_t_varchar2;
  l_community_id number(32) := to_number(:P5165_COMMUNITY_ID);
  l_exists number(1);
begin  
  apex_debug.message (p_message => 'START Save track list process');
  l_tracks_arr := apex_string.split(p_str => l_tracks, p_sep => ':'); 
  delete 
    from ks_event_community_tracks
   where community_id = l_community_id
    and ':' || :P5165_TRACK_LIST || ':' not like '%:' || to_char (track_id) || ':%';
  apex_debug.message (p_message => '..deleted total of ' || sql%rowcount || ' row(s)');
  
  for idx in 1..l_tracks_arr.count
  loop
    begin
     select 1 into l_exists 
       from ks_event_community_tracks
      where community_id = l_community_id
        and track_id =  l_tracks_arr(idx);
    exception
      when no_data_found then
        apex_debug.message (p_message => '..insert row with track_id ' || l_tracks_arr(idx) || ' and community_id ' || l_community_id);
        insert into ks_event_community_tracks(community_id, track_id) 
         values (l_community_id, l_tracks_arr(idx));
    end;  
  end loop;
  
  apex_debug.message (p_message => 'END Save track list process');
end;