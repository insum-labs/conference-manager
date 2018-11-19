REM INSERTING into KS_EMAIL_TEMPLATES
SET DEFINE OFF
SET SQLBLANKLINES ON
Insert into KS_EMAIL_TEMPLATES (NAME,TEMPLATE_TEXT) values ('RESET_PASSWORD_REQUEST_NOTIFICATION','Hi #USER_FIRST_NAME#,

You either have a brand new account with username #USERNAME# or a reset password has been requested for your account on the ODTUG Kscope Voting Apps.

Your temporary password is: #TEMP_PASSWORD#
You will need to change it when you log in for the first time.

Click on the following link to login to the Voting App:
#VOTING_APP_LINK#

If you''re a Track Lead you can use the Abstract Review App:
#ADMIN_APP_LINK#
');
Insert into KS_EMAIL_TEMPLATES (NAME,TEMPLATE_TEXT) values ('RESET_PASSWORD_DONE_NOTIFICATION','Hi #USER_FIRST_NAME#,
Your password has been reset.

If you did not reset it, please contact info@odtug.com
');
Insert into KS_EMAIL_TEMPLATES (NAME,TEMPLATE_TEXT) values ('SESSION_LOAD','The "#TRACK_NAME#" track has received #SESSION_COUNT# sessions.

If the voting period is open go vote at:
#VOTING_APP_LINK#

If you''re a Track Lead you can use the Abstract Review App:
#ADMIN_APP_LINK#
');

