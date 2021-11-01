-- SESSIONTAGFILTER_top_clear
ks_tags_api.maintain_filter_coll(
    p_coll   => 'SESSIONTAGFILTER'
  , p_sub    => :P1_TRACK_ID
  , p_id     => 'top'
  , p_status => 'NO');
