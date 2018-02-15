create or replace package ks_api
is

--------------------------------------------------------------------------------
--*
--* API Messages
--*
--------------------------------------------------------------------------------
type message_rec_type is record (
    message_text  varchar2(4000)
  , severity      varchar2(1)
);

type message_tbl_type
  is table of message_rec_type
  index by binary_integer;

subtype result_status_type is varchar2(1);
subtype gt_string is varchar2(32767);

--------------------------------------------------------------------------------
--*
--* Operations
--*
--------------------------------------------------------------------------------
g_opr_create  CONSTANT VARCHAR2(10) := 'CREATE';
g_opr_update  CONSTANT VARCHAR2(10) := 'UPDATE';
g_opr_delete  CONSTANT VARCHAR2(10) := 'DELETE';
g_opr_none    CONSTANT VARCHAR2(10) := 'NONE';

--------------------------------------------------------------------------------
--*
--* Return statuses
--*
--------------------------------------------------------------------------------
g_ret_sts_success     CONSTANT result_status_type := 'S';
g_ret_sts_error       CONSTANT result_status_type := 'E';
g_ret_sts_unexp_error CONSTANT result_status_type := 'U';

--------------------------------------------------------------------------------
--*
--* "Missing" values
--* These values are used to differentiate between NULLs and values
--* that are not provided.
--*
--------------------------------------------------------------------------------
g_miss_num  CONSTANT NUMBER       := 9.99E125;
g_miss_char CONSTANT VARCHAR2(1)  := chr(0);
g_miss_date CONSTANT DATE         := to_date('1','j');

--------------------------------------------------------------------------------
c_crlf      constant varchar2(30) := chr(13)||chr(10);

--------------------------------------------------------------------------------
--*
--* Exceptions
--*
--------------------------------------------------------------------------------
e_api_error        exception;
e_api_unexp_error  exception;

--------------------------------------------------------------------------------
procedure add_message(p_msg          in out NOCOPY ks_api.message_tbl_type
                    , p_message_text in VARCHAR2
                    , p_severity     in VARCHAR2 DEFAULT 'E');

--------------------------------------------------------------------------------
function format_error_messages(
    p_messages_tbl  in out NOCOPY ks_api.message_tbl_type
  , p_sep           in varchar2 default '<br>'
)
return varchar2;

--------------------------------------------------------------------------------
procedure set_page_errors(
    p_messages_tbl     in out NOCOPY ks_api.message_tbl_type
  , p_display_location in varchar2 default apex_error.c_inline_in_notification
);

end ks_api;
/
