PRO seed ks_tracks

/*
 Seed the following Tracks:

  Application Express
  BI & Data Warehousing
  Big Data & Advanced Analytics
  Database
  EPM Applications
  EPM Business Content
  EPM Data Integration
  EPM Foundations
  EPM Platform
  EPM Reporting
  Essbase
  Financial Close
  Planning
  Vendor Presentation
*/
set define off

insert into ks_tracks (display_seq, name, alias, active_ind) values (10, 'Application Express', 'APEX', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (20, 'BI & Reporting', 'BI', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (30, 'Visualization & Adv Analytics', 'Big Data', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (30, 'Data Warehousing & Big Data', 'Big Data', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (40, 'Database', '', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (50, 'EPM Business Content', 'EPM Business', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (60, 'EPM Data Integration', '', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (70, 'EPM Infrastructure', '', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (80, 'Essbase', '', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (90, 'Financial Close', '', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (100, 'Planning', '', 'Y');
insert into ks_tracks (display_seq, name, alias, active_ind) values (110, 'Vendor Presentation', 'Vendor', 'Y');

set define on
