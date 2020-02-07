select 
    a.application_id
  , a.application_name
  , a.apex_user
  , a.apex_session_id
  , a.page_id
  , a.page_name
  , a.seconds_ago
  , (current_timestamp-numtodsinterval(a.seconds_ago,'SECOND')) as activity_time
  , to_char(round((a.seconds_ago)/3600,2),'9,999.99') as hours_ago
  , a.elapsed_time
  , a.ERROR_MESSAGE
  , a.ERROR_ON_COMPONENT_TYPE
  , a.ERROR_ON_COMPONENT_NAME
  , a.ip_address
  , a.agent
from apex_workspace_activity_log a
where a.application_id= to_number(:APP_ID)
  and a.apex_user is not null
  and (
   (:P1050_EXCLUDE_ME = 'Y' and a.apex_user <> :APP_USER)
   or 
   (:P1050_EXCLUDE_ME = 'N')
 )