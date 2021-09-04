' PB_GenericCDEF_Functions.inc

#INCLUDE ONCE "..\Libraries\PB_Common_Strings.inc"
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"


%SUCCESS                        =   0           'ZERO ERRORS
%SUCCESS_WITH_INFO              =   1   'SUCCESS; GET INFO FROM SQL_Error FUNCTION
%SQL_STILL_EXECUTING            =   2
%SQL_ERROR                      =  -1   'SQL REPORTED AN ERROR
%SQL_INVALID_HANDLE             =  -2   'HANDLE PASSED TO API FUNCTION IS INVALID
%SQL_IGNORE                     =  -6
%SQL_NEED_DATA                  =  99
%SQL_NO_DATA                    = 100

%MY_SQLT_AUTHCODE               = 0     ' dummy codes
%OPT_TEXT_MAXLENGTH             = 0
'
' define the globals to specify which app,form,grid and tab we are working on
GLOBAL g_lngCBOAppSelected  AS LONG   ' app selected
GLOBAL g_lngCBOFormSelected AS LONG   ' form selected
GLOBAL g_lngCBOGridSelected AS LONG   ' grid selected
GLOBAL g_lngCBOTabSelected  AS LONG   ' tab selected
'
FUNCTION SQL_Authorize(lngCode AS LONG) AS LONG
  FUNCTION = %SUCCESS
END FUNCTION
'
FUNCTION SQL_SetOptionSInt(lngCode AS LONG, lngData AS LONG) AS LONG
  FUNCTION = %SUCCESS
END FUNCTION
'
FUNCTION funGetRefValue(strFileTable AS STRING, _
                        strValue AS STRING) AS STRING
' look up a reference value
  DIM a_strData() AS STRING
  LOCAL lngR AS LONG
  '
  REPLACE "'" WITH "" IN strValue
  '
  ' check file exists
  IF ISTRUE ISFILE(EXE.PATH$ & "CDEF_Config\" & strFileTable) THEN
    ' load the file to an array
    IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & "CDEF_Config\" & strFileTable, _
                                        BYREF a_strData()) THEN
      FOR lngR = 1 TO UBOUND(a_strData)
      ' check every record for a match
        IF strValue = a_strData(lngR) THEN
        ' return the number if a match is found
          FUNCTION = FORMAT$(lngR)
          EXIT FUNCTION
        END IF
      NEXT lngR
      '
      FUNCTION = ""
      '
    ELSE
      FUNCTION = ""
    END IF
    '
  ELSE
    FUNCTION = ""
  END IF
  '
END FUNCTION
'
FUNCTION funRunSQL(strSQL AS STRING, _
                   strError AS STRING, _
                   lngDB AS LONG) AS LONG
' update something
'
' "EXEC dbo.CDEF_sprUpdateTabRefs @idxCDEFTabRef='1001',@TabPos='1',@GridPos='1',@ColumnName='ID',
'@ResultName='idxID',@Columnwidth='100',@ColumnHide='0',@ColumnColour='Black',@ColumnPrimary='0',
'@ColumnLock='1',@JustifyText='Centre',@ColumnCheckbox='0',@ColumnCheckBoxCounterLimit='0',
'@ColumnUserButtonID='0',@ColumnDropDown='0',@ColumnDropdownSPR='',@ColumnDateTime='0',
'@ColumnSupressTime='0'"
  '
  LOCAL strSPR AS STRING
  LOCAL strParameters AS STRING
  LOCAL strFileName AS STRING
  LOCAL a_strData() AS STRING
  LOCAL strHeaders AS STRING
  LOCAL lngR AS LONG
  LOCAL lngP AS LONG
  LOCAL lngColumn AS LONG
  LOCAL strField AS STRING
  LOCAL strValue AS STRING
  LOCAL lngFound AS LONG
  LOCAL a_strParameters() AS STRING
  '
  ' get the name of the stored procedure & parameters
  strSPR = PARSE$(strSQL,"dbo.",2)
  ' get the parameters - if any
  lngColumn = INSTR(strSQL,"@")
  IF lngColumn > 0 THEN
    strParameters = MID$(strSQL,lngColumn)
  ELSE
    strParameters = ""
  END IF
  '  strParameters = TRIM$(PARSE$(strSPR," ",2))
  '
  IF strParameters <> "" THEN
  ' we have some parameters - so store them
    REDIM a_strParameters(1 TO PARSECOUNT(strParameters,",")) AS STRING
    FOR lngR = 1 TO UBOUND(a_strParameters)
    ' trim off @
      a_strParameters(lngR) = MID$(PARSE$(strParameters,",",lngR),2)
    NEXT lngR
  END IF
  '
  ' trim of parameters from stored procedure name
  strSPR = TRIM$(PARSE$(strSPR," ",1))
  '
  SELECT CASE strSPR
    CASE "CDEF_sprAddHiddenColumn"
    ' add a new column
      FUNCTION = funAddHiddenColumn(strParameters)
    '
    CASE "CDEF_sprUpdateTabRefs"
    ' update the table refs
    ' first get the name of the file
      strFileName = EXE.PATH$ & "CDEF_Config\" & _
      "CDEF_sprGetTabRefs" & " " & FORMAT$(g_lngCBOAppSelected) & "," &  _
                                   FORMAT$(g_lngCBOFormSelected) & "," &  _
                                   FORMAT$(g_lngCBOGridSelected) & "," &  _
                                   FORMAT$(g_lngCBOTabSelected) & ".cfg"
    ' get references for specific fields
