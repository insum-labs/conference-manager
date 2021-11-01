apex_util.set_preference('DEFAULT_TRACK_ID', :P1_SELECT_TRACK_ID);

-- SESSIONTAGFILTER_top_clear
ks_tags_api.maintain_filter_coll(
    p_coll   => 'SESSIONTAGFILTER'
  , p_sub    => :P1_SELECT_TRACK_ID
  , p_id     => 'top'
  , p_status => 'NO');
