# Conference Manager
Open Source Conference Abstract Voting and Content Selection Apps

## App List

| app | Description |
|:-|--|
| 120124 | Voting App |
| 83791 | Admin & Review App |

## Install

Run the following scripts in order:
```
@release/master_install.sql
@release/master_release_v2.sql
```


The scripts are meant to be executed via command line (sqlcl for example) or uploaded via SQL Workshop from within APEX.

Install the following APEX apps:
```
@f120124.sql
@f83791.sql
```

> **IMPORTANT:** Do install the supporting objects from app f120124.

If you change an App ID you'll want to update the parameters that store those values: 

```
begin
  ks_util.set_param('VOTING_APP_ID', '120124');
end;
/
```