'    for lngP = 1 to ubound(a_strParameters)
'      strField = PARSE$(a_strParameters(lngP),"=",1)
'      select case strField
'        case "ColumnColour"
'        ' look up column colour reference
'          strValue = PARSE$(a_strParameters(lngP),"=",2)
'          strValue = funGetRefValue("CDEF_sprGetColours.cfg",strValue)
'          ' put value back into cell
'          a_strParameters(lngP) = strField & "='" & strValue & "'"
'        case "JustifyText"
'        ' look up justification reference
'          strValue = PARSE$(a_strParameters(lngP),"=",2)
'          strValue = funGetRefValue("CDEF_sprGetJustifications.cfg",strValue)
'          ' put value back into cell
'          a_strParameters(lngP) = strField & "='" & strValue & "'"
'      end select
'    next lngP


    '
    ' first load the file into memory
    IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                        BYREF a_strData()) THEN
    ' file is now loaded
    ' work out the column positions
      strHeaders = a_strData(0)
      ' find the row to update
      lngFound = %FALSE
      '
      FOR lngR = 1 TO UBOUND (a_strData)
        ' check every row in the array for a match
        ' get the field name and value of first parameter
        ' which is our where clause
        strField = PARSE$(a_strParameters(1),"=",1)
        strValue = PARSE$(a_strParameters(1),"=",2)
        REPLACE "'" WITH "" IN strValue
        '
        lngColumn = funParseFind(strHeaders,"|",strField)
        IF PARSE$(a_strData(lngR),"|", lngColumn) = strValue THEN
        ' found the row we are looking for
          lngFound = %TRUE
          ' now put the updated information into the fields
          IF ISTRUE funUpdateArray(BYREF a_strData(), lngR, _
                                   BYREF a_strParameters() ) THEN
          ' now save the array back to disk
            lngFound = funArrayDump(strFileName,a_strData())
          '
          END IF
          '
          EXIT FOR  ' and exit the loop
          '
        END IF
      NEXT lngR
      '
      IF ISTRUE lngFound THEN
        FUNCTION = %TRUE
      ELSE
        strError = "No data updated"
        FUNCTION = %FALSE
      END IF
    '
    ELSE
      strError = "Unable to load file
      FUNCTION = %FALSE
    END IF
    '
  END SELECT


  FUNCTION = %TRUE
END FUNCTION
'
FUNCTION funUpdateArray(BYREF a_strData() AS STRING, _
                        lngR AS LONG, _
                        BYREF a_strParameters() AS STRING ) AS LONG
' update the array element
  LOCAL strHeaders AS STRING
  LOCAL lngC AS LONG
  LOCAL lngD AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngTotalColumns AS LONG
  LOCAL strField AS STRING
  LOCAL strValue AS STRING
  LOCAL strData AS STRING
  LOCAL lngUpdateCount AS LONG
  '
  strHeaders = a_strData(0)  ' store the header row
  strData = a_strData(lngR)  ' store the data row
  '
  lngTotalColumns = PARSECOUNT(strHeaders,"|")
  FOR lngD = 2 TO lngTotalColumns
    strField = PARSE$(strHeaders,"|",lngD)
    FOR lngC = 1 TO UBOUND(a_strParameters)
      IF strField = PARSE$(a_strParameters(lngC),"=",1) THEN
      ' field found
        strValue = PARSE$(a_strParameters(lngC),"=",2)
        REPLACE "'" WITH "" IN strValue
        strData = funParsePut(strData,"|",lngC, strValue)
        '
        INCR lngUpdateCount
        EXIT FOR
      '
      END IF
    NEXT lngC
    '
  NEXT lngD
  '
  IF lngUpdateCount > 0 THEN
  ' update the array now
    a_strData(lngR) = strData
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funGetGenericData(strSQL AS STRING , _
                           BYREF a_strData() AS STRING , _
                           lngDB AS LONG, _
                           OPTIONAL strError AS STRING) AS LONG
                           '
  FUNCTION = funGetSQLResultset(strSQL, _
                                strError, _
                                a_strData(), _
                                lngDB, _
                                lngDB)
  '
