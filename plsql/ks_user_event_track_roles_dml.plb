create or replace package body KS_USER_EVENT_TRACK_ROLES_DML is 
 
-------------------------------------------------------------- 
-- create procedure for table KS_USER_EVENT_TRACK_ROLES 
 
   procedure INS_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID                  in out number, 
      P_USERNAME            in varchar2, 
      P_EVENT_TRACK_ID      in number, 
      P_SELECTION_ROLE_CODE in varchar2                        default null, 
      P_VOTING_ROLE_CODE    in varchar2                        default null, 
      P_CREATED_BY          in varchar2                        default null, 
      P_CREATED_ON          in date                            default null, 
      P_UPDATED_BY          in varchar2                        default null, 
      P_UPDATED_ON          in date                            default null 
   ) is  
  
   begin 
  
      insert into KS_USER_EVENT_TRACK_ROLES ( 
         --ID, 
         USERNAME, 
         EVENT_TRACK_ID, 
         SELECTION_ROLE_CODE, 
         VOTING_ROLE_CODE 
         --CREATED_BY, 
         --CREATED_ON, 
         --UPDATED_BY, 
         --UPDATED_ON 
      ) values (  
         --P_ID, 
         P_USERNAME, 
         P_EVENT_TRACK_ID, 
         P_SELECTION_ROLE_CODE, 
         P_VOTING_ROLE_CODE 
         --P_CREATED_BY, 
         --P_CREATED_ON, 
         --P_UPDATED_BY, 
         --P_UPDATED_ON 
      ) 
	  returning id into p_id; 
  
   end INS_KS_USER_EVENT_TRACK_ROLES; 
 
 
-------------------------------------------------------------- 
-- update procedure for table KS_USER_EVENT_TRACK_ROLES 
 
   procedure UPD_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID in number, 
      P_USERNAME            in varchar2, 
      P_EVENT_TRACK_ID      in number, 
      P_SELECTION_ROLE_CODE in varchar2                        default null, 
      P_VOTING_ROLE_CODE    in varchar2                        default null, 
      P_CREATED_BY          in varchar2                        default null, 
      P_CREATED_ON          in date                            default null, 
      P_UPDATED_BY          in varchar2                        default null, 
      P_UPDATED_ON          in date                            default null, 
      P_MD5                 in varchar2                        default null 
   ) is  
  
      L_MD5 varchar2(32767) := null; 
  
   begin 
  
      if P_MD5 is not null then 
         for c1 in ( 
            select * from KS_USER_EVENT_TRACK_ROLES  
            where ID = P_ID FOR UPDATE 
         ) loop 
  
            L_MD5 := BUILD_KS_USR_EVNT_TRCK_RLE_MD5( 
               c1.ID, 
               c1.USERNAME, 
               c1.EVENT_TRACK_ID, 
               c1.SELECTION_ROLE_CODE, 
               c1.VOTING_ROLE_CODE, 
               c1.CREATED_BY, 
               c1.CREATED_ON, 
               c1.UPDATED_BY, 
               c1.UPDATED_ON 
            ); 
  
         end loop; 
  
      end if; 
  
      if (P_MD5 is null) or (L_MD5 = P_MD5) then  
         update KS_USER_EVENT_TRACK_ROLES set 
            ID                    = P_ID, 
            USERNAME              = P_USERNAME, 
            EVENT_TRACK_ID        = P_EVENT_TRACK_ID, 
            SELECTION_ROLE_CODE   = P_SELECTION_ROLE_CODE, 
            VOTING_ROLE_CODE      = P_VOTING_ROLE_CODE, 
            CREATED_BY            = P_CREATED_BY, 
            CREATED_ON            = P_CREATED_ON, 
            UPDATED_BY            = P_UPDATED_BY, 
            UPDATED_ON            = P_UPDATED_ON 
         where ID = P_ID; 
      else 
         raise_application_error (-20001,'Current version of data in database has changed since user initiated update process. current checksum = '||L_MD5||', item checksum = '||P_MD5||'.');   
      end if; 
  
   end UPD_KS_USER_EVENT_TRACK_ROLES; 
 
 
-------------------------------------------------------------- 
-- delete procedure for table KS_USER_EVENT_TRACK_ROLES 
 
   procedure DEL_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID in number 
   ) is  
  
   begin 
  
      delete from KS_USER_EVENT_TRACK_ROLES  
      where ID = P_ID; 
  
   end DEL_KS_USER_EVENT_TRACK_ROLES; 
 
