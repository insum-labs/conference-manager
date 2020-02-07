declare
    l_abstract ks_sessions.session_abstract%type;
begin
    select session_abstract
      into l_abstract
      from ks_sessions
     where id = :P3_ID;
     
    htp.p(nvl(ks_session_api.html_whitelist_tokenize(l_abstract, :P3_ID, 'N'), 'N/A'));
    
    exception when no_data_found
    then
        htp.p('None');
end;
