
set define '^'
set verify off
set feedback off



PROMPT
PROMPT == Package Specs
PROMPT =================

PROMPT ks_tags_api
@@ks_tags_api.pls

PROMPT ks_sec
@@ks_sec.pls

PROMPT ks_api
@@ks_api.pls

PROMPT ks_util
@@ks_util.pls

PROMPT ks_error_handler
@@ks_error_handler.pls

PROMPT ks_session_load_api
@@ks_session_load_api.pls

PROMPT ks_session_api
@@ks_session_api.pls


PROMPT
PROMPT == Package Bodies
PROMPT ==================


PROMPT ks_tags_api
@@ks_tags_api.plb

PROMPT ks_error_handler
@@ks_error_handler.plb

PROMPT ks_sec
@@ks_sec.plb

PROMPT ks_api
@@ks_api.plb

PROMPT ks_util
@@ks_util.plb

PROMPT ks_session_load_api
@@ks_session_load_api.plb

PROMPT ks_session_api
@@ks_session_api.plb



------------------------------
PROMPT ks_users_iu
@@ks_users_iu.sql

PROMPT Fixing user passwords
update ks_users set password = 'welcome';

