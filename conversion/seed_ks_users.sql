PRO seed ks_users

SET DEFINE OFF;
delete from ks_users;
insert into ks_users(username, password, first_name, last_name, email, active_ind, admin_ind) values ('JRIMBLAS',  'welcome','Jorge','Rimblas',  'jorge@rimblas.com', 'Y', 'Y');
insert into ks_users(username, password, first_name, last_name, email, active_ind, admin_ind) values ('ADMIN',  'welcome','Super','User',  'jorge@rimblas.com', 'Y', 'Y');
