/*
These inserts are based on these export columns.

Session Number
Session Title
Session Title Link
Track
Sub-Categorization
Session Type
Role:Submitter
Full Name	Session
Status	All roles
All roles (with line break)
Are you part of the ACE program?
Cross-Listed Tracks
Have you presented this session before?
I Agree	I Agree	I Agree
If yes, at what events?
Initial Submission
Last Update
Link to your optional abstract submission video
Review Comments
Role:Co-Presenter Biography
Role:Co-Presenter Company
Role:Co-Presenter First Name
Role:Co-Presenter Full Name
Role:Co-Presenter Last Name
Role:Co-Presenter Title
Role:Co-Presenter User Id
Role:Primary Presenter Biography
Role:Primary Presenter Company
Role:Primary Presenter First Name
Role:Primary Presenter Full Name
Role:Primary Presenter Last Name
Role:Primary Presenter Title
Role:Primary Presenter User Id
Role:Submitter Biography
Role:Submitter Company
Role:Submitter First Name
Role:Submitter Last Name
Role:Submitter Title
Role:Submitter User Id
Session Description	Session Id
Short Description	Status Change
Tags
Target Audience
Technologies or Products Used
Vote Average	Vote Count
Will this presentation include a demo?
Would you be willing to present this as a webinar?
Role:Primary Presenter Email
Role:Submitter Email
*/


delete from ks_load_mapping;

SET DEFINE OFF;




insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 1, 'SESSION_NUM', 'Session Number'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 2, 'TITLE', 'Session Title'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 3, null, 'Session Title Link'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 4, 'EVENT_TRACK_ID', 'Track'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 5, 'SUB_CATEGORY', 'Sub-Categorization'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 6, 'SESSION_TYPE', 'Session Type'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 7, null, 'Role:Submitter Full Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 8, null, 'Session Status'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 9, null, 'All roles'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 10, null, 'All roles (with line break)'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 11, 'ACE_LEVEL', 'Are you part of the ACE program?'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 12, null, 'Cross-Listed Tracks'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 13, 'PRESENTED_BEFORE_IND', 'Have you presented this session before?'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 14, null, 'I Agree'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 15, null, 'I Agree'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 16, null, 'I Agree'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 17, 'PRESENTED_BEFORE_WHERE', 'If yes, at what events?'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 18, null, 'Initial Submission'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 19, null, 'Last Update'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 20, 'VIDEO_LINK', 'Link to your optional abstract submission video'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 21, null, 'Review Comments'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 22, null, 'Role:Co-Presenter Biography'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 23, null, 'Role:Co-Presenter Company'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 24, null, 'Role:Co-Presenter First Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 25, 'CO_PRESENTER', 'Role:Co-Presenter Full Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 26, null, 'Role:Co-Presenter Last Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 27, null, 'Role:Co-Presenter Title'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 28, 'CO_PRESENTER_USER_ID', 'Role:Co-Presenter User Id'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 29, 'PRESENTER_BIOGRAPHY', 'Role:Primary Presenter Biography'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 30, 'COMPANY', 'Role:Primary Presenter Company'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 31, null, 'Role:Primary Presenter First Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 32, 'PRESENTER', 'Role:Primary Presenter Full Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 33, null, 'Role:Primary Presenter Last Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 34, null, 'Role:Primary Presenter Title'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 35, 'PRESENTER_USER_ID', 'Role:Primary Presenter User Id'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 36, null, 'Role:Submitter Biography'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 37, null, 'Role:Submitter Company'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 38, null, 'Role:Submitter First Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 39, null, 'Role:Submitter Last Name'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 40, null, 'Role:Submitter Title'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 41, null, 'Role:Submitter User Id'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 42, 'SESSION_ABSTRACT', 'Session Description'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 43, 'EXTERNAL_SYS_REF', 'Session Id'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 44, 'SESSION_SUMMARY', 'Short Description'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 45, null, 'Status Change'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 46, 'TAGS', 'Tags'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 47, 'TARGET_AUDIENCE', 'Target Audience'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 48, 'TECHNOLOGY_PRODUCT', 'Technologies or Products Used'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 49, null, 'Vote Average'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 50, null, 'Vote Count'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 51, 'CONTAINS_DEMO_IND', 'Will this presentation include a demo?'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 52, 'WEBINAR_WILLING_IND', 'Would you be willing to present this as a webinar?'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 53, 'PRESENTER_EMAIL', 'Role:Primary Presenter Email'
  );
insert into ks_load_mapping(
  table_name, display_seq, to_column_name, header_name
  )
values(
  'KS_FULL_SESSION_LOAD', 54, null, 'Role:Submitter Email'
  );
