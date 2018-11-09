create or replace package ks_sec
is

C_AUTH_SUCCESS            number := 0;
C_AUTH_UNKNOWN_USER       number := 1;
C_AUTH_ACCOUNT_LOCKED     number := 2;
C_AUTH_ACCOUNT_EXPIRED    number := 3;
C_AUTH_PASSWORD_INCORRECT number := 4;
C_AUTH_PASSWORD_FIRST_USE number := 5;
C_AUTH_ATTEMPTS_EXCEEDED  number := 6;
C_AUTH_INTERNAL_ERROR     number := 7;


subtype salt_type               is varchar2(16);
subtype password_type           is varchar2(128);
subtype password_with_salt_type is varchar2(145); --Length of salt and password, plus 1 character seperator


function is_valid_user (
       p_username IN varchar2
     , p_password IN varchar2
)
   return boolean;

function password_with_salt (p_password IN varchar2)
   return varchar2;

procedure post_login;
 
function get_name_from_user(p_username in varchar2) return varchar2;

end ks_sec;
/
