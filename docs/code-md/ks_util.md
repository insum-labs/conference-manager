# KS_UTIL






- [BLOB2CLOB Function](#blob2clob)












 
## BLOB2CLOB Function<a name="blob2clob"></a>


<p>
<p>Converts blob to clob</p><p>Notes:</p><ul>
<li>Copied from OOS Utils <a href="https://github.com/OraOpenSource/oos-utils/blob/master/source/packages/oos_util_lob.pkb">https://github.com/OraOpenSource/oos-utils/blob/master/source/packages/oos_util_lob.pkb</a></li>
</ul>

</p>

### Syntax
```plsql
function blob2clob(
  p_blob in blob,
  p_blob_csid in integer default dbms_lob.default_csid)
  return clob
```

 





 
