
CREATE OR REPLACE PACKAGE BODY       "AS_READ_XLSX_CLOB" 
is
--
  function read( p_xlsx blob, p_sheets varchar2 := null, p_cell varchar2 := null )
  return tp_all_cells pipelined
  is
    t_date1904 boolean;
    type tp_date is table of boolean index by pls_integer;
    t_xf_date tp_date;
    t_numfmt_date tp_date;
    type tp_strings is table of varchar2(32767) index by pls_integer;
    t_strings tp_strings;
    t_sheet_ids tp_strings;
    t_sheet_names tp_strings;
    t_r varchar2(32767);
    t_s varchar2(32767);
    t_val varchar2(32767);
    t_t varchar2(400);
    t_nr number;
    t_c pls_integer;
    t_x pls_integer;
    t_xx pls_integer;
    t_ns varchar2(200) := 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"';
    t_nd dbms_xmldom.domnode;
    t_nd2 dbms_xmldom.domnode;
    t_nl dbms_xmldom.domnodelist;
    t_nl2 dbms_xmldom.domnodelist;
    t_nl3 dbms_xmldom.domnodelist;
    t_one_cell tp_one_cell;
--
    function blob2node( p_blob blob )
    return dbms_xmldom.domnode
    is
    begin
      if p_blob is null or dbms_lob.getlength( p_blob ) = 0
      then
        return null;
      end if;
      return dbms_xmldom.makenode( dbms_xmldom.getdocumentelement( dbms_xmldom.newdomdocument( xmltype( p_blob, nls_charset_id( 'AL32UTF8' ) ) ) ) );
    exception
      when others
      then
        declare
          t_nd dbms_xmldom.domnode;
          t_clob         clob;
          t_dest_offset  integer;
          t_src_offset   integer;
          t_lang_context number := dbms_lob.default_lang_ctx;
          t_warning      integer;
        begin
          dbms_lob.createtemporary( t_clob, true );
          t_dest_offset := 1;
          t_src_offset  := 1;
          dbms_lob.converttoclob( t_clob
                                , p_blob
                                , dbms_lob.lobmaxsize
                                , t_dest_offset
                                , t_src_offset
                                , nls_charset_id('AL32UTF8')
                                , t_lang_context
                                , t_warning
                                );
          t_nd := dbms_xmldom.makenode( dbms_xmldom.getdocumentelement( dbms_xmldom.newdomdocument( t_clob ) ) );
          dbms_lob.freetemporary( t_clob );
          return t_nd;
      end;
    end;
--
    function blob2num( p_blob blob, p_len integer, p_pos integer )
    return number
    is
    begin
      return utl_raw.cast_to_binary_integer( dbms_lob.substr( p_blob, p_len, p_pos ), utl_raw.little_endian );
    end;
--
    function little_endian( p_big number, p_bytes pls_integer := 4 )
    return raw
    is
    begin
      return utl_raw.substr( utl_raw.cast_from_binary_integer( p_big, utl_raw.little_endian ), 1, p_bytes );
    end;
--
    function col_alfan( p_col varchar2 )
    return pls_integer
    is
    begin
      return ascii( substr( p_col, -1 ) ) - 64
           + nvl( ( ascii( substr( p_col, -2, 1 ) ) - 64 ) * 26, 0 )
           + nvl( ( ascii( substr( p_col, -3, 1 ) ) - 64 ) * 676, 0 );
    end;
--
    function get_file
      ( p_zipped_blob blob
      , p_file_name varchar2
      )
    return blob
    is
      t_tmp blob;
      t_ind integer;
      t_hd_ind integer;
      t_fl_ind integer;
      t_encoding varchar2(10);
      t_len integer;
    begin
      t_ind := dbms_lob.getlength( p_zipped_blob ) - 21;
      loop
        exit when t_ind < 1 or dbms_lob.substr( p_zipped_blob, 4, t_ind ) = hextoraw( '504B0506' ); -- End of central directory signature
        t_ind := t_ind - 1;
      end loop;
