delete
from ks_tag_type_sums t
where t.content_type = 'SESSION' || ':' || :P1_TRACK_ID
  and t.tag_count = 0;