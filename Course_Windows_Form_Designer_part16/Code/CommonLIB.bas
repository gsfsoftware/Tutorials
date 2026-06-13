#COMPILE DLL
#DIM ALL

#INCLUDE ONCE "Win32API.inc"

GLOBAL ghInstance AS DWORD
'-------------------------------------------------------------------------------
' Main DLL entry point called by Windows...
'
FUNCTION LIBMAIN (BYVAL hInstance   AS LONG, _
                  BYVAL fwdReason   AS LONG, _
                  BYVAL lpvReserved AS LONG) AS LONG

    SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH
        'Indicates that the DLL is being loaded by another process (a DLL
        'or EXE is loading the DLL).  DLLs can use this opportunity to
        'initialize any instance or global data, such as arrays.

        ghInstance = hInstance

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_ATTACH
        'Indicates that the DLL is being loaded by a new thread in the
        'calling application.  DLLs can use this opportunity to
        'initialize any thread local storage (TLS).

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_DETACH
        'Indicates that the thread is exiting cleanly.  If the DLL has
        'allocated any thread local storage, it should be released.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    END SELECT

END FUNCTION
'
FUNCTION funSaveListView ALIAS "funSaveListView" _
                         (hDlg AS DWORD, _
                         lnglistView AS LONG, _
                         strListViewGrid AS STRING, _
                         lngColumns AS LONG) EXPORT AS LONG
' save the listview to file
  LOCAL lngRow AS LONG            ' row counter
  DIM a_strStaffData() AS STRING  ' array for staff details
  LOCAL lngRowCount AS LONG       ' number of rows in listview
  LOCAL lngColumn AS LONG         ' column counter
  LOCAL strText AS STRING
  '
  LISTVIEW GET COUNT hDlg, lnglistView TO lngRowCount
  ' size the array
  REDIM a_strStaffData(lngRowCount,lngColumns)
  '
  ' first get the headers
  FOR lngColumn = 1 TO lngColumns
    LISTVIEW GET HEADER hDlg,lnglistView, lngColumn TO _
                        a_strStaffData(0,lngColumn)
  NEXT lngColumn
  '
   FOR lngRow = 1 TO lngRowCount
    FOR lngColumn = 1 TO lngColumns
    ' get the data out of listview
      LISTVIEW GET TEXT hDlg, lnglistView, _
                        lngRow, lngColumn TO _
                        strText
      a_strStaffData(lngRow,lngColumn) = strText
      '
    NEXT lngColumn
  NEXT lngRow
  '
  ' save to disk
  '
  FUNCTION = funSaveTheArrayToCsvFile(strListViewGrid, _
                                      a_strStaffData(), _
                                      %FALSE)
  '
END FUNCTION
'
FUNCTION funSaveTheArrayToCsvFile ALIAS "funSaveTheArrayToCsvFile" _
                               (strFilename AS STRING, _
                               BYREF a_strWork() AS STRING, _
                               OPTIONAL lngStartAtZero AS LONG) _
                               EXPORT AS LONG
' save an array 1D or 2D to a specified CSV file
  LOCAL lngFile AS LONG
  LOCAL lngDimensions AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngColumnStart AS LONG
  LOCAL strText AS STRING
  '
  IF ISMISSING(lngStartAtZero) THEN
    lngColumnStart = 1
  ELSE
    IF ISTRUE lngStartAtZero THEN
      lngColumnStart = 0
    ELSE
      lngColumnStart = 1
    END IF
  END IF
  '
  lngDimensions = ARRAYATTR(a_strWork(),3)
  '
  IF lngDimensions <1 OR lngDimensions > 2 THEN
  ' only 1 & 2 dimensions are supported
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR OUTPUT AS #lngFile
    '
    IF lngDimensions = 1 THEN
      FOR lngR = lngColumnStart TO UBOUND(a_strWork)
      ' for each row wrap in "
        PRINT #lngFile,$DQ & a_strWork(lngR) & $DQ
      NEXT lngR
    ELSE
    ' handle 2 dimensional arrays
      FOR lngR = LBOUND(a_strWork) TO UBOUND(a_strWork)
        ' build up text to be output
        strText = $DQ
        FOR lngC = lngColumnStart TO UBOUND(a_strWork,2)
        ' for each column add ","
          strText = strText & a_strWork(lngR,lngC) & $QCQ
        NEXT lngC
        ' print to file with " at end of string
        PRINT #lngFile,RTRIM$(strText,$QCQ) & $DQ
      NEXT lngR
    END IF
    '
     FUNCTION = %TRUE
    '
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funReadTheCSVFileIntoAnArray ALIAS "funReadTheCSVFileIntoAnArray" _
                               (strFilename AS STRING, _
                               BYREF a_strWork() AS STRING) _
                               EXPORT AS LONG
' read a CSV file into a 2 dimensional array
  LOCAL lngFile AS LONG      ' file handle
  LOCAL lngRecords AS LONG   ' number of records
  LOCAL lngColumns AS LONG   ' number of columns
  LOCAL strData AS STRING    ' data in the cell
  LOCAL lngR AS LONG         ' row counter
  LOCAL lngC AS LONG         ' column counter
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    DECR lngRecords ' reduce count by 1
    ' read the header line
    LINE INPUT #lngFile,strData
    '
    lngColumns = PARSECOUNT(strData,"")
    REDIM a_strWork(lngRecords ,lngColumns) AS STRING
    '
    FOR lngR = 0 TO lngRecords
      FOR lngC = 1 TO lngColumns
        a_strWork(lngR,lngC) = PARSE$(strData,"",lngC)
      NEXT lngC
      IF NOT EOF(#lngFile) THEN
        LINE INPUT #lngFile,strData
      END IF
    NEXT lngR
    '
    FUNCTION = %TRUE
  CATCH
    ' error occurred
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
