select 1
from apex_applications a
where a.application_id = :APP_ID
  and a.feedback = 'Enabled'