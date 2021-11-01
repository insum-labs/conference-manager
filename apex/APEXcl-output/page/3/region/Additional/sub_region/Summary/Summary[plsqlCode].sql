declare
    l_summary ks_sessions.session_summary%type;
begin
    select session_summary
      into l_summary
      from ks_sessions
     where id = :P3_ID;
     
    htp.p(nvl(ks_session_api.html_whitelist_tokenize(l_summary, :P3_ID, 'N'), 'N/A'));
    
    exception when no_data_found
    then
        htp.p('None');
end;
