declare
    l_filename apex_application_temp_files.filename%type;
    l_filetype varchar2(4000);
begin
    if :P5040_FILE_NAME is null
    then
        return true; --The user is already going to get a "Filename must have some value" error
                     --  so giving them an "incorrect filename" error is redundant
    end if;
    
    select filename
      into l_filename
      from apex_application_temp_files
     where name = :P5040_FILE_NAME;
     
    --Get the file type based on the file name
    --This is "better" than mimetype since excel files can have multiple mimetypes
    --(as described here https://stackoverflow.com/questions/974079/setting-mime-type-for-excel-document)
    l_filetype := trim(lower(regexp_substr(l_filename, '\w+$')));
    if l_filetype not in ('xlsx')
    then
        return false;
    end if;
    return true;
end;