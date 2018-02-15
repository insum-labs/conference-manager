create or replace package body ks_api
is

--------------------------------------------------------------------------------
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';



--------------------------------------------------------------------------------
--*
--* Add messages to the queue
--*
procedure add_message(p_msg          in out NOCOPY ks_api.message_tbl_type
                    , p_message_text in VARCHAR2
                    , p_severity     in VARCHAR2 DEFAULT 'E')
is
  -- l_scope logger_logs.scope%type := gc_scope_prefix || 'add_message';
  -- l_params logger.tab_param;
  l_index  PLS_INTEGER;
begin
  -- logger.append_param(l_params, 'p_message_text', p_message_text);

  l_index := p_msg.COUNT + 1;
  p_msg(l_index).message_text := p_message_text;
  p_msg(l_index).severity := p_severity;

  -- logger.log('Message added:'||p_msg(l_index).message_text, l_scope, null, l_params);

  exception
    when OTHERS then
      -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
      raise;
end add_message;


--------------------------------------------------------------------------------
--*
--* Receives a message table and will concatenate it into a
--* formatted varchar2(4000) value.
--* p_sep is used as the separator between the messages. You can
--* use chr(13)||chr(10) if working with a textarea or printing.
--*
--------------------------------------------------------------------------------
function format_error_messages (
    p_messages_tbl  in out NOCOPY ks_api.message_tbl_type
  , p_sep           in varchar2 default '<br>'
)
return varchar2
is
  -- l_scope   logger_logs.scope%type := gc_scope_prefix || 'format_error_messages';
  -- l_params  logger.tab_param;

  len       number;
  l_output  varchar2(4000);
begin
  -- logger.append_param(l_params, 'p_sep', p_sep);
  -- logger.log('BEGIN', l_scope, null, l_params);

  l_output := '';

  for i in 1..p_messages_tbl.COUNT loop
    len := 4000 - nvl(length(l_output),0) - length(p_sep);
    if len > 0 then
      l_output := l_output || substr(p_messages_tbl(i).message_text,1,len)
                    || p_sep;
    end if;
  end loop;

  -- logger.log('END', l_scope, null, l_params);
  return l_output;

exception
  when OTHERS then
    -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end format_error_messages;



--------------------------------------------------------------------------------
--*
--* Receives a message table and will add the entries as
--* errors on the APEX page.
--*
--------------------------------------------------------------------------------
procedure set_page_errors(
    p_messages_tbl     in out NOCOPY ks_api.message_tbl_type
  , p_display_location in varchar2 default apex_error.c_inline_in_notification
)
is
  -- l_scope   logger_logs.scope%type := gc_scope_prefix || 'set_page_errors';
  -- l_params  logger.tab_param;
begin
  -- logger.append_param(l_params, 'p_display_location', p_display_location);
  -- logger.log_information('BEGIN', l_scope, null, l_params);


  for i in 1..p_messages_tbl.COUNT loop
    -- logger.log('message:' || i, l_scope);
    apex_error.add_error(
        p_message           => p_messages_tbl(i).message_text
      , p_display_location  => p_display_location
    );
  end loop;

  -- logger.log('END', l_scope, null, l_params);

exception
  when OTHERS then
    -- logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end set_page_errors;



end ks_api;
/