END FUNCTION
'
FUNCTION funGetSQLResultset(strSQL AS STRING, _
                            strError AS STRING, _
                            a_strData() AS STRING, _
                            lngDBref AS LONG, _
                            lngDB AS LONG) AS LONG
' get the data
' strSQL contains the request
' e.g. strSQL = "EXEC " & g_strDBDatabase & ".dbo.CDEF_sprReadAppFormGridDefinitions '"  & strApplicationName & "'"
  LOCAL strDB AS STRING
  LOCAL strFile AS STRING
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  LOCAL strSPR AS STRING
  LOCAL strParameters AS STRING
  ' get the name of the stored procedure & parameters
  strSPR = PARSE$(strSQL,"dbo.",2)
  ' get the parameters - if any
  strParameters = TRIM$(PARSE$(strSPR," ",2))
  '
  IF strParameters <> "" THEN
    strParameters = " " & strParameters
  END IF
  '
  ' trim of parameters from stored procedure name
  strSPR = TRIM$(PARSE$(strSPR," ",1))
  '
  strFile = "CDEF_Config\" & strSPR & strParameters & ".cfg"
  '
  SELECT CASE strSPR
    CASE "CDEF_sprGetTabRefs"
    ' store the refs of the App, Form, Grid & tab
    ' when a new tab is selected
      g_lngCBOAppSelected  = VAL(PARSE$(strParameters,",",1))
      g_lngCBOFormSelected = VAL(PARSE$(strParameters,",",2))
      g_lngCBOGridSelected = VAL(PARSE$(strParameters,",",3))
      g_lngCBOTabSelected  = VAL(PARSE$(strParameters,",",4))
      '
    CASE "CDEF_sprGetApplicationID"
    ' get the application id
      FUNCTION = funReadAppID(TRIM$(strParameters), BYREF a_strData())
      EXIT FUNCTION
      '
    CASE "CDEF_sprGetFormID"
    ' get the form ID
      FUNCTION = funReadFormID(TRIM$(strParameters), BYREF a_strData())
      EXIT FUNCTION
      '
    CASE "CDEF_sprGetGridID"
    ' get the grid ID
      FUNCTION = funReadGridID(TRIM$(strParameters), BYREF a_strData())
      EXIT FUNCTION
      '
    CASE "CDEF_sprGetTabID"
    ' get the tab id
      FUNCTION = funReadTabID(TRIM$(strParameters), BYREF a_strData())
      EXIT FUNCTION
      '
    CASE "CDEF_sprCountTabRefs"
    ' get the tab refs
      FUNCTION = funCountTabRefs(TRIM$(strParameters), BYREF a_strData())
      EXIT FUNCTION
    '
    CASE "CDEF_sprAddHiddenColumn"
    ' add the hidden columns

  END SELECT
  '
  ' read that file into the array
  IF ISTRUE funReadTheFileIntoAnArray(strFile,a_strData()) THEN
    FOR lngR = 1 TO UBOUND(a_strData,1)
      strData = a_strData(lngR)
      REPLACE "NULL|" WITH "|" IN strData
      REPLACE "|NULL" WITH "|" IN strData
      a_strData(lngR) = strData
    NEXT lngR
    '
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funReadAppID(strParameters AS STRING, _
                      BYREF a_strOutputData() AS STRING) AS LONG
