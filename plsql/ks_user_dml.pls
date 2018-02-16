-- table API for application ks_user_dml, generated 13-OCT-2017
-- package specification
-- 
   
create or replace package ks_user_dml is

--------------------------------------------------------------
-- create procedure for table KS_USERS

   procedure INS_KS_USERS (
      P_ID         in out number,
      P_USERNAME   in varchar2,
      P_PASSWORD   in varchar2                        default null,
      P_FIRST_NAME in varchar2                        default null,
      P_LAST_NAME  in varchar2                        default null,
      P_EMAIL      in varchar2                        default null,
      P_ACTIVE_IND in varchar2,
      P_ADMIN_IND  in varchar2,
	  P_EXTERNAL_SYS_REF in varchar2,
      P_CREATED_BY in varchar2                        default null,
      P_CREATED_ON in date                            default null,
      P_UPDATED_BY in varchar2                        default null,
      P_UPDATED_ON in date                            default null
   );


--------------------------------------------------------------
-- update procedure for table KS_USERS

   procedure UPD_KS_USERS (
      P_ID in number,
      P_USERNAME   in varchar2,
      P_PASSWORD   in varchar2                        default null,
      P_FIRST_NAME in varchar2                        default null,
      P_LAST_NAME  in varchar2                        default null,
      P_EMAIL      in varchar2                        default null,
      P_ACTIVE_IND in varchar2,
      P_ADMIN_IND  in varchar2,
	  P_EXTERNAL_SYS_REF in varchar2,
      P_CREATED_BY in varchar2                        default null,
      P_CREATED_ON in date                            default null,
      P_UPDATED_BY in varchar2                        default null,
      P_UPDATED_ON in date                            default null,
      P_MD5        in varchar2                        default null
   );


--------------------------------------------------------------
-- delete procedure for table KS_USERS

   procedure DEL_KS_USERS (
      P_ID in number
   );

--------------------------------------------------------------
-- get procedure for table KS_USERS

   procedure GET_KS_USERS (
      P_ID in number,
      P_USERNAME   out varchar2,
      P_PASSWORD   out varchar2,
      P_FIRST_NAME out varchar2,
      P_LAST_NAME  out varchar2,
      P_EMAIL      out varchar2,
      P_ACTIVE_IND out varchar2,
      P_ADMIN_IND  out varchar2,
	  P_EXTERNAL_SYS_REF in varchar2,
      P_CREATED_BY out varchar2,
      P_CREATED_ON out date,
      P_UPDATED_BY out varchar2,
      P_UPDATED_ON out date
   );

--------------------------------------------------------------
-- get procedure for table KS_USERS

   procedure GET_KS_USERS (
      P_ID in number,
      P_USERNAME   out varchar2,
      P_PASSWORD   out varchar2,
      P_FIRST_NAME out varchar2,
      P_LAST_NAME  out varchar2,
      P_EMAIL      out varchar2,
      P_ACTIVE_IND out varchar2,
      P_ADMIN_IND  out varchar2,
	  P_EXTERNAL_SYS_REF in varchar2,
      P_CREATED_BY out varchar2,
      P_CREATED_ON out date,
      P_UPDATED_BY out varchar2,
      P_UPDATED_ON out date,
      P_MD5        out varchar2
   );

--------------------------------------------------------------
-- build MD5 function for table KS_USERS

   function BUILD_KS_USERS_MD5 (
      P_ID in number,
      P_USERNAME   in varchar2,
      P_PASSWORD   in varchar2                        default null,
      P_FIRST_NAME in varchar2                        default null,
      P_LAST_NAME  in varchar2                        default null,
      P_EMAIL      in varchar2                        default null,
      P_ACTIVE_IND in varchar2,
      P_ADMIN_IND  in varchar2,
	  P_EXTERNAL_SYS_REF in varchar2,
      P_CREATED_BY in varchar2                        default null,
      P_CREATED_ON in date                            default null,
      P_UPDATED_BY in varchar2                        default null,
      P_UPDATED_ON in date                            default null
   ) return varchar2;
 
end ks_user_dml;
/
