select column_name d, column_name r
  from user_tab_cols
 where table_name = 'KS_FULL_SESSION_LOAD'
   and column_name not in ('APP_USER')
 minus
 select to_column_name, to_column_name
  from ks_load_mapping 
union all
select to_column_name d, to_column_name r
  from KS_LOAD_MAPPING
 where id = to_number (:P5050_ID) 
order by 1