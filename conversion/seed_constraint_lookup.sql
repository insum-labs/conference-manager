prompt seed constraint_lookup

SET DEFINE OFF;
insert into constraint_lookup (constraint_name,message) values ('KS_USERS_U01','User already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_USERS_U02','Email already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_SESSIONS_U01','Session already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_TRACKS_U01','Track already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_OWNER_FK','Owner already assigned, cannot change.');
  
