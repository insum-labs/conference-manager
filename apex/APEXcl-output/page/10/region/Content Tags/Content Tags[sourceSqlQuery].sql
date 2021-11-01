select t.tag id
     , t.tag
     , t.tag_count
from ks_tag_type_sums t
where t.content_type = 'SESSION' || ':' || :P1_TRACK_ID
