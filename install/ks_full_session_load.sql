
-- drop table ks_full_session_load purge;
create table ks_full_session_load (
   app_user                      varchar2(60) default coalesce(
                                         sys_context('APEX$SESSION','app_user')
                                       , sys_context ('userenv', 'os_user'), user)
 , external_sys_ref              varchar2(4000)
 , session_num                   varchar2(4000)
 , event_track_id                varchar2(4000)
 , sub_category                  varchar2(4000)
 , session_type                  varchar2(4000)
 , title                         varchar2(4000)
 , ace_level                     varchar2(4000)
 , presented_before_ind          varchar2(4000)
 , presented_before_where        varchar2(4000)
 , video_link                    varchar2(4000)
 , co_presenter                  varchar2(4000)
 , co_presenter_company          varchar2(4000)
 , presenter_biography           clob
 , company                       varchar2(4000)
 , presenter                     varchar2(4000)
 , session_abstract              clob
 , session_summary               varchar2(4000)
 , tags                          varchar2(4000)
 , target_audience               varchar2(4000)
 , technology_product            varchar2(4000)
 , contains_demo_ind             varchar2(4000)
 , webinar_willing_ind           varchar2(4000)
 , presenter_email               varchar2(4000)
 , presenter_user_id             varchar2(4000)
 , co_presenter_user_id          varchar2(4000)
)
/





comment on table ks_full_session_load is 'Staging table for loading sessions.';
