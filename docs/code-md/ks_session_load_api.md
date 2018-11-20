# KS_SESSION_LOAD_API



- [Constants](#constants)

- [Variables](#variables)

- [Exceptions](#exceptions)

- [LOAD_XLSX_DATA Procedure](#load_xlsx_data)
- [LOAD_SESSIONS Procedure](#load_sessions)
- [PURGE_EVENT Procedure](#purge_event)
- [CREATE_LOADED_SESSION_COLL Procedure](#create_loaded_session_coll)
- [TOGGLE_TRACK_NOTIFICATION Procedure](#toggle_track_notification)



## Variables<a name="variables"></a>

Name | Code | Description
--- | --- | ---
 | <pre>l_index := l_cells(i).col_nr;</pre> | 
end | <pre>    end loop;</pre> | 
end | <pre>  end if;</pre> | 
end | <pre>end if;</pre> | 
end | <pre>      end if;</pre> | 
end | <pre>    end loop;</pre> | 
end | <pre>end load_xlsx_data;</pre> | 

## Constants<a name="constants"></a>

Name | Code | Description
--- | --- | ---
gc_scope_prefix | <pre>gc_scope_prefix      constant varchar2(31) := lower($$PLSQL_UNIT) || '.';</pre> | 
gc_all_clob_columns | <pre>gc_all_clob_columns  constant varchar2(4000) := 'SESSION_DESCRIPTION';</pre> | 
c_session_load_table | <pre>c_session_load_table constant varchar2(30) := 'KS_FULL_SESSION_LOAD';</pre> | 
c_loaded_session_coll | <pre>c_loaded_session_coll constant varchar2 (30) := 'LOADED_SESSIONS';</pre> | 
c_max_errors_to_display | <pre>c_max_errors_to_display constant number := 4;</pre> | 

## Exceptions<a name="exceptions"></a>

Name | Code | Description
--- | --- | ---
 | <pre>l_index := l_cells(i).col_nr;</pre> | 
end | <pre>    end loop;</pre> | 
end | <pre>  end if;</pre> | 
end | <pre>end if;</pre> | 
end | <pre>      end if;</pre> | 
end | <pre>    end loop;</pre> | 
end | <pre>end load_xlsx_data;</pre> | 




 
## LOAD_XLSX_DATA Procedure<a name="load_xlsx_data"></a>


<p>
<p>Load data from xlsx into appropriate collection for parsing. All data is<br />loaded to into the session APP_USER</p>
</p>

### Syntax
```plsql
procedure load_xlsx_data (
    p_xlsx      in blob
  , p_username  in varchar2 default v('APP_USER')
)
```

### Parameters
Name | Description
--- | ---
`p_xlsx` | blob with all data
 
 





 
## LOAD_SESSIONS Procedure<a name="load_sessions"></a>


<p>

</p>

### Syntax
```plsql
procedure load_sessions (
    p_event_id   in ks_events.id%TYPE
  , p_username   in varchar2 default v('APP_USER')
  , x_load_count in out number
)
```

### Parameters
Name | Description
--- | ---
`p_event_id` | 
`p_username` | (optional)
`x_load_count` | <ul>
<li>final load count</li>
</ul>

 
 


### Example
```plsql
 ks_session_load_api.load_sessions(
     p_event_id   => :P5040_EVENT_ID
   , x_load_count => :P5041_ROW_COUNT
 );
```



 
## PURGE_EVENT Procedure<a name="purge_event"></a>


<p>
<p>Process to purge votes, sessions and tags from and event and/or track.</p>
</p>

### Syntax
```plsql
procedure purge_event(
  p_event_id          in ks_sessions.event_id%TYPE
  , p_track_id        in ks_sessions.event_track_id%TYPE default null
  , p_votes_only_ind  in varchar2
  , p_force_ind       in varchar2
)
```

### Parameters
Name | Description
--- | ---
`p_event_id` | id of the specific event.
`p_track_id` | id of a specific track.
`p_votes_only_ind` | to specify that only votes should be deleted.
`p_force_ind` | to force the execution of the process even when votes                    are present.
 
 





 
## CREATE_LOADED_SESSION_COLL Procedure<a name="create_loaded_session_coll"></a>


<p>
<p>Create collection session loaded having</p><ul>
<li>The name of the track </li>
<li>The number of loaded sessions by track</li>
<li>The checked flag (set Y by default)</li>
</ul>

</p>

### Syntax
```plsql
procedure create_loaded_session_coll (
    p_event_id   in ks_events.id%TYPE
  , p_username   in varchar2 default v('APP_USER')
)
```

### Parameters
Name | Description
--- | ---
`` | 
 
 





 
## TOGGLE_TRACK_NOTIFICATION Procedure<a name="toggle_track_notification"></a>


<p>
<p>Toggle the notification status of a loaded track</p>
</p>

### Syntax
```plsql
procedure toggle_track_notification(p_seq_id in number)
```

### Parameters
Name | Description
--- | ---
`p_seq_id` | position in the collection
`p_notification_ind` | Y|N
 
 





 
