select c.seq_id
     , c.track_name
     , c.session_count
     , decode(c.notify_ind, 'N', '-', '-check-') notify_chk
  from ks_session_load_coll_v c
 order by c.track_name