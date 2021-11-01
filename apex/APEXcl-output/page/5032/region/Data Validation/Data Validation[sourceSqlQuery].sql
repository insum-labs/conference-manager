select n001 as row_num,
       c049 as action,
       c001, c002, c003,
       c004, c005, c006,
       c007, c008, c009,
       c010, c011, c012,
       c013, c014, c015,
       c016, c017, c018,
       c019, c020, c021,
       c022, c023, c024,
       c025, c026, c027,
       c028, c029, c030,
       c031, c032, c033,
       c034, c035, c036,
       c037, c038, c040,
       c041, c042, c043,
       c044, c045
  from apex_collections
 where collection_name = 'LOAD_CONTENT'
   and c049 in ('INSERT','UPDATE', 'FAILED')
 order by seq_id