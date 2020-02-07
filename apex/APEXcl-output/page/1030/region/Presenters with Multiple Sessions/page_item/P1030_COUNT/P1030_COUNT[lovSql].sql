select level d, level r
 from dual
 connect by level < 5
order by 1 desc