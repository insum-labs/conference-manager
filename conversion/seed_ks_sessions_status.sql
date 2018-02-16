PRO seed ks_session_status

SET DEFINE OFF;

insert into ks_session_status (display_seq, code, name, active_ind) values (10, 'ACCEPTED', 'Accepted', 'Y');
insert into ks_session_status (display_seq, code, name, active_ind) values (20, 'REJECTED', 'Rejected', 'Y');
insert into ks_session_status (display_seq, code, name, active_ind) values (30, 'ONHOLD', 'On-Hold', 'Y');
insert into ks_session_status (display_seq, code, name, active_ind) values (35, 'ALT', 'Alternate', 'Y');
insert into ks_session_status (display_seq, code, name, active_ind) values (40, 'WEBINAR', 'Webinar', 'Y');
insert into ks_session_status (display_seq, code, name, active_ind) values (99, 'TBA', 'TBA', 'Y');