' read the app id or provide a new one
  DIM a_strData() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngFound AS LONG
  LOCAL strAppname AS STRING
  LOCAL lngAppID AS LONG
  '
  ' used to hold output from this function
  REDIM a_strOutputData(1) AS STRING
  '
  strAppName = strParameters
  REPLACE "'" WITH "" IN strAppName
  '
  strFilename = EXE.PATH$ & "CDEF_Config\" & "CDEF_sprGetAllApplications.cfg"
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strData()) THEN
    ' look for existing app
    FOR lngR = 1 TO UBOUND(a_strData)
      lngAppID = VAL(PARSE$(a_strData(lngR),"|",1))
      IF PARSE$(a_strData(lngR),"|",2) = strAppName THEN
        lngFound = %TRUE
        EXIT FOR
      END IF
    NEXT lngR
    '
    IF ISTRUE lngFound THEN
    ' found an existing app ref
      a_strOutputData(1) = FORMAT$(lngAppID)
      FUNCTION = %TRUE
      EXIT FUNCTION
    ELSE
    ' no app with this name exists
    ' so add one
      INCR lngAppID
      ' extend the array
      REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
      ' and save the new data to it
      a_strData(UBOUND(a_strData)) = FORMAT$(lngAppID) & "|" & strAppName
      'save the updated file
      IF ISTRUE funArrayDump(strFilename,BYREF a_strData()) THEN
        a_strOutputData(1) = FORMAT$(lngAppID)
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
      '
    END IF
    '
  ELSE
  ' no file found
    a_strOutputData(1) = "1"
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funReadFormID(strParameters AS STRING, _
                      BYREF a_strOutputData() AS STRING) AS LONG
' read the form id or provide a new one
  DIM a_strData() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngFound AS LONG
  LOCAL lngAppID AS LONG
  LOCAL lngFormID AS LONG
  '
  LOCAL strFormName AS STRING
  '
  ' used to hold output from this function
  REDIM a_strOutputData(1) AS STRING
  '
  lngAppID = VAL(PARSE$(strParameters,",",2))
  strFormName = PARSE$(strParameters,",",1)
  REPLACE "'" WITH "" IN strFormName
  '
  strFilename = EXE.PATH$ & "CDEF_Config\" & "CDEF_sprGetAllFormsInApp " & _
                FORMAT$(lngAppID) & ".cfg"
                '
  IF ISFALSE ISFILE(strFilename) THEN
  ' no file exists yet - so create empty file with headers
    REDIM a_strData(0) AS STRING
    a_strData(0) = "idxCDEFform|Formname"
    funArrayDump(strFilename,BYREF a_strData())
    '
  END IF
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strData()) THEN
  ' look for existing form
    FOR lngR = 1 TO UBOUND(a_strData)
      lngFormID = VAL(PARSE$(a_strData(lngR),"|",1))
      IF PARSE$(a_strData(lngR),"|",2) = strFormName THEN
        lngFound = %TRUE
        EXIT FOR
      END IF
    NEXT lngR
    '
    IF ISTRUE lngFound THEN
    ' found an existing form ref
      a_strOutputData(1) = FORMAT$(lngFormID)
      FUNCTION = %TRUE
      EXIT FUNCTION
    ELSE
    ' no form with this name exists
    ' so add one
      INCR lngFormID
      ' extend the array
      REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
      ' and save the new data to it
      a_strData(UBOUND(a_strData)) = FORMAT$(lngFormID) & "|" & strFormName
      'save the updated file
      IF ISTRUE funArrayDump(strFilename,BYREF a_strData()) THEN
        a_strOutputData(1) = FORMAT$(lngFormID)
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
      '
    END IF
    '
    '
  ELSE
  ' no file found
  '
  END IF
  '
END FUNCTION
'
FUNCTION funReadGridID(strParameters AS STRING, _
                      BYREF a_strOutputData() AS STRING) AS LONG
