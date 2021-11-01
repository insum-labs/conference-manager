-- alter session set PLSQL_CCFLAGS='VERBOSE_OUTPUT:TRUE';
PROMPT ks_tags_api body
create or replace package body ks_tags_api
is
        
--------------------------------------------------------------------------------
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';

---
--- Tag Synchronisation Procedure
---
procedure tag_sync (
    p_new_tags          in varchar2,
    p_old_tags          in varchar2,
    p_content_type      in varchar2,
    p_content_id        in number )
as
    l_scope  ks_log.scope := gc_scope_prefix || 'tag_sync';
  -- l_params logger.tab_param;

    type tags is table of varchar2(255) index by varchar2(255);
    l_new_tags_a    tags;
    l_old_tags_a    tags;
    l_new_tags      apex_application_global.vc_arr2;
    l_old_tags      apex_application_global.vc_arr2;
    l_merge_tags    apex_application_global.vc_arr2;
    l_dummy_tag     varchar2(255);
    i               integer;

begin
  -- we call tag_sync form a trigger, so lets not call logger unless we need to.
  -- logger.append_param(l_params, 'p_option_name', p_option_name);
    $IF $$VERBOSE_OUTPUT $THEN
    ks_log.log('START', l_scope);
    ks_log.log('p_content_type: ' || p_content_type, l_scope);
    ks_log.log('  p_content_id: ' || p_content_id, l_scope);
    ks_log.log('p_new_tags: ' || p_new_tags, l_scope);
    ks_log.log('p_old_tags: ' || p_old_tags, l_scope);
    $END

    l_old_tags := apex_util.string_to_table(p_old_tags,':');
    l_new_tags := apex_util.string_to_table(p_new_tags,':');
    if l_old_tags.count > 0 then --do inserts and deletes
        --build the associative arrays
        for i in 1..l_old_tags.count loop
            l_old_tags_a(l_old_tags(i)) := l_old_tags(i);
        end loop;
        for i in 1..l_new_tags.count loop
            l_new_tags_a(l_new_tags(i)) := l_new_tags(i);
        end loop;
        --do the inserts
        for i in 1..l_new_tags.count loop
            begin
                l_dummy_tag := l_old_tags_a(l_new_tags(i));
            exception when no_data_found then
                insert into ks_tags (tag, content_id, content_type )
                    values (l_new_tags(i), p_content_id, p_content_type );
                l_merge_tags(l_merge_tags.count + 1) := l_new_tags(i);
            end;
        end loop;
        --do the deletes
        for i in 1..l_old_tags.count loop
            begin
                l_dummy_tag := l_new_tags_a(l_old_tags(i));
            exception when no_data_found then
                delete from ks_tags where content_id = p_content_id and tag = l_old_tags(i);
                l_merge_tags(l_merge_tags.count + 1) := l_old_tags(i);
            end;
        end loop;
    else --just do inserts
        $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log('insert: ' || l_new_tags.count, l_scope);
        $END
        for i in 1..l_new_tags.count loop
            insert into ks_tags (tag, content_id, content_type )
                values (l_new_tags(i), p_content_id, p_content_type );
            l_merge_tags(l_merge_tags.count + 1) := l_new_tags(i);
        end loop;
    end if;

    for i in 1..l_merge_tags.count 
    loop
        $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log('merging(' || i || '): ' || l_merge_tags(i), l_scope);
        ks_log.log('merging ks_tag_type_sums', l_scope);
        $END
        merge into ks_tag_type_sums s
        using (select count(*) tag_count
                 from ks_tags
                where tag = l_merge_tags(i) 
                  and content_type = p_content_type ) t
           on (s.tag = l_merge_tags(i) and s.content_type = p_content_type )
         when not matched then
           insert (tag, content_type, tag_count)
           values (l_merge_tags(i), p_content_type, t.tag_count)
         when matched then
           update set s.tag_count = t.tag_count;


        $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log('merging ks_tag_sums', l_scope);
        $END
        merge into ks_tag_sums s
        using (select sum(tag_count) tag_count
                 from ks_tag_type_sums
                where tag = l_merge_tags(i) ) t
           on (s.tag = l_merge_tags(i) )
         when not matched then
           insert (tag, tag_count)
           values (l_merge_tags(i), t.tag_count)
         when matched then
           update set s.tag_count = t.tag_count;
    end loop;

    $IF $$VERBOSE_OUTPUT $THEN
    ks_log.log('END', l_scope);
    $END

end tag_sync;

/*******************************************************************
 * Maintain the collection elements when using search filters
 *   p_coll: collection_name
 *    p_sub: Optional sub level/area for the tags.
 *     p_id: ID being managed
 * p_status: YES/NO is the element checked (YES) or un-checked (NO)
 *******************************************************************/
procedure maintain_filter_coll(
       p_coll   in varchar2
     , p_sub    in varchar2 := null
     , p_id     in varchar2
     , p_status in varchar2 := 'NO')
is
  l_scope  ks_log.scope := gc_scope_prefix || 'maintain_filter_coll';

  l_seq_id number;
begin

  ks_log.log('START', l_scope);

  /*
  The collections being used:
    SESSIONTAGFILTER: For Session (abstract) filters
  */

  if p_coll in ('SESSIONTAGFILTER') then
    -- is this the top level selection
    if p_id = 'top' then

      -- Because it's the top level, empty the collection
      if apex_collection.collection_exists(p_coll) then
        apex_collection.truncate_collection(p_coll);
      else
        apex_collection.create_collection(p_coll);
      end if;

      -- the collection is already empty, but if the status
      -- is YES then we need to populate ALL of the elmemnts
      if p_status = 'YES' then
        for i in (
          select tag id from ks_tag_type_sums where content_type='SESSION' || nvl2(p_sub, ':' || p_sub, '') and p_coll = 'SESSIONTAGFILTER'
          )
        loop
          apex_collection.add_member(p_coll, p_c001 => i.id);
        end loop;
      end if;

    else
      -- We're dealing with a single element

      -- Create the collection if it doesn't exist.
      if not apex_collection.collection_exists(p_coll) then
          apex_collection.create_collection(p_coll);
      end if;

      -- The element was checked so add it
      if p_status = 'YES' then
          apex_collection.add_member(p_coll, p_c001 => p_id);
      else

        -- the element was unchecked so remove it.
        begin
        select seq_id
          into l_seq_id
          from apex_collections
         where collection_name = p_coll
           and c001 = p_id;

          apex_collection.delete_member(p_coll, l_seq_id);
        exception
        when NO_DATA_FOUND then
          null;
        end;
      end if;

    end if;
  end if;

  ks_log.log('END', l_scope);

end maintain_filter_coll;


end ks_tags_api;
/
