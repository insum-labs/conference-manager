PRO seed ks_event_tracks

SET DEFINE OFF;

-- Insert tracks for events (All for Kscope17, APEX only for Kscope16)
insert into ks_event_tracks (event_id, display_seq, name, alias, active_ind)
select e.id, t.display_seq, t.name, t.alias, t.active_ind
  from ks_tracks t
     , ks_events e
 where t.active_ind = 'Y'
   and e.active_ind = 'Y'
   -- and ((e.name = 'Kscope16' and t.alias = 'APEX') 
   --    or e.name = 'Kscope17'
   -- )
/
