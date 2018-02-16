--------------------------------------------------------
-- Replace previosul trigger
create or replace trigger ks_sessions_iu_trg 
before insert or update
on ks_sessions
referencing old as old new as new
for each row
begin
  if updating then
    :new.updated_on := sysdate;
    :new.updated_by := coalesce(
                          sys_context('APEX$SESSION','app_user')
                        , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                        , sys_context('userenv','session_user')
                       );
  end if;

  if   inserting
    or (updating and :new.event_track_id = :old.event_track_id)
  then 
    ks_tags_api.tag_sync(
        p_new_tags      => :new.tags
      , p_old_tags      => :old.tags
      , p_content_type  => 'SESSION' || ':' || :new.event_track_id
      , p_content_id    => :new.session_num );
      
  else --We are updating AND our event_track_id changed
    ks_tags_api.tag_sync(
        p_new_tags      => null
      , p_old_tags      => :old.tags
      , p_content_type  => 'SESSION' || ':' || :old.event_track_id
      , p_content_id    => :new.session_num );

    ks_tags_api.tag_sync(
        p_new_tags      => :new.tags
      , p_old_tags      => null
      , p_content_type  => 'SESSION' || ':' || :new.event_track_id
      , p_content_id    => :new.session_num );

  end if;

end;
/

create or replace trigger ks_sessions_bd_trg
    before delete on ks_sessions
    for each row
begin
  ks_tags_api.tag_sync(
      p_new_tags      => null
    , p_old_tags      => :old.tags
    , p_content_type  => 'SESSION' || ':' || :old.event_track_id
    , p_content_id    => :old.session_num );
end;
/
-- ========================================
