PRO .. ks_event_community_tracks 

-- drop table ks_event_community_tracks cascade constraints purge;

-- Keep table names under 24 characters
--           1234567890123456789012345
create table ks_event_community_tracks (
    id              number        generated by default on null as identity (start with 1) primary key not null
  , community_id    number        not null
  , track_id        number        not null
  , created_by      varchar2(60) default 
                    coalesce(
                        sys_context('APEX$SESSION','app_user')
                      , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                      , sys_context('userenv','session_user')
                    )
                    not null
  , created_on      date         default sysdate not null
  , updated_by      varchar2(60)
  , updated_on      date
  , constraint ks_community_tracks_fk foreign key ( community_id ) references ks_event_communities ( id ) not deferrable
  , constraint ks_event_community_tracks_fk foreign key ( track_id ) references ks_event_tracks ( id ) not deferrable
)
enable primary key using index
/

create unique index ks_event_community_tracks_u01 on ks_event_community_tracks(community_id, track_id);

comment on table ks_event_community_tracks is 'List of tracks in a community';

comment on column ks_event_community_tracks.id is 'Primary Key ID';
comment on column ks_event_community_tracks.created_by is 'User that created this record';
comment on column ks_event_community_tracks.created_on is 'Date the record was first created';
comment on column ks_event_community_tracks.updated_by is 'User that last modified this record';
comment on column ks_event_community_tracks.updated_on is 'Date the record was last modified';


--------------------------------------------------------
--                        123456789012345678901234567890
create or replace trigger ks_event_community_track_u_trg
before update
on ks_event_community_tracks
referencing old as old new as new
for each row
begin
  :new.updated_on := sysdate;
  :new.updated_by := coalesce(
                         sys_context('APEX$SESSION','app_user')
                       , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                       , sys_context('userenv','session_user')
                     );
end;
/
