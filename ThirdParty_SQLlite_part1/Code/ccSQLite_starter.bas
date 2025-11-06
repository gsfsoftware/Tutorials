#COMPILE EXE
#DIM ALL
' ccSQLite_starter.bas
'
#INCLUDE "win32api.inc"
'
DECLARE FUNCTION sqlite3_open LIB "sqlite3.dll" ALIAS "sqlite3_open" _
                (BYVAL filename AS STRING, _
                 BYREF ppDb AS LONG) AS LONG
                 '
DECLARE FUNCTION sqlite3_close LIB "sqlite3.dll" ALIAS "sqlite3_close" _
                (BYVAL pDb AS LONG) AS LONG
                '
DECLARE FUNCTION sqlite3_exec LIB "sqlite3.dll" ALIAS "sqlite3_exec" _
                (BYVAL pDb AS LONG, _
                 BYVAL sql AS STRING, _
                 BYVAL callback AS LONG, _
                 BYVAL pArg AS LONG, _
                 BYREF pzErrMsg AS LONG) AS LONG
                 '
DECLARE FUNCTION sqlite3_prepare_v2 LIB "sqlite3.dll"  _
         ALIAS "sqlite3_prepare_v2" _
        (BYVAL pDb AS LONG, _
         BYVAL zSql AS STRING, _
         BYVAL nByte AS LONG, _
         BYREF ppStmt AS LONG, _
         BYREF pzTail AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_step LIB "sqlite3.dll" _
         ALIAS "sqlite3_step" _
         (BYVAL pStmt AS LONG) AS LONG
          '
DECLARE FUNCTION sqlite3_column_text LIB "sqlite3.dll" _
         ALIAS "sqlite3_column_text" _
         (BYVAL pStmt AS LONG, BYVAL iCol AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_column_int LIB "sqlite3.dll" _
         ALIAS "sqlite3_column_int" _
         (BYVAL pStmt AS LONG, BYVAL iCol AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_finalize LIB "sqlite3.dll" _
         ALIAS "sqlite3_finalize" _
         (BYVAL pStmt AS LONG) AS LONG

%SQLite_OK    = 0         ' sql command successful
%SQLite_ROW   = 100       ' row returned
%SQLite_DONE  = 101       ' no more rows to read
'
FUNCTION PBMAIN () AS LONG
  LOCAL lngDB AS LONG   ' database handle
  LOCAL lngRC AS LONG   ' return code
  LOCAL lngRowCount AS LONG ' count of rows inserted
  '
  ' Open (or create) the database file
  lngRC = sqlite3_open(EXE.PATH$ & "test.db", lngDB)
  '
  CON.COLOR(10,-1)
  '
  IF lngRC <> %SQLite_OK THEN
    CON.STDOUT "Unable to open/create database"
  ELSE
    CON.STDOUT "Database opened"
  END IF
  '
  IF ISTRUE funCreateTable(lngDB) THEN
    CON.STDOUT "Table created"
    '
    IF ISTRUE funInsertRows(lngDB, lngRowCount) THEN
      CON.STDOUT "All rows inserted"
    ELSE
      CON.STDOUT FORMAT$(lngRowCount) & " inserted"
    END IF
    '
    ' now read back the rows inserted
    lngRowCount = 0
    IF ISTRUE funReadData(lngDB, lngRowCount) THEN
      CON.STDOUT FORMAT$(lngRowCount) & " data rows read"
    END IF
    '
  ELSE
    CON.STDOUT "Unable to create Table"
  END IF


  ' now close the DB
  lngRC = sqlite3_close(lngDB)
  IF lngRC <> %SQLite_OK THEN
    CON.STDOUT "Problem closing DB"
  ELSE
    CON.STDOUT "DB closed"
  END IF
  '
  CON.STDOUT "Press any key to exit app"
  WAITKEY$
  '
END FUNCTION
'
FUNCTION funReadData(lngDB AS LONG, lngRowCount AS LONG ) AS LONG
' read the data from the database table
  LOCAL strSQL AS STRING  ' sql statement
  LOCAL lngRC AS LONG     ' return code
  LOCAL lngErrMsg AS LONG ' error message
  LOCAL lngStatementID AS LONG ' statement ID
  LOCAL lngTail AS LONG   ' unused here
  '
  LOCAL lngID AS LONG         ' primary key
  LOCAL strName AS STRING     ' name
  LOCAL ptrName AS ASCIIZ PTR ' pointer for name
  LOCAL lngAge AS LONG        ' age
  '
  strSQL = "SELECT id, name, age FROM tblStaff ORDER BY id;"
  lngRC = sqlite3_prepare_v2(lngDB,strSQL , -1, lngStatementID, lngTail)
  '
  IF lngRC <> %SQLite_OK THEN
    CON.STDOUT "Unable to prepare select statement"
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  '
  PRINT "ID","Name","Age"
  '
  DO
    lngRC = sqlite3_step(lngStatementID)
    '
    SELECT CASE lngRC
      CASE %SQLite_ROW
      ' pick up data
        ' first the primary key
        lngID = sqlite3_column_int(lngStatementID, 0)
        ' now the name
        ptrName = (sqlite3_column_text(lngStatementID, 1))
        strName = @ptrName
        '
        ' now the age
        lngAge = sqlite3_column_int(lngStatementID, 2)
        '
        PRINT lngID,strName,lngAge
        INCR lngRowCount
      '
      CASE %SQLite_DONE
      ' no more data
        FUNCTION = %TRUE
        EXIT DO
        '
      CASE ELSE
      ' error?
        PRINT "sqlite3_step error lngRC="; lngRC
        FUNCTION = %FALSE
        EXIT DO
    END SELECT
    '
  LOOP
  '
  ' clean up
  lngRC = sqlite3_finalize(lngStatementID)
  IF lngRC <> %SQLite_OK THEN
    PRINT "Warning: sqlite3_finalize lngRC="; lngRC
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funInsertRows(lngDB AS LONG, lngRowCount AS LONG) AS LONG
' insert some rows to table
  DIM a_strSQL(1 TO 3) AS STRING  ' sql statements
  LOCAL lngRC AS LONG             ' return code
  LOCAL lngErrMsg AS LONG         ' error message returned
  LOCAL lngS AS LONG              ' statement counter
  LOCAL ptrErrMsg AS ASCIIZ PTR   ' pointer for the error message
  '
  a_strSQL(1) = "Insert Into tblStaff(name,age) Values('Tom Smith',25);"
  a_strSQL(2) = "Insert Into tblStaff(name,age) Values('Jane Thompson',28);"
  a_strSQL(3) = "Insert Into tblStaff(name,age) Values('David Jones',35);"
  '
  FOR lngS = 1 TO UBOUND(a_strSQL)
  ' step through each sql statement
    lngRC = sqlite3_exec(lngDB,a_strSQL(lngS),0,0,lngErrMsg)
    '
    IF lngRC = %SQLite_OK THEN
      INCR lngRowCount
    ELSE
      CON.STDOUT "SQL statement " & FORMAT$(lngS) & " cannot be run"
      ' reveal the error msg
      ptrErrMsg = lngErrMsg
      CON.STDOUT @ptrErrMsg
    END IF
    '
  NEXT lngS
  '
  ' return to calling routine
  IF lngRowCount = UBOUND(a_strSQL) THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funCreateTable(lngDB AS LONG) AS LONG
' create a table in the database
  LOCAL strSQL AS STRING  ' sql statement
  LOCAL lngRC AS LONG     ' return code
  LOCAL lngErrMsg AS LONG ' error message
  '
  strSQL = "CREATE TABLE IF NOT EXISTS " & _
           "tblStaff(id INTEGER PRIMARY KEY, name TEXT, age INTEGER);"
            '
  lngRC = sqlite3_exec(lngDB,strSQL,0,0,lngErrMsg)
  '
  IF lngRC <> %SQLite_OK THEN
    CON.STDOUT "Unable to create table"
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
