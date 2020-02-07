select 1
  from ks_load_mapping
 where display_seq = to_number (:P5050_DISPLAY_SEQ )
   and id != nvl(to_number(:P5050_ID), -1)