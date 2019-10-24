-- alter session set PLSQL_CCFLAGS='VERBOSE_OUTPUT:TRUE';
create or replace package body ks_session_load_api
is

--------------------------------------------------------------------------------
-- TYPES
/**
 * @type
 */

-- CONSTANTS
/**
 * @constant gc_scope_prefix: Standard logger package name
 * @constant gc_all_clob_columns: comma separeted list of columns that are clobs
 * @constant c_loaded_session_coll: Name of the collection created during the load session wizard
 * @column_names_t: is the table type for columns taken from the export file.
 * @c_max_errors_to_display: the maximum number of errors to display to the user.
 * @index_map_t: maps column numbers from the export file to column names in ks_full_session_load
*/
gc_scope_prefix      constant varchar2(31) := lower($$PLSQL_UNIT) || '.';
gc_all_clob_columns  constant varchar2(4000) := 'SESSION_DESCRIPTION';
c_session_load_table constant varchar2(30) := 'KS_FULL_SESSION_LOAD';
c_loaded_session_coll constant varchar2 (30) := 'LOADED_SESSIONS';

c_max_errors_to_display constant number := 6;

type column_names_t is varray(4000) of varchar2(4000);

-- type index_map_t is table of varchar2(30) index by varchar2(10);
type index_map_t is table of varchar2(30) index by pls_integer;



--==============================================================================
-- Function: add_error_check_continue
-- Purpose: Wrapper function for apex_error. It logs the error and if we've reached the threshold c_max_errors_to_display we return false.
--
-- Inputs:  p_message - message to be displayed
--          p_display_location - apex_error constant for display location
-- Output: whether we have crossed the c_max_errors_to_display threshold
-- Scope: Not publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/12/2017
--==============================================================================
function add_error_check_continue (p_message in varchar2,
                                   p_display_location in varchar2)
  return boolean
is
  l_scope ks_log.scope := 'add_error_check_continue';
  --l_params logger.tab_param;
begin
  --logger.append_param(l_params, 'p_message', p_message);
  --ks_log.append_param(l_params, 'p_display_location', p_display_location);
  ks_log.log('START', l_scope);

  apex_error.add_error(
            p_message => p_message
          , p_display_location => p_display_location
        );

  if apex_error.get_error_count >= c_max_errors_to_display
  then
    return false;
  else
    return true;
  end if;

exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end add_error_check_continue;




--==============================================================================
-- Function: check_continue
-- Purpose: Checks if we've reached the threshold c_max_errors_to_display. If so, then it returns false.
--
-- Inputs:  p_message - message to be displayed
--          p_display_location - apex_error constant for display location
-- Output: whether we have crossed the c_max_errors_to_display threshold
-- Scope: Not publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/12/2017
--==============================================================================
function check_continue
  return boolean
is
  l_scope ks_log.scope := 'check_continue';
  --l_params logger.tab_param;
begin
  --logger.append_param(l_params, 'p_message', p_message);
  --ks_log.append_param(l_params, 'p_display_location', p_display_location);
  ks_log.log('START', l_scope);


  if apex_error.get_error_count >= c_max_errors_to_display
  then
    return false;
  else
    return true;
  end if;

exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end check_continue;




--==============================================================================
-- Function: validate_uniqueness
-- Purpose:
--
-- Inputs:
-- Output:
-- Scope: Not publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/13/2017
--==============================================================================
function validate_uniqueness
  return boolean
is
  l_scope ks_log.scope := gc_scope_prefix || 'validate_uniqueness';

  l_count number;
  l_username varchar2(60);
begin
  ks_log.log('START', l_scope);

  l_username := v('APP_USER');

  for row in (
    select session_num
      from ks_full_session_load
     where app_user = l_username
     group by session_num
    having count(*) > 1
  )
  loop
    if not add_error_check_continue(p_message => 'The session_number "' || row.session_num || '", is not unique. Correct to continue.'
                             ,  p_display_location => apex_error.c_inline_in_notification
                                )
    then
      return false;
    end if;
  end loop;

  --Do the same thing for external_sys_ref
  for row in (
    select external_sys_ref
      from ks_full_session_load
     where app_user = l_username
     group by external_sys_ref
     having count(*) > 1
  )
  loop
    if not add_error_check_continue(
        p_message => 'The session id (external system reference) "' || row.external_sys_ref || '", is not unique. Correct to continue.'
      , p_display_location => apex_error.c_inline_in_notification
    )
    then
      return false;
    end if;
  end loop;

  if apex_error.get_error_count > 0
  then
    return false;
  end if;

  return true;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end validate_uniqueness;



