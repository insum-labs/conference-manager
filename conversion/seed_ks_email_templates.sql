REM INSERTING into KS_EMAIL_TEMPLATES
SET DEFINE OFF;

insert into KS_EMAIL_TEMPLATES (NAME,TEMPLATE_TEXT) values ('SESSION_LOAD','The #TRACK_NAME# has received #SESSION_COUNT# sessions.

Please review or vote as needed.
#VOTING_APP_LINK#');

