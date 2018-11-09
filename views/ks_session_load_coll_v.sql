PRO ks_session_load_coll_v
create or replace view ks_session_load_coll_v
as
select seq_id
     , n001 track_id
     , c001 track_name
     , n002 session_count
     , c002 notify_ind
  from apex_collections
 where collection_name = 'LOADED_SESSIONS'
/