--==============================================================================
-- Function: validate_not_null
-- Purpose:
--
-- Inputs:
-- Output:
-- Scope: Not publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/13/2017
--==============================================================================
function validate_not_null
  return boolean
is
  l_scope ks_log.scope := gc_scope_prefix || 'validate_not_null';

  l_username varchar2(60);
begin
  ks_log.log('START', l_scope);

  l_username := v('APP_USER');

  for row in (
    select title
      from ks_full_session_load
     where app_user = l_username
       and ( session_num is null
          or external_sys_ref is null
        )
  )
  loop
    if not add_error_check_continue(
        p_message => 'Session "' || substr(row.title,1,20) || '" is missing a session_num or external_sys_ref.'
      , p_display_location => apex_error.c_inline_in_notification
    )
    then
      return false;
    end if;
  end loop;


  for row in (
    select session_num || ':' || title name
      from ks_full_session_load
     where app_user = l_username
       and event_track_id is null
  )
  loop
    if not add_error_check_continue(
        p_message => 'Session "' || substr(row.name,1,20) || '" is missing a track.'
      , p_display_location => apex_error.c_inline_in_notification
    )
    then
      return false;
    end if;
  end loop;


  if apex_error.get_error_count > 0
  then
    return false;
  end if;

  ks_log.log('END', l_scope);

  return true;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end validate_not_null;



--==============================================================================
-- Function: validate_new_session
-- Purpose:
--
-- Inputs:
-- Output:
-- Scope: Not publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/13/2017
--==============================================================================
function validate_new_session(p_into_event_id varchar2)
  return boolean
is
  l_scope ks_log.scope := gc_scope_prefix || 'validate_new_session';

  l_username varchar2(60);
begin
  ks_log.log('START', l_scope);

  l_username := v('APP_USER');

  for row in (
    select sl.session_num
      from ks_full_session_load sl
         , ks_sessions s
     where sl.app_user = l_username
       and s.session_num = sl.session_num
       and s.event_id = p_into_event_id
  )
  loop
    if not add_error_check_continue(
        p_message => 'A session with session number "' || row.session_num || '" already exists for this event.'
      , p_display_location => apex_error.c_inline_in_notification
    )
    then
      return false;
    end if;
  end loop;


  for row in (
    select sl.external_sys_ref
      from ks_full_session_load sl
         , ks_sessions s
     where sl.app_user = l_username
       and s.external_sys_ref = sl.external_sys_ref
       and s.event_id = p_into_event_id
  )
  loop
    if not add_error_check_continue(
        p_message => 'A session with session id (external_sys_ref) "' || row.external_sys_ref || '" already exists for this event.'
      , p_display_location => apex_error.c_inline_in_notification
    )
    then
      return false;
    end if;
  end loop;


  if apex_error.get_error_count > 0
  then
    return false;
  end if;

  ks_log.log('END', l_scope);

  return true;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end validate_new_session;




--==============================================================================
-- Function: validate_correct_tracks
-- Purpose:
--
-- Inputs: p_into_event_id - the id of the event
-- Output:
-- Scope: Not publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/13/2017
--==============================================================================
function validate_correct_tracks(p_into_event_id varchar2)
  return boolean
is
  l_scope ks_log.scope := gc_scope_prefix || 'validate_correct_tracks';

  l_username varchar2(60);

begin
  ks_log.log('START', l_scope);

  l_username := v('APP_USER');

  --First check the track
  -- Sorry, ks_full_session_load.event_track_id is not an ID at all but a name!
  for row in (
    select distinct sl.event_track_id
      from ks_full_session_load sl
     where sl.app_user = l_username
       and sl.event_track_id not in (
        select name
          from ks_event_tracks
         where event_id = p_into_event_id
     )
  )
  loop
    if not add_error_check_continue(
        p_message => 'The track "'|| row.event_track_id ||'" does not exist for this event.'
      , p_display_location => apex_error.c_inline_in_notification
    )
    then
      ks_log.log('Missing track, Abort!', l_scope);
      return false;
    end if;
  end loop;

  ks_log.log('END', l_scope);
  
  return true;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end validate_correct_tracks;





--==============================================================================
-- Function: validate_data
-- Purpose: Runs validations checks on the data. This occurs after ks_full_session_load is loaded and it's columns are validated,
--             but before we have submitted it's data to the corresponding tables.
--
-- Inputs: p_into_event_id, the id the of the event
-- Output: whether the data is avalid or not
-- Scope: Publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/12/2017
--==============================================================================
function validate_data(p_into_event_id ks_event_tracks.event_id%TYPE)
  return boolean
is
  l_scope ks_log.scope := gc_scope_prefix || 'validate_data';