' read the Grid id or provide a new one
  DIM a_strData() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngFound AS LONG
  LOCAL lngAppID AS LONG
  LOCAL lngFormID AS LONG
  LOCAL lngGridID AS LONG
  '
  LOCAL strGridName AS STRING
  '
  ' used to hold output from this function
  REDIM a_strOutputData(1) AS STRING
  '
  lngAppID = VAL(PARSE$(strParameters,",",2))
  lngFormID = VAL(PARSE$(strParameters,",",3))
  strGridName = PARSE$(strParameters,",",1)
  REPLACE "'" WITH "" IN strGridName
  '
  strFilename = EXE.PATH$ & "CDEF_Config\" & "CDEF_sprGetAllGridsInForm " & _
                FORMAT$(lngAppID) & "," & FORMAT$(lngFormID) & ".cfg"
                '
  IF ISFALSE ISFILE(strFilename) THEN
  ' no file exists yet - so create empty file with headers
    REDIM a_strData(0) AS STRING
    a_strData(0) = "idxCDEFgrid|Gridname"
    funArrayDump(strFilename,BYREF a_strData())
  '
  END IF

  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                       BYREF a_strData()) THEN
    ' look for existing grid
    FOR lngR = 1 TO UBOUND(a_strData)
      lngGridID = VAL(PARSE$(a_strData(lngR),"|",1))
      IF PARSE$(a_strData(lngR),"|",2) = strGridName THEN
        lngFound = %TRUE
        EXIT FOR
      END IF
    NEXT lngR
    '
    IF ISTRUE lngFound THEN
    ' found an existing form ref
      a_strOutputData(1) = FORMAT$(lngGridID)
      FUNCTION = %TRUE
      EXIT FUNCTION
    ELSE
    ' no form with this name exists
    ' so add one
      INCR lngGridID
      ' extend the array
      REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
      ' and save the new data to it
      a_strData(UBOUND(a_strData)) = FORMAT$(lngGridID) & "|" & strGridName
      'save the updated file
      IF ISTRUE funArrayDump(strFilename,BYREF a_strData()) THEN
        a_strOutputData(1) = FORMAT$(lngGridID)
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
      '
    END IF
    '
    '
   ELSE
   END IF
   '
END FUNCTION
'
FUNCTION funReadTabID(strParameters AS STRING, _
                      BYREF a_strOutputData() AS STRING) AS LONG
' read the Tab id or provide a new one
  DIM a_strData() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngFound AS LONG
  LOCAL lngAppID AS LONG
  LOCAL lngFormID AS LONG
  LOCAL lngGridID AS LONG
  LOCAL lngTabID AS LONG
  '
  LOCAL strTabName AS STRING
  '
  ' used to hold output from this function
  REDIM a_strOutputData(1) AS STRING
  '
  lngAppID = VAL(PARSE$(strParameters,",",2))
  lngFormID = VAL(PARSE$(strParameters,",",3))
  lngGridID  = VAL(PARSE$(strParameters,",",4))
  strTabName = PARSE$(strParameters,",",1)
  REPLACE "'" WITH "" IN strTabName
  '
  strFilename = EXE.PATH$ & "CDEF_Config\" & "CDEF_sprGetAllTabsInGrid " & _
                FORMAT$(lngAppID) & "," & FORMAT$(lngFormID) & "," & _
                FORMAT$(lngGridID) & ".cfg"
                '
  IF ISFALSE ISFILE(strFilename) THEN
  ' no file exists yet - so create empty file with headers
    REDIM a_strData(0) AS STRING
    a_strData(0) = "idxCDEFtabs|Tabname"
    funArrayDump(strFilename,BYREF a_strData())
    '
  END IF
                '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                       BYREF a_strData()) THEN
    ' look for existing tab
    FOR lngR = 1 TO UBOUND(a_strData)
      lngTabID = VAL(PARSE$(a_strData(lngR),"|",1))
      IF PARSE$(a_strData(lngR),"|",2) = strTabName THEN
        lngFound = %TRUE
        EXIT FOR
      END IF
    NEXT lngR
    '
    IF ISTRUE lngFound THEN
    ' found an existing tab ref
      a_strOutputData(1) = FORMAT$(lngTabID)
      FUNCTION = %TRUE
      EXIT FUNCTION
    ELSE
    ' no tab with this name exists
    ' so add one
      INCR lngTabID
      ' extend the array
      REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
      ' and save the new data to it
      a_strData(UBOUND(a_strData)) = FORMAT$(lngTabID) & "|" & strTabName
      ' save the updated file
      IF ISTRUE funArrayDump(strFilename,BYREF a_strData()) THEN
        a_strOutputData(1) = FORMAT$(lngTabID)
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
      '
    END IF
    '
    '
   ELSE
   END IF
'
END FUNCTION
'
FUNCTION funCountTabRefs(strParameters AS STRING, _
                        BYREF a_strOutputData() AS STRING) AS LONG
