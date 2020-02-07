declare
    l_blob apex_application_temp_files.blob_content%type;
begin

    select blob_content
      into l_blob
      from apex_application_temp_files
     where name = :P5040_FILE_NAME;


    ks_session_load_api.load_xlsx_data(p_xlsx => l_blob);
end;
