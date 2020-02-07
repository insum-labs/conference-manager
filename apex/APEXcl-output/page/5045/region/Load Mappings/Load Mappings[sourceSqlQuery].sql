with not_mapped_column as 
(
  select column_name to_column_name
       , table_name
    from user_tab_cols
   where table_name = 'KS_FULL_SESSION_LOAD'
     and column_name not in ('APP_USER')
   minus
   select to_column_name
        , table_name
    from ks_load_mapping 
 )
select m.id
     , m.display_seq
     , m.table_name
     , m.header_name
     , m.to_column_name 
     , 'Y' mapped_ind
     , '' disabled_class
from ks_load_mapping m  
union all
select null id
     , null display_seq
     , mc.table_name
     , null header_name
     , mc.to_column_name
     , 'N' mapped_ind
     , 'disabled' disabled_class
  from not_mapped_column mc