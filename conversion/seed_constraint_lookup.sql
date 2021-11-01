prompt seed constraint_lookup

SET DEFINE OFF;
delete from constraint_lookup;
insert into constraint_lookup (constraint_name,message) values ('KS_USERNAME_U','User already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_USERS_U01','User already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_USERS_U02','Email already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_SESSIONS_U01','Session already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_TRACKS_U01','Track already exists.');
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_OWNER_FK','Owner already assigned, cannot change.');

insert into constraint_lookup (constraint_name,message) values ('KS_USER_EVT_TRK_ROLE_U1','User already assigned to a track.');
insert into constraint_lookup (constraint_name,message) values ('KS_USER_EVT_TRK_ROLE_USER_FK','User cannot be deleted. Remove all assignments for this user first.');
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_TYPE_U','That code is already in use.');
insert into constraint_lookup (constraint_name,message) values ('KS_EVENTS_EVENT_TYPE_FK','Cannot delete an event type that is in use already.');

--- Add New Constrainst Below ----
-- vvvvvvvvvvvvvvvvvvvvvvvvvvvv --
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_COMMUNITY_TRACKS_U01','That track is already part of the community.');
insert into constraint_lookup (constraint_name,message) values ('KS_COMMUNITY_TRACKS_FK','The community cannot be removed when it has tracks.');
insert into constraint_lookup (constraint_name,message) values ('KS_EVENT_COMMUNITY_TRACKS_FK', 'The track cannot be removed if it is associated with a community.');
  