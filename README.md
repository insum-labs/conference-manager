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
@release/master_release_v0200.sql
@release/master_release_v0300.sql
```


The scripts are meant to be executed via command line (sqlcl for example) or uploaded via SQL Workshop from within APEX.

Install the following APEX apps:
```
@f83791.sql
@f120124.sql
```

> **IMPORTANT:** Do install the supporting objects from app f120124.


## Configuration

Below are options and parameters you may want to take a look before running.

### Application reference
If you change an App ID you'll want to update the parameters that store those values: 

```
begin
  ks_util.set_param('ADMIN_APP_ID', '83791');
  ks_util.set_param('VOTING_APP_ID', '120124');
end;
/
```

### Email Notifications

There are several situations that emails are sent. Review the parameters below and configure as needed.

| Parameter | Description |
|:-|--|
| EMAIL_OVERRIDE | Set this value during testing and **all** emails will be sent to this coma delimited email list instead of the intended recipient. |
| EMAIL_PREFIX | All emails will have this prefix value in the subject. ie. \[VOTEAPP\] |
| EMAIL_FROM_ADDRESS | Emails from the system will come from this address. |
| SERVER_URL | When an email links back to the applications (Selection or Voting apps), this is the Server URL |

```
begin
  ks_util.set_param('EMAIL_OVERRIDE', '');
  ks_util.set_param('EMAIL_PREFIX', '[ODTUGKscope]');
  ks_util.set_param('EMAIL_FROM_ADDRESS', 'info@odtug.com');
  ks_util.set_param('SERVER_URL', 'https://apex.oracle.com/pls/apex/f?p=');
end;
/
```

