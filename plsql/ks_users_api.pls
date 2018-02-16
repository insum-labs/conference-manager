create or replace package ks_users_api
as

--------------------------------------------------------------------------------
--*
--* Recieves the User information (Existing User, First Name, Last Name,
--* Email, Password, Is Admin) and Event / Track information (Event Id,
--* Track Id, Selection and Voting Role) and inserts this data into the
--* user table (ks_user) and/or relational table (ks_user_event_track_roles).
--*
--------------------------------------------------------------------------------
procedure set_user_information (
	p_existing_user    in   ks_users.username%TYPE,
	p_first_name       in   ks_users.first_name%TYPE,
	p_last_name        in   ks_users.last_name%TYPE,
	p_email            in   ks_users.email%TYPE,
	p_password         in   ks_users.password%TYPE,
	p_is_admin         in   ks_users.admin_ind%TYPE,
	p_event_id         in   ks_event_tracks.event_id%TYPE,
	p_track_id         in   ks_event_tracks.id%TYPE,
	p_selection_code   in   ks_roles.code%TYPE,
	p_voting_code      in   ks_roles.code%TYPE,
	p_external_sys_ref in   ks_users.external_sys_ref%TYPE
);

end ks_users_api;
/