begin
  ks_log.log('START', l_scope);

  if not validate_uniqueness
  then
    if not check_continue then
      return false;
    end if;
  end if;

  if not validate_not_null
  then
    if not check_continue then
      return false;
    end if;
  end if;

  if not validate_new_session(p_into_event_id => p_into_event_id)
  then
    if not check_continue then
      return false;
    end if;
  end if;

  if not validate_correct_tracks(p_into_event_id => p_into_event_id)
  then
    if not check_continue then
      return false;
    end if;
  end if;


  if apex_error.get_error_count > 0
  then
    return false;
  end if;

  ks_log.log('END', l_scope);

  return true;
exception
  when others then
    ks_log.log_error('Unhandled Exception', l_scope);
    raise;
end validate_data;





--==============================================================================
-- Function: validate_column_names
-- Purpose: This makes sure that the first row of the .xlsx file contains row names FOR EACH column in ks_session_load (minus event_id, track_id, and app_user)
--
-- Inputs: p_column_names - varray of column names
-- Output: returns true if valid, false if invalid
-- Scope: Not  Publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/09/2017
--==============================================================================
function validate_column_names (p_column_names in column_names_t)
return boolean
is
  l_scope ks_log.scope := 'validate_column_names';
  --l_params logger.tab_param;
  type column_names_dict_t is table of varchar2(20) index by varchar2(4000);
  l_column_names_dict column_names_dict_t;

  i number := 0;
  idx varchar2(4000);
begin
  --logger.append_param(l_params, 'p_column_names', p_column_names);
  ks_log.log('START', l_scope);


  for row in (
    select trim(upper(lm.header_name)) header
      from ks_load_mapping lm
     where table_name = c_session_load_table
  )
  loop
    l_column_names_dict(row.header) := 'not_matched';
  end loop;

  for i in 1..p_column_names.count
  loop
      if not l_column_names_dict.exists(trim(upper(p_column_names(i))))
      then
        if not add_error_check_continue(p_message => 'The column "' || p_column_names(i) || '" does not match any column names specified in the instructions.'
                                     ,  p_display_location => apex_error.c_inline_in_notification
                            )
        then
          return false;
        end if;
      else
        l_column_names_dict(trim(upper(p_column_names(i)))) := 'matched';
      end if;
  end loop;

  ks_log.log('before l_column_names_dict loop', l_scope);

  idx := l_column_names_dict.first;
  while idx is not null
  loop
    if l_column_names_dict(idx) = 'not_matched'
    then
      ks_log.log('Not matched l_column_names_dict(' || idx || '):', l_scope);
      if not add_error_check_continue(p_message => 'The column "' || initcap(idx) || '", was not found in the file. Please ensure this column exists in the file.'
                       ,  p_display_location => apex_error.c_inline_in_notification
                            )
       then
        return false;
       end if;
    end if;
    idx := l_column_names_dict.next(idx);
  end loop;

  ks_log.log('after l_column_names_dict loop. Errors:' || apex_error.get_error_count, l_scope);

  if apex_error.get_error_count > 0 then
    return false;
  else
    return true;
  end if;

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end validate_column_names;




--==============================================================================
-- Function: validate_column_order
-- Purpose: validates that the columns provided in the export file are in the correct order
--
-- Inputs:  p_column_names - an array of colum names
-- Output: returns true if valid, false if invalid
-- Scope: Not Publicly accessible
-- Errors: Logged and Raised.
-- Notes: THIS FUNCTION IS NOT USED - the function works, but turned out to not be useful.
-- Author: Ben Shumway (Insum Solutions) - Oct/11/2017
--==============================================================================
function validate_column_order (p_column_names in column_names_t)
  return boolean
is
  l_scope ks_log.scope := 'validate_column_order';
  --l_params logger.tab_param;
  l_idx number := 1;
  l_columns_in_their_order varchar2(4000);
begin
  --logger.append_param(l_params, 'p_column_names', p_column_names);
  ks_log.log('START', l_scope);

  for row in (select trim(upper(lm.header_name)) header_name,
                     display_seq
              from ks_load_mapping lm
             where 1=1
            and table_name = c_session_load_table
            and lm.to_column_name is not null
            order by lm.display_seq
            )
  loop
    if p_column_names(row.display_seq) != row.header_name
    then
      select listagg(lm.header_name, ', ') within group (order by lm.display_seq) value
        into l_columns_in_their_order
        from ks_load_mapping lm
        where 1=1
          and table_name = c_session_load_table;


        apex_error.add_error(
                  p_message => 'The columns in the export file are in an incorrect order. The proper order is: ' ||
                                  l_columns_in_their_order || '. At least this column is out of order: ' || p_column_names(l_idx)
                , p_display_location => apex_error.c_inline_in_notification
              );
      --This is a big error (lots of text), so exit here regardless of number of errors.
      return false;
    end if;

  end loop;

  return true;
exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end validate_column_order;



--==============================================================================
-- Procedure: init_index_map
-- Purpose: After the column names have been validated from the file,
--            we need to map which columns headers in the export go to which columns in ks_full_session_load
-- ASUMPTION(S): Column names are valid, and there aren't any missing
-- Inputs:  l_column_names - column names from the import file
--          l_cells - the final table we will create our view from.
-- Output:
-- Scope: Not Publicly accessible
-- Errors: Logged and Raised.
-- Notes:
-- Author: Ben Shumway (Insum Solutions) - Oct/11/2017
--==============================================================================
procedure init_index_map ( p_index_map in out nocopy index_map_t)
is
  l_scope ks_log.scope := gc_scope_prefix || 'init_index_map';
  --l_params logger.tab_param;

  l_index pls_integer;
begin
  --logger.append_param(l_params, 'l_column_names', l_column_names);
  ks_log.log('START', l_scope);

  for row in (
    select m.to_column_name
         , m.display_seq
      from ks_load_mapping m
     where m.table_name = c_session_load_table
     order by m.display_seq
  )
  loop
    p_index_map(p_index_map.count + 1) := nvl(row.to_column_name, '- not mapped -');
    ks_log.log('mapped: ' || p_index_map.count || ' to '  || row.to_column_name, l_scope);
  end loop;

  ks_log.log('map size: ' || p_index_map.count, l_scope);

  $IF $$VERBOSE_OUTPUT $THEN
  l_index := p_index_map.first;
  while l_index is not null
  loop
    ks_log.log('p_index_map(' || l_index ||'): ' || p_index_map(l_index), l_scope);    
    l_index := p_index_map.next(l_index);
  end loop;
  $END

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end init_index_map;


/**
 * Load data from xlsx into appropriate collection for parsing. All data is
 * loaded to into the session APP_USER
 *
 * @example
 * 
 * @issue
 *
 * @author Ben Shumway (Insum Solutions)
 * @created Oct/09/2017
 * @param p_xlsx blob with all data
 */
