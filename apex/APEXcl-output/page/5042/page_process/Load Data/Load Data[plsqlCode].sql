:P5042_TEMPLATE := ks_util.get_param('LOAD_NOTIFICATION_TEMPLATE');
:P5042_NOTIFY_OWNER := 'OWNER';
:P5042_NOTIFY_VOTER := null;
select count(*) 
  into :P5042_TRACK_COUNT
  from ks_session_load_coll_v;