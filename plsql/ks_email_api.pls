create or replace package ks_email_api
is

procedure send (
     p_to in varchar2
    ,p_cc in varchar2 default null
    ,p_bcc in varchar2 default null
    ,p_from in varchar2 default null
    ,p_replyto in varchar2 default null
    ,p_subj in varchar2
    ,p_body in clob
    ,p_body_html in clob
);

end ks_email_api;
/
