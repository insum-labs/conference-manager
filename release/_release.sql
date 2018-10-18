PRO Installing 3.0.0 (Kscope19)

--  sqlblanklines - Allows for SQL statements to have blank lines
set sqlblanklines on
--  define - Sets the character used to prefix substitution variables
set define '^'


-- *** DDL ***

-- #17
alter table ks_events add blind_vote_flag varchar2(1);


-- *** Objects ***


-- *** DML ***


-- DO NOT TOUCH/UPDATE BELOW THIS LINE


PRO Recompiling objects
exec dbms_utility.compile_schema(schema => user, compile_all => false);