create or replace package ks_tags_api
is
        
---
--- Tag Synchronisation Procedure
---
procedure tag_sync (
    p_new_tags          in varchar2,
    p_old_tags          in varchar2,
    p_content_type      in varchar2,
    p_content_id        in number );

procedure maintain_filter_coll(
       p_coll   in varchar2
     , p_sub    in varchar2 := null
     , p_id     in varchar2
     , p_status in varchar2 := 'NO');

end ks_tags_api;
/
