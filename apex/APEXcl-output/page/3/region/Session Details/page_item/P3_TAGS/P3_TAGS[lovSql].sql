select tag d, tag r
  from ks_tag_type_sums
 where content_type = 'SESSION' || ':' || :P3_EVENT_TRACK_ID
 order by tag_count desc, tag