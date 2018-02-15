
-- drop table ks_session_load purge;
create table ks_session_load (
    app_user     varchar2(60) default coalesce(
                                         sys_context('APEX$SESSION','app_user')
                                       , sys_context ('userenv', 'os_user'), user)
  , SESSION_NUM       number
  , SUB_CATEGORIZATION varchar2(4000)
  , session_type      varchar2(4000)
  , "SESSION"         varchar2(4000)
  , primary_presenter varchar2(4000)
  , co_presenter      varchar2(4000)
  , voter             varchar2(4000)
  , total             number
  , "COMMENT"         varchar2(4000)
)
/

comment on table ks_session_load is 'Staging table for loading sessions.';

/*
This table is based on these export columns. (-) column excluded from load
Session Num
Sub Categorization
Session Type
Session
Session Submitter(-)
Primary Presenter
Co-Presenter
Voter
Total
Vote(-)
Comment
*/