--
      if t_ind <= 0
      then
        return null;
      end if;
--
      t_hd_ind := blob2num( p_zipped_blob, 4, t_ind + 16 ) + 1;
      for i in 1 .. blob2num( p_zipped_blob, 2, t_ind + 8 )
      loop
        if utl_raw.bit_and( dbms_lob.substr( p_zipped_blob, 1, t_hd_ind + 9 ), hextoraw( '08' ) ) = hextoraw( '08' )
        then
          t_encoding := 'AL32UTF8'; -- utf8
        else
          t_encoding := 'US8PC437'; -- IBM codepage 437
        end if;
        if p_file_name = utl_i18n.raw_to_char
                           ( dbms_lob.substr( p_zipped_blob
                                            , blob2num( p_zipped_blob, 2, t_hd_ind + 28 )
                                            , t_hd_ind + 46
                                            )
                           , t_encoding
                           )
        then
          t_len := blob2num( p_zipped_blob, 4, t_hd_ind + 24 ); -- uncompressed length
          if t_len = 0
          then
            if substr( p_file_name, -1 ) in ( '/', '\' )
            then  -- directory/folder
              return null;
            else -- empty file
              return empty_blob();
            end if;
          end if;
--
          if dbms_lob.substr( p_zipped_blob, 2, t_hd_ind + 10 ) = hextoraw( '0800' ) -- deflate
          then
            t_fl_ind := blob2num( p_zipped_blob, 4, t_hd_ind + 42 );
            t_tmp := hextoraw( '1F8B0800000000000003' ); -- gzip header
            dbms_lob.copy( t_tmp
                         , p_zipped_blob
                         ,  blob2num( p_zipped_blob, 4, t_hd_ind + 20 )
                         , 11
                         , t_fl_ind + 31
                         + blob2num( p_zipped_blob, 2, t_fl_ind + 27 ) -- File name length
                         + blob2num( p_zipped_blob, 2, t_fl_ind + 29 ) -- Extra field length
                         );
            dbms_lob.append( t_tmp, utl_raw.concat( dbms_lob.substr( p_zipped_blob, 4, t_hd_ind + 16 ) -- CRC32
                                                  , little_endian( t_len ) -- uncompressed length
                                                  )
                           );
            return utl_compress.lz_uncompress( t_tmp );
          end if;
--
          if dbms_lob.substr( p_zipped_blob, 2, t_hd_ind + 10 ) = hextoraw( '0000' ) -- The file is stored (no compression)
          then
            t_fl_ind := blob2num( p_zipped_blob, 4, t_hd_ind + 42 );
            dbms_lob.createtemporary( t_tmp, true );
            dbms_lob.copy( t_tmp
                         , p_zipped_blob
                         , t_len
                         , 1
                         , t_fl_ind + 31
                         + blob2num( p_zipped_blob, 2, t_fl_ind + 27 ) -- File name length
                         + blob2num( p_zipped_blob, 2, t_fl_ind + 29 ) -- Extra field length
                         );
            return t_tmp;
          end if;
        end if;
        t_hd_ind := t_hd_ind + 46
                  + blob2num( p_zipped_blob, 2, t_hd_ind + 28 )  -- File name length
                  + blob2num( p_zipped_blob, 2, t_hd_ind + 30 )  -- Extra field length
                  + blob2num( p_zipped_blob, 2, t_hd_ind + 32 ); -- File comment length
      end loop;
--
      return null;
    end;
--
  begin
    t_one_cell.cell_type := 'S';
    t_one_cell.sheet_name := 'This doesn''t look like an Excel (xlsx) file to me!';
    t_one_cell.string_val := t_one_cell.sheet_name;
    if dbms_lob.substr( p_xlsx, 4, 1 ) != hextoraw( '504B0304' )
    then
      pipe row( t_one_cell );
      return;
    end if;
    t_nd := blob2node( get_file( p_xlsx, 'xl/workbook.xml' ) );
    if dbms_xmldom.isnull( t_nd )
    then
      pipe row( t_one_cell );
      return;
    end if;
    t_date1904 := lower( dbms_xslprocessor.valueof( t_nd, '/workbook/workbookPr/@date1904', t_ns ) ) in ( 'true', '1' );
    t_nl := dbms_xslprocessor.selectnodes( t_nd, '/workbook/sheets/sheet', t_ns );
    for i in 0 .. dbms_xmldom.getlength( t_nl ) - 1
    loop
      t_sheet_ids( i + 1 ) := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '@r:id', 'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"' );
      t_sheet_names( i + 1 ) := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '@name' );
    end loop;
    t_nd := blob2node( get_file( p_xlsx, 'xl/styles.xml' ) );
    t_nl := dbms_xslprocessor.selectnodes( t_nd, '/styleSheet/numFmts/numFmt', t_ns );
    for i in 0 .. dbms_xmldom.getlength( t_nl ) - 1
    loop
      t_val := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '@formatCode' );
      if (  instr( t_val, 'dd' ) > 0
         or instr( t_val, 'mm' ) > 0
         or instr( t_val, 'yy' ) > 0
         )
      then
        t_numfmt_date( dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '@numFmtId' ) ) := true;
      end if;
    end loop;
    t_numfmt_date( 14 ) := true;
    t_numfmt_date( 15 ) := true;
    t_numfmt_date( 16 ) := true;
    t_numfmt_date( 17 ) := true;
    t_numfmt_date( 22 ) := true;
    t_nl := dbms_xslprocessor.selectnodes( t_nd, '/styleSheet/cellXfs/xf/@numFmtId', t_ns );
    for i in 0 .. dbms_xmldom.getlength( t_nl ) - 1
    loop
      t_xf_date( i ) := t_numfmt_date.exists( dbms_xmldom.getnodevalue( dbms_xmldom.item( t_nl, i ) ) );
    end loop;
    t_nd := blob2node( get_file( p_xlsx, 'xl/sharedStrings.xml' ) );
    if not dbms_xmldom.isnull( t_nd )
    then
      t_x := 0;
      t_xx := 5000;
      loop
        t_nl := dbms_xslprocessor.selectnodes( t_nd, '/sst/si[position()>="' || to_char( t_x * t_xx + 1 ) || '" and position()<=" ' || to_char( ( t_x + 1 ) * t_xx ) || '"]', t_ns );
        exit when dbms_xmldom.getlength( t_nl ) = 0;
        t_x := t_x + 1;
        for i in 0 .. dbms_xmldom.getlength( t_nl ) - 1
        loop
          t_c := t_strings.count;
         ---------kc:  use proc instead   t_strings( t_c ) := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '.' );
          dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '.', t_strings( t_c ) );
          if t_strings( t_c ) is null
          then
          ------kc:   use proc instead  t_strings( t_c ) := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '*/text()' );   --******************************* this is the line that fails
            dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl, i ), '*/text()',  t_strings( t_c ) );
            if t_strings( t_c ) is null
            then
              t_nl2 := dbms_xslprocessor.selectnodes( dbms_xmldom.item( t_nl, i ), 'r/t/text()' );
              for j in 0 .. dbms_xmldom.getlength( t_nl2 ) - 1
              loop
                t_strings( t_c ) := t_strings( t_c ) || dbms_xmldom.getnodevalue( dbms_xmldom.item( t_nl2, j ) );
              end loop;
            end if;
          end if;
        end loop;
      end loop;
    end if;
    t_nd2 := blob2node( get_file( p_xlsx, 'xl/_rels/workbook.xml.rels' ) );
    for i in 1 .. t_sheet_ids.count
    loop
      if ( p_sheets is null
         or instr( ':' || p_sheets || ':', ':' || to_char( i ) || ':' ) > 0
         or instr( ':' || p_sheets || ':', ':' || t_sheet_names( i ) || ':' ) > 0
         )
      then
        t_val := dbms_xslprocessor.valueof( t_nd2, '/Relationships/Relationship[@Id="' || t_sheet_ids( i ) || '"]/@Target', 'xmlns="http://schemas.openxmlformats.org/package/2006/relationships"' );
        t_one_cell.sheet_nr := i;
        t_one_cell.sheet_name := t_sheet_names( i );
        t_nd := blob2node( get_file( p_xlsx, 'xl/' || t_val ) );
        t_nl3 := dbms_xslprocessor.selectnodes( t_nd, '/worksheet/sheetData/row' );
        for r in 0 .. dbms_xmldom.getlength( t_nl3 ) - 1
        loop
          t_nl2 := dbms_xslprocessor.selectnodes( dbms_xmldom.item( t_nl3, r ), 'c' );
          for j in 0 .. dbms_xmldom.getlength( t_nl2 ) - 1
          loop
            t_one_cell.date_val := null;
            t_one_cell.number_val := null;
            t_one_cell.string_val := null;
            t_r := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl2, j ), '@r', t_ns );
            t_val := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl2, j ), 'v' );
            -- see Changelog 2013-02-19 formula column
            t_one_cell.formula := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl2, j ), 'f' );
            -- see Changelog 2013-02-18 type='str'
            t_t := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl2, j ), '@t' );
            if t_t in ( 'str', 'inlineStr', 'e' )
            then
              t_one_cell.cell_type := 'S';
              t_one_cell.string_val := t_val;
            elsif t_t = 's'
            then
              t_one_cell.cell_type := 'S';
              if t_val is not null
              then
                t_one_cell.string_val := t_strings( to_number( t_val ) );  ----------------*************
              end if;
            else
              t_s := dbms_xslprocessor.valueof( dbms_xmldom.item( t_nl2, j ), '@s' );
              t_nr := to_number( t_val
                               , case when instr( t_val, 'E' ) = 0
                                   then translate( t_val, '.012345678,-+', 'D999999999' )
                                   else translate( substr( t_val, 1, instr( t_val, 'E' ) - 1 ), '.012345678,-+', 'D999999999' ) || 'EEEE'
                                 end
                               , 'NLS_NUMERIC_CHARACTERS=.,'
                               );
              if t_s is not null and t_xf_date( to_number( t_s ) )
              then
                t_one_cell.cell_type := 'D';
                if t_date1904
                then
                  t_one_cell.date_val := to_date('01-01-1904','DD-MM-YYYY') + to_number( t_nr );
                else
                  t_one_cell.date_val := to_date('01-03-1900','DD-MM-YYYY') + ( to_number( t_nr ) - 61 );
                end if;
              else
                t_one_cell.cell_type := 'N';
                t_nr := round( t_nr, 14 - substr( to_char( t_nr, 'TME' ), -3 ) );
                t_one_cell.number_val := t_nr;
              end if;
            end if;
            t_one_cell.row_nr := ltrim( t_r, rtrim( t_r, '0123456789' ) );
            t_one_cell.col_nr := col_alfan( rtrim( t_r, '0123456789' ) );
            t_one_cell.cell := t_r;
            if p_cell is null or t_r = upper( p_cell )
            then
              pipe row( t_one_cell );
            end if;
          end loop;
        end loop;
      end if;
    end loop;
    return;
  end;
--
  function file2blob
    ( p_dir varchar2
    , p_file_name varchar2
    )
  return blob
  is
    file_lob bfile;
    file_blob blob;
  begin
    file_lob := bfilename( p_dir, p_file_name );
    dbms_lob.open( file_lob, dbms_lob.file_readonly );
    dbms_lob.createtemporary( file_blob, true );
    dbms_lob.loadfromfile( file_blob, file_lob, dbms_lob.lobmaxsize );
    dbms_lob.close( file_lob );
    return file_blob;
  exception
    when others then
      if dbms_lob.isopen( file_lob ) = 1
      then
        dbms_lob.close( file_lob );
      end if;
      if dbms_lob.istemporary( file_blob ) = 1
      then
        dbms_lob.freetemporary( file_blob );
      end if;
      raise;
  end;
--
END as_read_xlsx_clob;
/