' count the tab references
  DIM a_strData() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngAppID AS LONG
  LOCAL lngFormID AS LONG
  LOCAL lngGridID AS LONG
  LOCAL lngTabID AS LONG
  LOCAL lngGridPosition AS LONG
  LOCAL lngLocalGridPosition AS LONG
  LOCAL lngColumn AS LONG
  '
  ' used to hold output from this function
  REDIM a_strOutputData(1) AS STRING
  '
  lngAppID = VAL(PARSE$(strParameters,",",1))
  lngFormID = VAL(PARSE$(strParameters,",",2))
  lngGridID  = VAL(PARSE$(strParameters,",",3))
  lngTabID = VAL(PARSE$(strParameters,",",4))
  '
  strFilename = EXE.PATH$ & "CDEF_Config\" & "CDEF_sprGetTabRefs " & _
                FORMAT$(lngAppID) & "," & FORMAT$(lngFormID) & "," & _
                FORMAT$(lngGridID) & "," & FORMAT$(lngTabID) & ".cfg"
                '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                       BYREF a_strData()) THEN
  ' file loaded now determine the biggest grid position
    lngColumn = funParseFind(a_strData(0),"|","GridPos")
    FOR lngR = 1 TO UBOUND(a_strData)
      lngLocalGridPosition = VAL(PARSE$(a_strData(lngR),"|",lngColumn))
      IF lngLocalGridPosition > lngGridPosition THEN
        lngGridPosition = lngLocalGridPosition
      END IF
    NEXT lngR
    '
    a_strOutputData(1) = FORMAT$(lngGridPosition)
    FUNCTION = %TRUE
    '
  ELSE
  ' no file
    a_strOutputData(1) = "0"
    FUNCTION = %TRUE
  '
  END IF
  '
END FUNCTION
'
FUNCTION funAddHiddenColumn(strParameters AS STRING) AS LONG
' add a hidden column to the tab refs table
  DIM a_strData() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  LOCAL lngAppID AS LONG
  LOCAL lngFormID AS LONG
  LOCAL lngGridID AS LONG
  LOCAL lngTabID AS LONG
  LOCAL lngRefID AS LONG
  LOCAL strColumnName AS STRING
  '
  LOCAL lngFile AS LONG
  '
  lngAppID = VAL(PARSE$(strParameters,",",1))
  lngFormID = VAL(PARSE$(strParameters,",",2))
  lngGridID  = VAL(PARSE$(strParameters,",",3))
  lngTabID = VAL(PARSE$(strParameters,",",4))
  lngRefID = VAL(PARSE$(strParameters,",",5))
  strColumnName = PARSE$(strParameters,",",6)
  REPLACE "'" WITH "" IN strColumnName
  '
  strFilename = EXE.PATH$ & "CDEF_Config\" & "CDEF_sprGetTabRefs " & _
                FORMAT$(lngAppID) & "," & FORMAT$(lngFormID) & "," & _
                FORMAT$(lngGridID) & "," & FORMAT$(lngTabID) & ".cfg"
                '
  IF ISFALSE ISFILE(strFileName) THEN
  ' create the file
    lngFile = FREEFILE
    OPEN strFileName FOR OUTPUT AS #lngFile
    ' output the header
      PRINT #lngFile,"idxCDEFTabRef|TabPos|GridPos|ColumnName|ResultName|" & _
                     "Columnwidth|ColumnHide|ColumnColour|ColumnPrimary|" & _
                     "ColumnLock|JustifyText|ColumnCheckBox|ColumnUserButtonID|" & _
                     "ColumnCheckBoxCounterLimit|ColumnDropdown|ColumnDropdownSPR|" _
                     "ColumnDateTime|ColumnSupressTime|ColumnNotesField
    CLOSE #lngFile
  END IF
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                       BYREF a_strData()) THEN
    REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
    a_strData(UBOUND(a_strData)) = FORMAT$(lngRefID) & "||" & _
                                   FORMAT$(lngRefID) & "|" & _
                                   strColumnName & "|" & _
                                   strColumnName & "|" & _
                                   "100|1|NULL|0|1|Centre|0|0|0|0||0|0|NULL"
                                   '
    IF ISTRUE funArrayDump(strFilename,BYREF a_strData()) THEN
      FUNCTION = %TRUE
    END IF
    '
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funUserOpenDB(lngDB AS LONG , _
                       strSQLServer AS STRING, _
                       strDBDatabase AS STRING, _
                       strConnectionString AS STRING) AS LONG
  FUNCTION = %TRUE
END FUNCTION
'
FUNCTION SQL_Init() AS LONG
  FUNCTION = %SUCCESS
END FUNCTION
'
FUNCTION SQL_Shutdown() AS LONG
  FUNCTION = %SUCCESS
END FUNCTION
'
FUNCTION funEscapeApostrophe(BYVAL strData AS STRING) AS STRING
  ' Handle single ' in sql strings
  REPLACE "'" WITH "''" IN strData
  FUNCTION = strData
END FUNCTION
