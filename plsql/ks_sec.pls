create or replace package ks_sec
is

C_AUTH_SUCCESS            constant number := 0;
C_AUTH_UNKNOWN_USER       constant number := 1;
C_AUTH_ACCOUNT_LOCKED     constant number := 2;
C_AUTH_ACCOUNT_EXPIRED    constant number := 3;
C_AUTH_PASSWORD_INCORRECT constant number := 4;
C_AUTH_PASSWORD_FIRST_USE constant number := 5;
C_AUTH_ATTEMPTS_EXCEEDED  constant number := 6;
C_AUTH_INTERNAL_ERROR     constant number := 7;

subtype salt_type               is varchar2(16);
subtype password_type           is varchar2(128);
subtype password_with_salt_type is varchar2(145); --Length of salt and password, plus 1 character seperator

user_not_found exception;
pragma exception_init (user_not_found, -20001);

function password_match (
  p_username in ks_users.username%type 
 ,p_password in ks_users.password%type
)
return boolean;

function is_valid_user (
       p_username IN varchar2
     , p_password IN varchar2
)
return boolean;

function password_with_salt (p_password IN varchar2)
   return varchar2;

procedure post_login;
 
function get_name_from_user(p_username in varchar2) return varchar2;

procedure request_reset_password (
    p_username in ks_users.username%type
   ,p_app_id in ks_parameters.value%type
);

procedure reset_password (
    p_username in ks_users.username%type
   ,p_new_password in ks_users.password%type
   ,p_new_password_2 in ks_users.password%type
   ,p_error_msg out varchar2
);

function is_password_expired (p_username in ks_users.username%type)
return boolean;

end ks_sec;
/
