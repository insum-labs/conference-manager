-- table API for application KS_USER_DML, generated 13-OCT-2017
-- package body
-- 
   
create or replace package body ks_user_dml is

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
   ) is 
 
   begin
 
      insert into KS_USERS (
         -- ID,
         USERNAME,
         PASSWORD,
         FIRST_NAME,
         LAST_NAME,
         EMAIL,
         ACTIVE_IND,
         ADMIN_IND,
		 EXTERNAL_SYS_REF
         --CREATED_BY,
         --CREATED_ON,
         --UPDATED_BY,
         --UPDATED_ON
      ) values ( 
         -- P_ID,
         P_USERNAME,
         P_PASSWORD,
         P_FIRST_NAME,
         P_LAST_NAME,
         P_EMAIL,
         P_ACTIVE_IND,
         P_ADMIN_IND,
		 P_EXTERNAL_SYS_REF
         --P_CREATED_BY,
         --P_CREATED_ON,
         --P_UPDATED_BY,
         --P_UPDATED_ON
      )
      returning id into p_id;
 
   end INS_KS_USERS;


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
   ) is 
 
      L_MD5 varchar2(32767) := null;
 
   begin
 
      if P_MD5 is not null then
         for c1 in (
            select * from KS_USERS 
            where ID = P_ID FOR UPDATE
         ) loop
 
            L_MD5 := BUILD_KS_USERS_MD5(
               c1.ID,
               c1.USERNAME,
               c1.PASSWORD,
               c1.FIRST_NAME,
               c1.LAST_NAME,
               c1.EMAIL,
               c1.ACTIVE_IND,
               c1.ADMIN_IND,
			   c1.EXTERNAL_SYS_REF,
               c1.CREATED_BY,
               c1.CREATED_ON,
               c1.UPDATED_BY,
               c1.UPDATED_ON
            );
 
         end loop;
 
      end if;
 
      if (P_MD5 is null) or (L_MD5 = P_MD5) then 
         update KS_USERS set
            ID           = P_ID,
            USERNAME     = P_USERNAME,
            PASSWORD     = P_PASSWORD,
            FIRST_NAME   = P_FIRST_NAME,
            LAST_NAME    = P_LAST_NAME,
            EMAIL        = P_EMAIL,
            ACTIVE_IND   = P_ACTIVE_IND,
            ADMIN_IND    = P_ADMIN_IND,
			EXTERNAL_SYS_REF = P_EXTERNAL_SYS_REF,
            CREATED_BY   = P_CREATED_BY,
            CREATED_ON   = P_CREATED_ON,
            UPDATED_BY   = P_UPDATED_BY,
            UPDATED_ON   = P_UPDATED_ON
         where ID = P_ID;
      else
         raise_application_error (-20001,'Current version of data in database has changed since user initiated update process. current checksum = '||L_MD5||', item checksum = '||P_MD5||'.');  
      end if;
 
   end UPD_KS_USERS;


--------------------------------------------------------------
-- delete procedure for table KS_USERS

   procedure DEL_KS_USERS (
      P_ID in number
   ) is 
 
   begin
 
      delete from KS_USERS 
      where ID = P_ID;
 
   end DEL_KS_USERS;

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
   ) is 
 
      ignore varchar2(32676);
   begin
 
      GET_KS_USERS (
         P_ID,
         P_USERNAME,
         P_PASSWORD,
         P_FIRST_NAME,
         P_LAST_NAME,
         P_EMAIL,
         P_ACTIVE_IND,
         P_ADMIN_IND,
		 P_EXTERNAL_SYS_REF,
         P_CREATED_BY,
         P_CREATED_ON,
         P_UPDATED_BY,
         P_UPDATED_ON,
         ignore
      );
 
   end GET_KS_USERS;

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
   ) is 
 
   begin
 
      for c1 in (
         select * from KS_USERS 
         where ID = P_ID 
      ) loop
         P_USERNAME   := c1.USERNAME;
         P_PASSWORD   := c1.PASSWORD;
         P_FIRST_NAME := c1.FIRST_NAME;
         P_LAST_NAME  := c1.LAST_NAME;
         P_EMAIL      := c1.EMAIL;
         P_ACTIVE_IND := c1.ACTIVE_IND;
         P_ADMIN_IND  := c1.ADMIN_IND;
         P_CREATED_BY := c1.CREATED_BY;
         P_CREATED_ON := c1.CREATED_ON;
         P_UPDATED_BY := c1.UPDATED_BY;
         P_UPDATED_ON := c1.UPDATED_ON;
 
         P_MD5 := BUILD_KS_USERS_MD5(
            c1.ID,
            c1.USERNAME,
            c1.PASSWORD,
            c1.FIRST_NAME,
            c1.LAST_NAME,
            c1.EMAIL,
            c1.ACTIVE_IND,
            c1.ADMIN_IND,
			c1.EXTERNAL_SYS_REF,
            c1.CREATED_BY,
            c1.CREATED_ON,
            c1.UPDATED_BY,
            c1.UPDATED_ON
         );
      end loop;
 
   end GET_KS_USERS;

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
   ) return varchar2 is 
 
   begin
 
      return apex_util.get_hash(apex_t_varchar2(
         P_USERNAME,
         P_PASSWORD,
         P_FIRST_NAME,
         P_LAST_NAME,
         P_EMAIL,
         P_ACTIVE_IND,
         P_ADMIN_IND,
		 P_EXTERNAL_SYS_REF,
         P_CREATED_BY,
         to_char(P_CREATED_ON,'yyyymmddhh24:mi:ss'),
         P_UPDATED_BY,
         to_char(P_UPDATED_ON,'yyyymmddhh24:mi:ss') ));
 
   end BUILD_KS_USERS_MD5;
 
end ks_user_dml;
/
