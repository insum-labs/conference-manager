CREATE OR REPLACE PACKAGE "AS_READ_XLSX_CLOB"
is
/**********************************************
**
** Author: Anton Scheffer
** Date: 19-01-2013
** Website: http://technology.amis.nl/blog
**
** Changelog:
** 18-02-2013 - Ralph Bieber
                Handle cell type "str" to prevent ORA-06502
                if cell content is a string calculated by formula,
                then cell type is "str" instead of "s" and value is inside <v> tag
** 19-02-2013 - Ralph Bieber
                Add column formula in tp_one_cell record, to show, if value is calculated by formula
** 20-02-2013 - Anton Scheffer
                Handle cell types 'inlineStr' and 'e' to prevent ORA-06502
** 19-03-2013 - Anton Scheffer
                Support for formatted and empty strings
                Handle columns per row to prevent ORA-31186: Document contains too many nodes
** 12-06-2013 - Anton Scheffer
                Handle sharedStrings.xml on older Oracle database versions
** 18-09-2013 - Anton Scheffer
                Fix for LPX-00200 could not convert from encoding UTF-8 to ...
                (Note, this is an error I can't reproduce myself, maybe depending on database version and characterset)
                Thank you Stanislav Safonov for this solution
                Handle numbers with scientific notation
** 20-01-2014 - Anton Scheffer
                Fix for a large number (60000+) of strings
** 16-05-2014 - Anton Scheffer
                round to 15 digits
** 10-08-2015 - Karen cannell
                Mod to allow CLOBs for cells where content > 4000 char. Use

******************************************************************************
******************************************************************************
Copyright (C) 2013 by Anton Scheffer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

******************************************************************************
*************************************************************************** */
/*
**
** Some examples
**
--
-- every sheet and every cell
    select *
    from table( as_read_xlsx.read( as_read_xlsx.file2blob( 'DOC', 'Book1.xlsx' ) ) )
--
-- cell A3 from the first and the second sheet
    select *
    from table( as_read_xlsx.read( as_read_xlsx.file2blob( 'DOC', 'Book1.xlsx' ), '1:2', 'A3' ) )
--
-- every cell from the sheet with the name "Sheet3"
    select *
    from table( as_read_xlsx.read( as_read_xlsx.file2blob( 'DOC', 'Book1.xlsx' ), 'Sheet3' ) )
--
*/
  type tp_one_cell is record
    ( sheet_nr number(2)
    , sheet_name varchar(4000)
    , row_nr number(10)
    , col_nr number(10)
    , cell varchar2(100)
    , cell_type VARCHAR2(1)
    , string_val clob        --KC: was --varchar2(4000)
    , number_val number
    , date_val date
    , formula varchar2(4000)
  );
  type tp_all_cells is table of tp_one_cell;
--
  function read( p_xlsx blob, p_sheets varchar2 := null, p_cell varchar2 := null )
  return tp_all_cells pipelined;
--
  function file2blob
    ( p_dir varchar2
    , p_file_name varchar2
    )
  return blob;
--
end as_read_xlsx_clob;
/