-------------------------------------------------------------- 
-- get procedure for table KS_USER_EVENT_TRACK_ROLES 
 
   procedure GET_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID in number, 
      P_USERNAME            out varchar2, 
      P_EVENT_TRACK_ID      out number, 
      P_SELECTION_ROLE_CODE out varchar2, 
      P_VOTING_ROLE_CODE    out varchar2, 
      P_CREATED_BY          out varchar2, 
      P_CREATED_ON          out date, 
      P_UPDATED_BY          out varchar2, 
      P_UPDATED_ON          out date 
   ) is  
  
      ignore varchar2(32676); 
   begin 
  
      GET_KS_USER_EVENT_TRACK_ROLES ( 
         P_ID, 
         P_USERNAME, 
         P_EVENT_TRACK_ID, 
         P_SELECTION_ROLE_CODE, 
         P_VOTING_ROLE_CODE, 
         P_CREATED_BY, 
         P_CREATED_ON, 
         P_UPDATED_BY, 
         P_UPDATED_ON, 
         ignore 
      ); 
  
   end GET_KS_USER_EVENT_TRACK_ROLES; 
 
-------------------------------------------------------------- 
-- get procedure for table KS_USER_EVENT_TRACK_ROLES 
 
   procedure GET_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID in number, 
      P_USERNAME            out varchar2, 
      P_EVENT_TRACK_ID      out number, 
      P_SELECTION_ROLE_CODE out varchar2, 
      P_VOTING_ROLE_CODE    out varchar2, 
      P_CREATED_BY          out varchar2, 
      P_CREATED_ON          out date, 
      P_UPDATED_BY          out varchar2, 
      P_UPDATED_ON          out date, 
      P_MD5                 out varchar2 
   ) is  
  
   begin 
  
      for c1 in ( 
         select * from KS_USER_EVENT_TRACK_ROLES  
         where ID = P_ID  
      ) loop 
         P_USERNAME            := c1.USERNAME; 
         P_EVENT_TRACK_ID      := c1.EVENT_TRACK_ID; 
         P_SELECTION_ROLE_CODE := c1.SELECTION_ROLE_CODE; 
         P_VOTING_ROLE_CODE    := c1.VOTING_ROLE_CODE; 
         P_CREATED_BY          := c1.CREATED_BY; 
         P_CREATED_ON          := c1.CREATED_ON; 
         P_UPDATED_BY          := c1.UPDATED_BY; 
         P_UPDATED_ON          := c1.UPDATED_ON; 
  
         P_MD5 := BUILD_KS_USR_EVNT_TRCK_RLE_MD5( 
            c1.ID, 
            c1.USERNAME, 
            c1.EVENT_TRACK_ID, 
            c1.SELECTION_ROLE_CODE, 
            c1.VOTING_ROLE_CODE, 
            c1.CREATED_BY, 
            c1.CREATED_ON, 
            c1.UPDATED_BY, 
            c1.UPDATED_ON 
         ); 
      end loop; 
  
   end GET_KS_USER_EVENT_TRACK_ROLES; 
 
-------------------------------------------------------------- 
-- build MD5 function for table KS_USER_EVENT_TRACK_ROLES 
 
   function BUILD_KS_USR_EVNT_TRCK_RLE_MD5 ( 
      P_ID in number, 
      P_USERNAME            in varchar2, 
      P_EVENT_TRACK_ID      in number, 
      P_SELECTION_ROLE_CODE in varchar2                        default null, 
      P_VOTING_ROLE_CODE    in varchar2                        default null, 
      P_CREATED_BY          in varchar2                        default null, 
      P_CREATED_ON          in date                            default null, 
      P_UPDATED_BY          in varchar2                        default null, 
      P_UPDATED_ON          in date                            default null 
   ) return varchar2 is  
  
   begin 
  
      return apex_util.get_hash(apex_t_varchar2( 
         P_USERNAME, 
         P_EVENT_TRACK_ID, 
         P_SELECTION_ROLE_CODE, 
         P_VOTING_ROLE_CODE, 
         P_CREATED_BY, 
         to_char(P_CREATED_ON,'yyyymmddhh24:mi:ss'), 
         P_UPDATED_BY, 
         to_char(P_UPDATED_ON,'yyyymmddhh24:mi:ss') )); 
  
   end BUILD_KS_USR_EVNT_TRCK_RLE_MD5; 
  
end KS_USER_EVENT_TRACK_ROLES_DML;
/