create or replace package body ks_users_api
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
)
is

	l_is_active ks_users.active_ind%TYPE := 'Y';
	l_user_id ks_users.id%TYPE;
	l_username ks_users.username%TYPE;
	l_user_event_track_role ks_user_event_track_roles.id%TYPE;
	
begin

	if p_existing_user is null then
		
		ks_user_dml.ins_ks_users(
			l_user_id,
			upper(p_email),
			p_password,
			p_first_name,
			p_last_name,
			p_email,
			l_is_active,
			p_is_admin,
			p_external_sys_ref
		);
		
		select username 
			into l_username
			from ks_users
		where id = l_user_id;
		
		ks_user_event_track_roles_dml.ins_ks_user_event_track_roles(
            l_user_event_track_role,
			l_username,
			p_track_id,
			p_selection_code,
			p_voting_code
		);
		
	else
	
		l_username := p_existing_user;
	
		ks_user_event_track_roles_dml.ins_ks_user_event_track_roles(
			l_user_event_track_role,
			l_username,
			p_track_id,
			p_selection_code,
			p_voting_code
		);
		
	end if;

	exception
	
    when OTHERS then
	
      -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
	  
      raise;
	
end set_user_information;

end ks_users_api;
/
