

PRO ... create table tmp_presenters
create table tmp_presenters
as
select presenter, max(presenter_user_id) presenter_user_id
from ks_sessions
where presenter in (
    select presenter
    from ks_sessions
    where presenter_user_id is not null
)
  and presenter_user_id is not null
group by presenter
/

create or replace function get_presenter_user_id(p_presenter in ks_sessions.presenter%TYPE)
  return ks_sessions.presenter_user_id%TYPE
is
  l_presenter_user_id ks_sessions.presenter_user_id%TYPE;
  l_presenter_hash varchar2(128);
begin
  select presenter_user_id
    into l_presenter_user_id
    from tmp_presenters
   where presenter = p_presenter;

  -- ks_log.log('Got l_presenter_user_id:' || l_presenter_user_id, 'get_presenter_user_id');
  return l_presenter_user_id;

 exception
 when NO_DATA_FOUND then
   -- generate an ID:
   --   * create and MD5 of the presenter name
   --   * Convert it to a number (because we get a RAW back)
   --   * Convert the number back to a String and grab the first 20 only (the size limit of presenter_user_id)
   return substr(
      to_char(
          to_number(
            dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(p_presenter))
            , 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
      ),1,20);
end get_presenter_user_id;
/



declare
  cursor presenters_cur
  is
    select * from ks_sessions 
    where presenter_user_id is null
      for update of presenter_user_id;

  l_session_rec presenters_cur%rowtype;

begin

  open presenters_cur;
  loop
    fetch presenters_cur into l_session_rec;
    exit when presenters_cur%NOTFOUND;

    update ks_sessions
       set presenter_user_id = get_presenter_user_id(presenter)
     where current of presenters_cur;

  end loop;
  close presenters_cur;

end;
/


PRO ... Cleanup: Drop tmp_presenters, get_presenter_user_id
drop table tmp_presenters;

drop function get_presenter_user_id;


