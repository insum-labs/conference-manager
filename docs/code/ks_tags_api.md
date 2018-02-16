# KS_TAGS_API




- [Variables](#variables)

- [Exceptions](#exceptions)

- [MAINTAIN_FILTER_COLL Procedure](#maintain_filter_coll)



## Variables<a name="variables"></a>

Name | Code | Description
--- | --- | ---
else | <pre>    else<br />      apex_collection.create_collection(p_coll);</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>      end loop;</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>  end if;</pre> | 
end | <pre>end if;</pre> | 
end | <pre>end maintain_filter_coll;</pre> | 
end | <pre>end ks_tags_api;</pre> | 



## Exceptions<a name="exceptions"></a>

Name | Code | Description
--- | --- | ---
else | <pre>    else<br />      apex_collection.create_collection(p_coll);</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>      end loop;</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>    end if;</pre> | 
end | <pre>  end if;</pre> | 
end | <pre>end if;</pre> | 
end | <pre>end maintain_filter_coll;</pre> | 
end | <pre>end ks_tags_api;</pre> | 




 
## MAINTAIN_FILTER_COLL Procedure<a name="maintain_filter_coll"></a>


<p>
<hr>
<p>Maintain the collection elements when using search filters<br />  p_coll: collection_name<br />   p_sub: Optional sub level/area for the tags.<br />    p_id: ID being managed<br />p_status: YES/NO is the element checked (YES) or un-checked (NO)</p><hr>

</p>

### Syntax
```plsql
procedure maintain_filter_coll(
       p_coll   in varchar2
     , p_sub    in varchar2 := null
     , p_id     in varchar2
     , p_status in varchar2 := 'NO')
```

 





 
