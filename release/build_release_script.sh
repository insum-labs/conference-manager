#!/bin/bash

#
#*****************************************************************************
# This script received a .sql file as input and will create an output file
# that can be processed by SQL Workshop on apex.oracle.com
# This means that single commands can be executed as they are (for example 
# alter, create table, update, inserts, etc..).
# When a script is found with the form @../file, ie:
# @../views/ks_users_v.sql
# It will be "expanded" into the output file (defined by OUT_FILE)
#
#*****************************************************************************


OUT_FILE="master_release.sql"


Log() {
  echo "`date`: $1"
}


#*****************************************************************************
# Expand Script Lines or output regular lines
#******************************************************************************
fn_PROCESS_LINE ()
{

# Log "Is $1 a script?"

if [ -f "${1:1}" ]
then
  Log "Expanding file: ${1:1}"
  echo "-- $1" >> $OUT_FILE
  cat ${1:1} >> $OUT_FILE
  echo -n >> $OUT_FILE
else
  echo "$line" >> $OUT_FILE
fi

}




Log "Procesing $1 into $OUT_FILE"

echo "-- =============================================================================" > $OUT_FILE
echo "-- ==========================  Full $1 file" >> $OUT_FILE
echo "-- =============================================================================" >> $OUT_FILE
echo -n >> $OUT_FILE

while IFS='' read -r line || [[ -n "$line" ]]; do
  
  fn_PROCESS_LINE $line
    
done < "$1"