#COMPILE EXE
#DIM ALL
' ccSQLite_starter.bas
'
#INCLUDE "win32api.inc"
'
$DB_name = "test.db"      ' constant for DB name
$Log     = "app.log"      ' log of this application
'
#INCLUDE "SQLite_lib.inc" ' SQLite library
'
%IndexedSearch = %FALSE   ' needed for libray but not this app
%IndexStart = 0           ' needed for libray but not this app
%IndexEnd   = 0           ' needed for libray but not this app
'
#INCLUDE ONCE "PB_FileHandlingRoutines.inc" ' file handling library
#INCLUDE ONCE "PB_ArrayFunctions.inc"       ' array handling library
'
FUNCTION PBMAIN () AS LONG
  LOCAL lngDB AS LONG   ' database handle
  LOCAL lngRC AS LONG   ' return code
  LOCAL lngRowCount AS LONG ' count of rows inserted
  LOCAL strError AS STRING  ' error message
  LOCAL strSQL AS STRING    ' sql to run
  '
  CON.COLOR(10,-1)
  '
  ' wipe the log file if it exists
  IF ISFILE($log) THEN KILL $log
  '
  funLog "App started " & TIME$
  '
  ' Open (or create) the database file
  IF ISTRUE funCreateDB(EXE.PATH$ & $DB_name, lngDB, strError) THEN
    IF ISTRUE funOpenDB(EXE.PATH$ & $DB_name, lngDB, strError) THEN
    ' open the DB for use
      ' and create any tables needed
      IF ISTRUE funCreateTables(lngDB) THEN
      ' all tables created
        IF ISTRUE funInsertData(lngDB) THEN
        ' insert any data needed into tables
        END IF
      ELSE
      ' failure to create all tables
        funLog "Error creating tables"
        funCloseDB(lngDB,strError)
        EXIT FUNCTION
      END IF
      '
    ELSE
    ' unable to open the DB
      funLog "Problem opening DB"
      funLog strError
      funCloseDB(lngDB,strError)
      EXIT FUNCTION
    END IF
    '
  ELSE
    ' db already exists?
    IF strError <> "File already exists" THEN
      funLog "Problem creating DB"
      funLog strError
      funCloseDB(lngDB,strError)
      EXIT FUNCTION
    ELSE
    ' db already exists so just open it
      IF ISFALSE funOpenDB(EXE.PATH$ & $DB_name, lngDB, strError) THEN
      ' unable to open the DB
        funLog "Problem opening DB"
        funLog strError
        funCloseDB(lngDB,strError)
        EXIT FUNCTION
      END IF
    END IF
  END IF
  '
  funLog "Reading data from DB"
  DIM a_strData() AS STRING
  '
  ' get the data in a table as an array
  strSQL = "SELECT ID,name as 'User',age FROM tblStaff"
  '
  IF ISTRUE funRecordsetAsArray(lngDB,strSQL,a_strData(),strError) THEN
  ' get the data as an array
    IF ISTRUE funSaveTheArrayToCsvFile(EXE.PATH$ & "Data.txt", _
                                a_strData(),%TRUE) THEN
      funLog "Table Data saved to file"
    ELSE
      funLog "Unable to save DB data to file"
    END IF
   '
  ELSE
    funLog "Problem Reading to Array " & $CRLF & strSQL
    funLog strError
  END IF
  '
  funLog "App completed at " & TIME$
  funCloseDB(lngDB,strError)
  '
  CON.STDOUT "Press any key to exit app"
  WAITKEY$
  '
END FUNCTION
'
FUNCTION funCreateTables(lngDB AS LONG) AS LONG
' create any tables needed in this app
  DIM a_strSQL(1 TO 2) AS STRING    ' sql strings
  LOCAL lngRC AS LONG               ' return code
  LOCAL lngS AS LONG                ' sql string counter
  LOCAL strError AS STRING          ' error message
  '
  funLog "Creating tables"
  '
  a_strSQL(1) = "CREATE TABLE IF NOT EXISTS " & _
                "tblStaff(id INTEGER PRIMARY KEY, " & _
                "name TEXT, age INTEGER);"
                '
  a_strSQL(2) = "CREATE TABLE IF NOT EXISTS " & _
                "tblAccounts(id INTEGER PRIMARY KEY, " & _
                "staff_id INTEGER, balance INTEGER);"
                '
  ' now create tables
  FOR lngS = 1 TO UBOUND(a_strSQL)
    IF ISFALSE funExecuteSQL(lngDB, _
                             a_strSQL(lngS), _
                             strError) THEN
    ' error running SQL
      funLog "Table cannot be created " & $CRLF & _
             a_strSQL(lngS) & $CRLF & strError
      '
      FUNCTION = %FALSE
      EXIT FUNCTION
      '
    END IF
    '
  NEXT lngS
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funInsertData(lngDB AS LONG) AS LONG
' insert data into the tables
  DIM a_strSQL(1 TO 3) AS STRING  ' sql statements
  LOCAL lngS AS LONG              ' sql count
  LOCAL strError AS STRING        ' error message
  '
  a_strSQL(1) = "Insert Into tblStaff(name,age) Values('Tom Smith',25);"
  a_strSQL(2) = "Insert Into tblStaff(name,age) Values('Jane Thompson',28);"
  a_strSQL(3) = "Insert Into tblStaff(name,age) Values('David Jones',35);"
  '
  FOR lngS = 1 TO UBOUND(a_strSQL)
    IF ISFALSE funExecuteSQL(lngDB, _
                             a_strSQL(lngS), _
                             strError) THEN
    ' error occurred
      funLog "Data cannot be created " & $CRLF & _
             a_strSQL(lngS) & $CRLF & strError
      '
      FUNCTION = %FALSE
      EXIT FUNCTION
    '
    END IF
  NEXT lngS
  '
  FUNCTION = %TRUE
  '
END FUNCTION
