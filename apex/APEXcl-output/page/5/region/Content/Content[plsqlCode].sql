declare
    l_content_clob clob;
    l_content_char ks_sessions.session_summary%type;
begin
    if :P5_SHOW_TYPE = 'SESSION_SUMMARY'
    then
        select session_summary
          into l_content_char
          from ks_sessions
         where id = :P5_ID;
    else
        select case 
          when :P5_SHOW_TYPE = 'SESSION_ABSTRACT' then
            session_abstract
          else 
            presenter_biography
        end
          into l_content_clob
          from ks_sessions
         where id = :P5_ID;
    end if;
    
    sys.htp.p(
        case when :P5_SHOW_TYPE = 'PRESENTER_BIOGRAPHY'
              then l_content_clob
              else ks_session_api.html_whitelist_tokenize (nvl(l_content_char, to_char(l_content_clob)), :P5_ID) 
        end
    );    
end;