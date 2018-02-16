PRO seed ks_roles

SET DEFINE OFF;

delete from ks_roles;
insert into ks_roles (display_seq, code, name, role_type, active_ind) values (10, 'OWNER', 'Owner', 'SELECTION', 'Y');
insert into ks_roles (display_seq, code, name, role_type, active_ind) values (20, 'VIEWER', 'Viewer', 'SELECTION', 'Y');
insert into ks_roles (display_seq, code, name, role_type, active_ind) values (30, 'COMMITTEE', 'Abstract Reviewer', 'VOTING','Y');
insert into ks_roles (display_seq, code, name, role_type, active_ind) values (40, 'BLIND', 'Blind Voter','VOTING', 'Y');
