create or replace package KS_USER_EVENT_TRACK_ROLES_DML is 
 
-------------------------------------------------------------- 
-- create procedure for table "KS_USER_EVENT_TRACK_ROLES" 
 
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
   ); 
 
 
-------------------------------------------------------------- 
-- update procedure for table "KS_USER_EVENT_TRACK_ROLES" 
 
   procedure UPD_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID				    in number, 
      P_USERNAME            in varchar2, 
      P_EVENT_TRACK_ID      in number, 
      P_SELECTION_ROLE_CODE in varchar2                        default null, 
      P_VOTING_ROLE_CODE    in varchar2                        default null, 
      P_CREATED_BY          in varchar2                        default null, 
      P_CREATED_ON          in date                            default null, 
      P_UPDATED_BY          in varchar2                        default null, 
      P_UPDATED_ON          in date                            default null, 
      P_MD5                 in varchar2                        default null 
   ); 
 
 
-------------------------------------------------------------- 
-- delete procedure for table "KS_USER_EVENT_TRACK_ROLES" 
 
   procedure DEL_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID in number 
   ); 
 
-------------------------------------------------------------- 
-- get procedure for table "KS_USER_EVENT_TRACK_ROLES" 
 
   procedure GET_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID 					in number, 
      P_USERNAME            out varchar2, 
      P_EVENT_TRACK_ID      out number, 
      P_SELECTION_ROLE_CODE out varchar2, 
      P_VOTING_ROLE_CODE    out varchar2, 
      P_CREATED_BY          out varchar2, 
      P_CREATED_ON          out date, 
      P_UPDATED_BY          out varchar2, 
      P_UPDATED_ON          out date 
   ); 
 
-------------------------------------------------------------- 
-- get procedure for table "KS_USER_EVENT_TRACK_ROLES" 
 
   procedure GET_KS_USER_EVENT_TRACK_ROLES ( 
      P_ID 					in number, 
      P_USERNAME            out varchar2, 
      P_EVENT_TRACK_ID      out number, 
      P_SELECTION_ROLE_CODE out varchar2, 
      P_VOTING_ROLE_CODE    out varchar2, 
      P_CREATED_BY          out varchar2, 
      P_CREATED_ON          out date, 
      P_UPDATED_BY          out varchar2, 
      P_UPDATED_ON          out date, 
      P_MD5                 out varchar2 
   ); 
 
-------------------------------------------------------------- 
-- build MD5 function for table "KS_USER_EVENT_TRACK_ROLES" 
 
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
   ) return varchar2; 
  
end KS_USER_EVENT_TRACK_ROLES_DML;
/