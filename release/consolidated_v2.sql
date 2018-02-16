--- 

PRO Installing 2.0.1
/*
# Voting Apps upgrade to v2.0.1

## Voting App: Changes and Enhancements
* Session "Summary" and "Abstract" are now available columns in the session list.
* Committee Members can now opt to hide speaker and company information (Go to Preferences)
* By Popular demand: "Voting Region" has now been relocated to the top of the screen.
* When present, Co-Presenter is now displayed right below the Presenter


## Content Selection App: Changes and Enhancements
* Session "Summary" and "Abstract" are now available columns in the session list.

*/

alter table ks_full_session_load add co_presenter_company varchar2(4000);
alter table ks_sessions add co_presenter_company varchar2(500);

update ks_load_mapping
   set to_column_name = 'CO_PRESENTER_COMPANY'
 where header_name = 'Role:Co-Presenter Company'
/


PRO Installing 2.0.2
/*
# Voting Apps upgrade to v2.0.2

## Changes and Enhancements
* New report: All Sessions Report (with cross track priviledges)
* New report: Presenters with Multiple Sessions
* Submission Date is now loaded
* Submission Video is now more prominent and displayed for Committee voters
* Changes and enhancements to XLS sesison load

## Small Technical Changes
* Session should be unique by event

*/

drop index ks_sessions_u01;
create unique index ks_sessions_u01 on ks_sessions(event_id, session_num);

alter table ks_full_session_load add submission_date date;
alter table ks_sessions add submission_date date;

update ks_load_mapping
   set to_column_name = 'SUBMISSION_DATE'
 where header_name = 'Initial Submission'
/


PRO Installing 2.0.3
/*
# Voting Apps upgrade to v2.0.3

## Changes and Enhancements
* Full Summary & Abstract are now included in the “Additional” section.
* "Summary?" & "Abstract?" icon columns are searched if included in the report.
* Enhancements for censored words

## Small Technical Changes

*/


PRO Installing 2.0.4
/*
# Voting Apps upgrade to v2.0.4

## Changes and Enhancements
* Fixed issue on Voting App where long abstracts would fail the report
* Don’t show events that ended more than 6 months ago.

## Small Technical Changes
* epm added to the "token_exceptions" list
* Speed for Tokenizer and Token Replacement.
* Speed for Data Load

*/


PRO Installing 2.0.5
/*
# Voting Apps upgrade to v2.0.5

## Changes and Enhancements
* Added ability for Admin to move sessions to a different track

## Small Technical Changes
* New large "Check" mark to indicate you have voted
* Security enhancements on p2

*/



@../plsql/ks_session_load_api.pls
@../plsql/ks_util.pls
@../plsql/ks_session_api.pls


@../plsql/ks_session_load_api.plb
@../plsql/ks_log.plb
@../plsql/ks_util.plb
@../plsql/ks_session_api.plb

@../install/ks_tags_post_install.sql


