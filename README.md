[![APEX Community](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/78c5adbe/badges/apex-community-badge.svg)](https://github.com/Dani3lSun/apex-github-badges) [![APEX 18.2](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/2fee47b7/badges/apex-18_2-badge.svg)](https://github.com/Dani3lSun/apex-github-badges) [![APEX Built with Love](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/7919f913/badges/apex-love-badge.svg)](https://github.com/Dani3lSun/apex-github-badges)

# Conference Manager
Open Source Conference Abstract Voting and Content Selection Apps

## App List

| app | Description |
|:-|--|
| 83791 | Admin & Review App |
| 120124 | Voting App |

## Install

Run the following scripts in order:
```
@release/master_install.sql
@release/master_release_v2.sql
```


The scripts are meant to be executed via command line (sqlcl for example) or uploaded via SQL Workshop from within APEX.

Install the following APEX apps:
```
@f83791.sql
@f120124.sql
```

> **IMPORTANT:** Do install the supporting objects from app f120124.

If you change an App ID you'll want to update the parameters that store those values: 

```
begin
  ks_util.set_param('VOTING_APP_ID', '120124');
end;
/
```