procedure load_xlsx_data (
    p_xlsx      in blob
  , p_username  in varchar2 default v('APP_USER')
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'load_xlsx_data';

  l_column_names column_names_t;

  l_cells as_read_xlsx_clob.tp_all_cells;
  l_curr_row number;

  l_rows_row number;

  type session_load_row_t is table of ks_full_session_load%rowtype;
  l_rows session_load_row_t;

  l_curr_col varchar2(30);

  --column index for spreadsheet_content
  l_col_ind number;

  l_index_map index_map_t;
  l_index pls_integer;

  --used to get the first 4000 bytes of any string data
  l_substr varchar2(4000);
  --used to get the length of the string data
  l_substr_len number;

  l_string_val clob;
  l_number_val number;
  l_date_val date;

  l_reached_final_line boolean := false;

  --An array of tags
  l_tags apex_application_global.vc_arr2;

  --An array of session_length
  l_session_length apex_application_global.vc_arr2;
    

begin
   --logger.append_param(l_params, 'p_username', p_username);
   --logger.append_param(l_params, 'p_into_event_id', p_into_event_id);
   --logger.append_param(l_params, 'p_into_track_id', p_into_track_id);
   ks_log.log('BEGIN', l_scope);

   l_column_names := column_names_t();
   l_rows := session_load_row_t();

   select *
    bulk collect into l_cells
    from table(AS_READ_XLSX_CLOB.read(p_xlsx => p_xlsx))
   order by row_nr, col_nr;

   for i in 1 ..  l_cells.count
   loop
      l_curr_row := l_cells(i).row_nr;
      $IF $$VERBOSE_OUTPUT $THEN
      ks_log.log('BEGIN cell: ' ||  l_cells(i).row_nr || ',' || l_cells(i).col_nr, l_scope);
      $END

      --NOTE: Assumption, the bulk collect gets all cells in order by row then column
      if l_curr_row = 2 and l_cells(i).col_nr = 1
      then
        $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log('Length of l_column_names: ' || l_column_names.count, l_scope);
        $END
        if not ks_session_load_api.validate_column_names(l_column_names) then
          return;
        end if;

        --modify l_cells so that the column names are correct
        init_index_map(l_index_map);

      elsif l_curr_row = 1 then
        l_column_names.extend;
        --Get the column name (allows the .xlsx header to be defined "fuzzilly"
        $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log('Adding name: "' || l_cells(i).string_val || '"" to (' || i || ')', l_scope);
        $END
        l_column_names(i) := trim(upper(cast(l_cells(i).string_val as varchar2)));
     end if;

     $IF $$VERBOSE_OUTPUT $THEN
     ks_log.log('i: ' || i, l_scope);
     $END

     if l_curr_row > 1 then

        if l_rows.count < l_curr_row -1 then
          if l_reached_final_line then
            l_rows.delete(l_rows.count);
            exit;
          else
            l_reached_final_line := true; --Considered true until proven otherwise
          end if;
          l_rows.extend;
        end if;

        -- l_string_val := coalesce(l_cells(i).string_val, to_char(l_cells(i).number_val), to_char(l_cells(i).date_val));

        l_string_val := trim(l_cells(i).string_val);
        l_number_val := l_cells(i).number_val;
        l_date_val := l_cells(i).date_val;

        l_rows_row := l_curr_row -1;

        if   l_string_val is not null
          or l_number_val is not null
          or l_date_val is not null
        then
          l_reached_final_line := false;
        end if;
        
        if l_number_val is not null
        then
          $IF $$VERBOSE_OUTPUT $THEN
          ks_log.log('found number column, converting to vc', l_scope);
          $END
          l_string_val := to_char(l_number_val);
        end if;

        $IF $$VERBOSE_OUTPUT $THEN
        ks_log.log('current:' || l_string_val, l_scope);
        $END


        --The commented out code shows when the as_read_xlsx_clob package skips cells
        /*ks_log.log('Checking existence of: ' || to_char(case when 
                                                                  mod(i, l_column_names.count) = 0 
                                                                  then l_column_names.count 
                                                                  else mod(i, l_column_names.count)
                                                                  end) || ', l_cells(i).col_nr: ' || l_cells(i).col_nr 
                                                                       || ', string_val: ' || l_cells(i).string_val );
        l_index := to_char(case when 
                                                                  mod(i, l_column_names.count) = 0 
                                                                  then l_column_names.count 
                                                                  else mod(i, l_column_names.count)
                                                                  end);*/
        l_index := l_cells(i).col_nr;
        if l_index_map.exists(l_index) then

          l_curr_col := l_index_map(l_index);
          $IF $$VERBOSE_OUTPUT $THEN
          ks_log.log('l_curr_col: ' || l_curr_col, l_scope);
          $END
          
          if l_curr_col = 'EXTERNAL_SYS_REF'
          then            
            l_rows(l_rows_row).external_sys_ref := l_string_val;
          elsif l_curr_col = 'SESSION_NUM'
          then
            l_rows(l_rows_row).session_num :=  l_string_val;
          elsif l_curr_col = 'EVENT_TRACK_ID'
          then
            l_rows(l_rows_row).event_track_id := l_string_val;
          elsif l_curr_col = 'SUB_CATEGORY'
          then
            l_rows(l_rows_row).sub_category := substr(l_string_val,1,500);
          elsif l_curr_col = 'SESSION_TYPE'
          then
            l_rows(l_rows_row).session_type := substr(l_string_val,1,500);
          elsif l_curr_col = 'TITLE'
          then
            l_rows(l_rows_row).title := substr(l_string_val,1,500);
          elsif l_curr_col = 'ACE_LEVEL'
          then
            l_rows(l_rows_row).ace_level := substr(l_string_val,1,30);
          elsif l_curr_col = 'COMPANY'
          then
            l_rows(l_rows_row).company := substr(l_string_val,1,500);
          elsif l_curr_col = 'SESSION_ABSTRACT'
          then
            l_rows(l_rows_row).session_abstract := l_string_val;
          elsif l_curr_col = 'SESSION_SUMMARY'
          then
            l_rows(l_rows_row).session_summary := substr(l_string_val,1,4000);
          elsif l_curr_col = 'TARGET_AUDIENCE'
          then
            l_rows(l_rows_row).target_audience := substr(l_string_val,1,60);
          elsif l_curr_col = 'TECHNOLOGY_PRODUCT'
          then
            l_rows(l_rows_row).technology_product := substr(l_string_val,1,500);
          elsif l_curr_col = 'PRESENTED_BEFORE_IND'
          then
            l_rows(l_rows_row).presented_before_ind := l_string_val;
          elsif l_curr_col = 'PRESENTED_BEFORE_WHERE'
          then
            l_rows(l_rows_row).presented_before_where := substr(l_string_val,1,4000);
          elsif l_curr_col = 'PRESENTED_ANYTHING_IND'
          then
            l_rows(l_rows_row).presented_anything_ind := l_string_val;
          elsif l_curr_col = 'PRESENTED_ANYTHING_WHERE'
          then
            l_rows(l_rows_row).presented_anything_where := substr(l_string_val,1,4000);            
          elsif l_curr_col = 'VIDEO_LINK'
          then
            l_rows(l_rows_row).video_link := substr(l_string_val,1,4000);
          elsif l_curr_col = 'CO_PRESENTER'
          then
            l_rows(l_rows_row).co_presenter := substr(l_string_val,1,500);
          elsif l_curr_col = 'CO_PRESENTER_COMPANY'
          then
            l_rows(l_rows_row).co_presenter_company := substr(l_string_val,1,500);
          elsif l_curr_col = 'PRESENTER_BIOGRAPHY'
          then
            l_rows(l_rows_row).presenter_biography := l_string_val;
          elsif l_curr_col = 'PRESENTER'
          then
            l_rows(l_rows_row).presenter := substr(l_string_val,1,500);
          elsif l_curr_col = 'TAGS'
          then
            l_tags := apex_util.string_to_table(l_string_val,',');
            for i in 1..l_tags.count
            loop
              l_tags(i) := trim(l_tags(i));
            end loop;
            l_rows(l_rows_row).tags := substr(apex_util.table_to_string(l_tags,':'),1,1000);
          elsif l_curr_col = 'SESSION_LENGTH'
          then
            l_session_length := apex_util.string_to_table(l_string_val,',');
            for i in 1..l_session_length.count
            loop
              l_session_length(i) := trim(l_session_length(i));
            end loop;
            l_rows(l_rows_row).session_length := substr(apex_util.table_to_string(l_session_length,':'),1,500);
          elsif l_curr_col = 'CONTAINS_DEMO_IND'
          then
            l_rows(l_rows_row).contains_demo_ind := l_string_val;
          elsif l_curr_col = 'WEBINAR_WILLING_IND'
          then
            l_rows(l_rows_row).webinar_willing_ind := l_string_val;
          elsif l_curr_col = 'PRESENTER_EMAIL'
          then
            l_rows(l_rows_row).presenter_email := substr(l_string_val,1,500);
          elsif l_curr_col = 'CO_PRESENTER_USER_ID'
          then
            l_rows(l_rows_row).co_presenter_user_id := case when l_number_val = 0 then null else l_number_val end;
          elsif l_curr_col = 'PRESENTER_USER_ID'
          then
            l_rows(l_rows_row).presenter_user_id :=  case when l_number_val = 0 then null else l_number_val end;
          elsif l_curr_col = 'SUBMISSION_DATE'
          then
            -- l_rows(l_rows_row).submission_date := to_date(l_string_val, 'DD/MM/RR HH24:MI');
            l_rows(l_rows_row).submission_date := l_date_val;
          end if;

        end if;
      end if;
    end loop;


    ks_log.log('Removing previous load data (if present)', l_scope);
    delete 
      from ks_full_session_load s
     where app_user = p_username;


    ks_log.log('Inserting into ks_full_session_load', l_scope);
    forall i in l_rows.first .. l_rows.last
      insert into ks_full_session_load (
          app_user
        , external_sys_ref
        , session_num
        , event_track_id
        , sub_category
        , session_type
        , title
        , ace_level
        , presented_before_ind
        , presented_before_where
        , presented_anything_ind
        , presented_anything_where
        , video_link
        , co_presenter
        , co_presenter_company
        , presenter_biography
        , company
        , presenter
        , session_abstract
        , session_summary
        , tags
        , session_length
        , target_audience
        , technology_product
        , contains_demo_ind
        , webinar_willing_ind
        , presenter_email
        , co_presenter_user_id
        , presenter_user_id
        , submission_date
      )
      values (
          p_username
        , l_rows(i).external_sys_ref
        , l_rows(i).session_num
        , l_rows(i).event_track_id
        , l_rows(i).sub_category
        , l_rows(i).session_type
        , l_rows(i).title
        , l_rows(i).ace_level
        , l_rows(i).presented_before_ind
        , l_rows(i).presented_before_where
        , l_rows(i).presented_anything_ind
        , l_rows(i).presented_anything_where
        , l_rows(i).video_link
        , l_rows(i).co_presenter
        , l_rows(i).co_presenter_company
        , l_rows(i).presenter_biography
        , l_rows(i).company
        , l_rows(i).presenter
        , l_rows(i).session_abstract
        , l_rows(i).session_summary
        , l_rows(i).tags || nvl2(l_rows(i).session_length, nvl2(l_rows(i).tags, ':', ''), '') || l_rows(i).session_length
        , l_rows(i).session_length
        , l_rows(i).target_audience
        , l_rows(i).technology_product
        , l_rows(i).contains_demo_ind
        , l_rows(i).webinar_willing_ind
        , l_rows(i).presenter_email
        , l_rows(i).co_presenter_user_id
        , l_rows(i).presenter_user_id
        , l_rows(i).submission_date
      );

  ks_log.log('END', l_scope);
  
  exception when others
  then
    ks_log.log('ERROR', l_scope);
    raise;

end load_xlsx_data;



/**
 *
 *
 * @example
 *  ks_session_load_api.load_sessions(
 *      p_event_id   => :P5040_EVENT_ID
 *    , x_load_count => :P5041_ROW_COUNT
 *  );
 * 
 * @issue
 *
 * @author Jorge Rimblas
 * @created January 6, 2018
 * @param p_event_id
 * @param p_username (optional)
 * @param x_load_count - final load count
 * @return
 */
procedure load_sessions (
    p_event_id   in ks_events.id%TYPE
  , p_username   in varchar2 default v('APP_USER')
  , x_load_count in out number
)
is
  l_scope  ks_log.scope := gc_scope_prefix || 'load_sessions';
begin
  ks_log.log('BEGIN', l_scope);

  insert into ks_sessions(
      id
    , event_id
    , event_track_id
    , external_sys_ref
    , session_num
    , sub_category
    , session_type
    , title
    , presenter
    , company
    , co_presenter
    , co_presenter_company
    , tags
    , presenter_email
    , session_abstract
    , session_summary
    , target_audience
    , presented_before_ind
    , presented_before_where
    , presented_anything_ind
    , presented_anything_where
    , technology_product
    , ace_level
    , video_link        
    , contains_demo_ind
    , webinar_willing_ind
    , presenter_biography
    , co_presenter_user_id
    , presenter_user_id
    , submission_date
   )            
  select null
       , p_event_id
       , e.id
       , s.external_sys_ref
       , s.session_num
       , s.sub_category
       , s.session_type
       , s.title
       , s.presenter
       , s.company
       , s.co_presenter
       , s.co_presenter_company
       , s.tags
       , s.presenter_email
       , s.session_abstract
       , s.session_summary
       , s.target_audience
       , decode(trim(lower(s.presented_before_ind))
          , null, 'N'
          , 'n', 'N'
          , 'yes', 'Y'
          , 'y', 'Y'
          , 'N'
         )
       , s.presented_before_where
       , decode(trim(lower(s.presented_anything_ind))
          , null, 'N'
          , 'n', 'N'
          , 'yes', 'Y'
          , 'y', 'Y'
          , 'N'
         )
       , s.presented_anything_where
       , s.technology_product        
       , s.ace_level
       , s.video_link        
       , decode(trim(lower(s.contains_demo_ind))
          , null, 'N'
          , 'n', 'N'
          , 'yes', 'Y'
          , 'y', 'Y'
          , 'N'
         )
       , decode(trim(lower(s.webinar_willing_ind))
          , null, 'N'
          , 'n', 'N'
          , 'yes', 'Y'
          , 'y', 'Y'
          , 'N'
         )
       , s.presenter_biography
       , co_presenter_user_id
       , presenter_user_id
       , coalesce(submission_date, sysdate)
    from ks_full_session_load s
         left outer join ks_event_tracks e on s.event_track_id = e.name and e.event_id = p_event_id
   where s.app_user = p_username
   order by s.session_num;

  x_load_count := SQL%ROWCOUNT;

  ks_log.log('END', l_scope);

  exception
    when OTHERS then
      ks_log.log_error('Unhandled Exception', l_scope);
      raise;
end load_sessions;






/**
 * Process to purge votes, sessions and tags from and event and/or track.
 *
 * @example
 *
 * @issue
 *
 * @author Guillermo Hernandez
 * @created October 25, 2017
 * @param p_event_id id of the specific event.
 * @param p_track_id id of a specific track.
 * @param p_votes_only_ind to specify that only votes should be deleted.
 * @param p_force_ind to force the execution of the process even when votes
 *                    are present.
 */
procedure purge_event(
  p_event_id          in ks_sessions.event_id%TYPE
  , p_track_id        in ks_sessions.event_track_id%TYPE default null
  , p_votes_only_ind  in varchar2
  , p_force_ind       in varchar2
)
is
  l_scope  ks_log.scope := gc_scope_prefix || 'purge_event';

  no_action exception;

  l_votes_count number := 0;

begin
  ks_log.log('BEGIN', l_scope);

  -- This count is for pretection.
  -- We don't want to delete when there are votes present.
  select count(1)
    into l_votes_count
    from ks_session_votes v
       , ks_sessions s
   where v.session_id = s.id
     and s.event_id = p_event_id
     and (p_track_id is null or s.event_track_id = p_track_id)
     and p_votes_only_ind = 'N';


  if l_votes_count > 0 then
    -- if this parameter equals No 'N' then the process raises an error indicating no action will be done.
    raise no_action;
  end if;


  -- Delete the votes when the user selects "Votes Only" or "Force Purge"
  delete 
    from ks_session_votes v
   where v.session_id in (
      select ss.id
        from ks_sessions ss
       where ss.event_id = p_event_id
         and (p_track_id is null or ss.event_track_id = p_track_id)
   )
     and (p_votes_only_ind = 'Y' or p_force_ind = 'Y');


  -- Only delete sessions when the there are no votes and user selected Votes Only
  -- OR 
  -- Delete when user selected "Force Purge"
  delete
    from ks_sessions
   where event_id = p_event_id
     and (p_track_id is null or event_track_id = p_track_id)
     and ( (l_votes_count = 0 and p_votes_only_ind = 'N')
         or p_force_ind = 'Y'
       );


  -- Remove unused tags after the "delete ks_sessions"
  --   When the there are no votes and user selected Votes Only
  --   OR 
  --   Delete when user selected "Force Purge"
  delete
    from ks_tag_type_sums ts
   where exists (
    select 1
     from ks_tag_type_sums s
        , ks_event_tracks t
    where s.content_type = 'SESSION' || ':' || t.id
      and s.tag_count = 0
      and s.rowid = ts.rowid
      and t.event_id = p_event_id
      and (p_track_id is null or t.id = p_track_id)
   )
    and ( (l_votes_count = 0 and p_votes_only_ind = 'N')
        or p_force_ind = 'Y'
      );

  ks_log.log('END', l_scope);

  exception
    when no_action then
      raise_application_error (-20000,'Votes are present. Purge action aborted.');
    
end purge_event;




/**
 * Create collection session loaded having
 *    - The name of the track 
 *    - The number of loaded sessions by track
 *    - The checked flag (set Y by default)
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/07/2019
 * @param 
 */
procedure create_loaded_session_coll (
    p_event_id   in ks_events.id%TYPE
  , p_username   in varchar2 default v('APP_USER')
)
is
  l_scope ks_log.scope := gc_scope_prefix || 'create_loaded_session_coll';
  l_sql varchar2 (32000);
  l_param_names apex_application_global.vc_arr2;
  l_param_values apex_application_global.vc_arr2;
begin
  ks_log.log('START', l_scope);
  
  l_sql := q'[select e.id track_id
          ,count(*) session_count
          ,null
          ,null
          ,null
          ,null
          ,null
          ,null
          ,null
          ,null
          ,s.event_track_id track_name
          ,'Y' notify_ind
  from    ks_full_session_load s
  left    outer join ks_event_tracks e 
  on      s.event_track_id = e.name 
  and     e.event_id = :p_event_id
  where   s.app_user = :p_username
  group   by s.event_track_id
         ,e.id]';

  if apex_collection.collection_exists (p_collection_name => c_loaded_session_coll) then 
    apex_collection.delete_collection (p_collection_name  => c_loaded_session_coll);
  end if;

  l_param_names(l_param_names.count + 1) := 'p_event_id';
  l_param_values(l_param_values.count + 1) := p_event_id;
  
  l_param_names(l_param_names.count + 1) := 'p_username';
  l_param_values(l_param_values.count + 1) := p_username;

  apex_collection.create_collection_from_queryb2 (
    p_collection_name => c_loaded_session_coll
   ,p_query           => l_sql
   ,p_names           => l_param_names
   ,p_values          => l_param_values
  );

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception', l_scope);
    raise;
end create_loaded_session_coll;



/**
 * Toggle the notification status of a loaded track
 *
 * @example
 * 
 * @issue
 *
 * @author Juan Wall (Insum Solutions)
 * @created Nov/08/2019
 * @param p_seq_id position in the collection
 * @param p_notification_ind Y|N
 */
procedure toggle_track_notification(p_seq_id in number)
is
  l_scope ks_log.scope := gc_scope_prefix || 'toggle_track_notification';

  l_notification_ind varchar2(1);

begin
  ks_log.log('START', l_scope);
  ks_log.log('p_seq_id:' || p_seq_id, l_scope);
  
  -- Get the new value
  select decode(notify_ind, 'Y', 'N', 'Y')
    into l_notification_ind
    from ks_session_load_coll_v
   where seq_id = p_seq_id;

  ks_log.log('l_notification_ind:' || l_notification_ind, l_scope);

  apex_collection.update_member_attribute  (
      p_collection_name => c_loaded_session_coll
    , p_seq => p_seq_id
    , p_attr_number => 2
    , p_attr_value  => l_notification_ind
  );

  ks_log.log('END', l_scope);

exception
  when others then
    ks_log.log('Unhandled Exception:' || sqlerrm, l_scope);
    raise;
end toggle_track_notification;



end ks_session_load_api;
/
