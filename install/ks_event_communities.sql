PRO .. ks_event_communities 

-- drop table ks_event_communities cascade constraints purge;

-- Keep table names under 24 characters
--           1234567890123456789012345
create table ks_event_communities (
    id              number        generated by default on null as identity (start with 1) primary key not null
  , event_id        number        not null
  , name            varchar2(60)  not null
  , active_ind      varchar2(1)   not null
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
  , constraint ks_event_communities_ck_active
      check (active_ind in ('Y', 'N'))
  , constraint ks_event_communities_fk foreign key ( event_id ) references ks_events ( id ) not deferrable
)
enable primary key using index
/

comment on table ks_event_communities is 'List of Communities';

comment on column ks_event_communities.id is 'Primary Key ID';
comment on column ks_event_communities.active_ind is 'Is the record enabled Y/N?';
comment on column ks_event_communities.created_by is 'User that created this record';
comment on column ks_event_communities.created_on is 'Date the record was first created';
comment on column ks_event_communities.updated_by is 'User that last modified this record';
comment on column ks_event_communities.updated_on is 'Date the record was last modified';


--------------------------------------------------------
--                        123456789012345678901234567890
create or replace trigger ks_event_communities_u_trg
before update
on ks_event_communities
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
