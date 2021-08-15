' Form - grid - tab resource info

' column definitions

TYPE uTabColumn
  GridPos AS LONG                        ' column position in the grid
  ColumnName AS STRING * 50              ' name of the column
  ResultPos AS LONG                      ' result position in the sql spr
  ResultName AS STRING * 100             ' name of the parameter in the sql spr
  TabPos AS LONG                         ' ordinal position of the tab
  ' grid column definitions
  ColumnPrimary AS LONG                  ' true if the column is the primary key on this record
  ColumnLock AS LONG                     ' true if column read only
  ColumnJustify AS LONG                  ' justify value   -1(left) 0(centre) 1(right)
  ColumnCheckBox AS LONG                 ' true if column is a check box
  ColumnDateTime AS LONG                 ' true if column contains a date time
  ColumnSupressTime AS LONG              ' true if the time element on the datetime should be supressed
  ColumnCheckBoxCounterLimit AS LONG     ' when value in the result is >= this number then check box is ticked
  ColumnUserButtonID AS LONG             ' true if a user button needs drawn here
  ColumnHide AS LONG                     ' true if column is to be hidden
  ColumnWidth AS LONG                    ' column width in pixels
  ColumnColour AS LONG                   ' columns text colour
                                         ' (0 = black) (1= red) (2= blue)
  ColumnDropdown AS LONG                 ' true is column is a dropdown
  ColumnDropdownSPR AS STRING * 255      ' sql spr call to populate the column
  ColumnNote AS LONG                     ' true if Column is a notes field
  ColumnCurrency AS LONG                 ' true if column is a currency field
  '
END TYPE
'
TYPE uTabs
  TabName AS STRING * 50
  TabColumn(%max_cols) AS uTabColumn
END TYPE
'
TYPE uGrids
  GridName AS STRING * 50
  GridTab(%max_tabs) AS uTabs
END TYPE
'
TYPE uForms
  FormName AS STRING * 50
  FormGrid(%Max_Grids) AS uGrids
END TYPE
'
TYPE uApp
  AppName AS STRING * 100
  AppForm(%Max_Forms) AS uForms
END TYPE

GLOBAL udtApp AS uApp
'
FUNCTION funInitialiseUDT() AS LONG
' initialise the UDT
  LOCAL lngForm AS LONG
  LOCAL lngGrid AS LONG
  LOCAL lngTab AS LONG
  LOCAL lngColumn AS LONG
  '
  udtApp.AppName = ""
  FOR lngForm = 1 TO %Max_forms
    udtApp.AppForm(lngForm).FormName = ""
    '
    FOR lngGrid = 1 TO %Max_grids
      udtApp.AppForm(lngForm).FormGrid(lngGrid).GridName = ""
      '
      FOR lngTab = 1 TO %Max_tabs
        udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabName = ""
        '
        FOR lngColumn = 1 TO %Max_cols
          udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnName = ""
          udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnDropdownSPR = ""
          udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName = ""
        NEXT lngColumn
      NEXT lngTab
    NEXT lngGrid
  NEXT lngForm
  '
END FUNCTION
'
FUNCTION funReadAppFormGridDefinitions(strApplicationName AS STRING) AS LONG
' read the applications Form grid definitions
  LOCAL strSQL AS STRING
  LOCAL strError AS STRING
  DIM a_strData() AS STRING
  LOCAL lngR AS LONG
  LOCAL strTemp AS STRING
  LOCAL strRecord AS STRING
  '
  LOCAL lngFormCounter AS LONG
  LOCAL lngGridCounter AS LONG
  LOCAL lngTabCounter AS LONG
  LOCAL lngColumnCounter AS LONG
  '
  LOCAL strForm AS STRING
  LOCAL strGrid AS STRING
  LOCAL strTab AS STRING
  LOCAL strTabPos AS STRING
  LOCAL strColumnName AS STRING
  LOCAL strColumnWidth AS STRING
  LOCAL strColumnCheckBox AS STRING
  LOCAL strColumnHidden AS STRING
  LOCAL strColumnUserButton AS STRING
  LOCAL strColumnReadonly AS STRING
  LOCAL strColumnJustify AS STRING
  LOCAL strColumnColour AS STRING
  LOCAL strColumnDropDown AS STRING
  LOCAL strColumnDropDownSPR AS STRING
  LOCAL strColumnCheckBoxCounterLimit AS STRING
  LOCAL strColumnPrimary AS STRING
  LOCAL strColumnDateTime AS STRING
  LOCAL strColumnSupressTime AS STRING
  LOCAL strColumnNote AS STRING
  LOCAL strResultName AS STRING
  LOCAL strGridPos AS STRING
  LOCAL strColumnCurrency AS STRING
  '
  LOCAL strOldForm AS STRING
  LOCAL strOldGrid AS STRING
  LOCAL strOldTab AS STRING
  LOCAL strOldColumnName AS STRING
  '
  strSQL = "EXEC " & g_strDBDatabase & ".dbo.CDEF_sprReadAppFormGridDefinitions '"  & strApplicationName & "'"
  '
  IF ISTRUE funGetGenericData(strSQL ,BYREF a_strData() ,1 ) THEN
  ' got the data
    IF UBOUND(a_strData)<> -1 THEN
    ' array is populated
      funInitialiseUDT()
      '
      lngFormCounter = 0
      lngGridCounter = 0
      lngTabCounter = 0
      lngColumnCounter = 0
      '
      strTemp = ""
      '
      FOR lngR = 1 TO UBOUND(a_strData)
      ' read thro and process the array
        strRecord = a_strData(lngR)
        strForm = PARSE$(strRecord,"|",2)
        strGrid = PARSE$(strRecord,"|",3)
        strTab = PARSE$(strRecord,"|",4)
        strTabPos = PARSE$(strRecord,"|",5)
        strGridPos = PARSE$(strRecord,"|",6)
        strColumnName = PARSE$(strRecord,"|",7)

        strColumnReadonly = PARSE$(strRecord,"|",9)
        strColumnJustify = PARSE$(strRecord,"|",10)
        strColumnCheckBox = PARSE$(strRecord,"|",11)
        strColumnUserButton = PARSE$(strRecord,"|",12)
        strColumnHidden = PARSE$(strRecord,"|",13)
        strColumnWidth = PARSE$(strRecord,"|",14)
        strColumnColour = PARSE$(strRecord,"|",15)
        strColumnCheckBoxCounterLimit = PARSE$(strRecord,"|",16)
        strColumnDropdown = PARSE$(strRecord,"|",17)
        strColumnDropdownSPR = PARSE$(strRecord,"|",18)
        strResultName = PARSE$(strRecord,"|",19)
        strColumnPrimary = PARSE$(strRecord,"|",20)
        strColumnDateTime = PARSE$(strRecord,"|",21)
        strColumnSupressTime = PARSE$(strRecord,"|",22)
        strColumnNote = PARSE$(strRecord,"|",23)
        strColumnCurrency = PARSE$(strRecord,"|",24)
        '
        IF strForm <> strOldForm THEN
        ' new form
          INCR lngFormCounter
          ' reset all the pointers
          lngGridCounter = 0
          lngTabCounter = 0
          lngColumnCounter = 0
          strOldForm = strForm
        END IF
        '
        IF strGrid <> strOldGrid THEN
          INCR lngGridCounter
          lngTabCounter = 0
          lngColumnCounter = 0
          strOldGrid = strGrid
        END IF
        '
        IF strTab <> strOldTab THEN
          INCR lngTabCounter
          lngColumnCounter = 0
          strOldTab = strTab
        END IF
        '
        IF strColumnName <> strOldColumnName THEN
          INCR lngColumnCounter
          strOldColumnName = strColumnName
        END IF
        '
        PREFIX "udtApp."
          AppName = strApplicationName
          AppForm(lngFormCounter).FormName = strForm
          Appform(lngFormCounter).FormGrid(lngGridCounter).GridName = strGrid
          AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabName = strTab
          AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnName = strColumnName
          AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnWidth = VAL(strColumnWidth)
          '
        END PREFIX
        '
        IF strColumnCurrency = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnCurrency = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnCurrency = %FALSE
        END IF

        '
        IF strColumnNote = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnNote = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnNote = %FALSE
        END IF
        '
        IF strColumnSupressTime = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnSupressTime = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnSupressTime = %FALSE
        END IF
        '
        IF strColumnDateTime = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnDateTime = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnDateTime = %FALSE
        END IF
        '
        IF strColumnReadonly = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnLock = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnLock = %FALSE
        END IF
        '
        IF strColumnCheckBox = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnCheckbox = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnCheckbox = %FALSE
        END IF
        '
        IF strColumnHidden = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnHide = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnHide = %FALSE
        END IF
        '
        udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnJustify = VAL(strColumnJustify)
        udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnColour = VAL(strColumnColour)
        '
        IF strColumnDropDown = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnDropdown = %TRUE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnDropdownSPR = strColumnDropdownSPR
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnDropdown = %FALSE
        END IF
        '
        udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ResultName = strResultName
        udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).GridPos = VAL(strGridPos)
        udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).TabPos = VAL(strTabPos)
        '
        IF strColumnUserButton = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnUserButtonID = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnUserButtonID = %FALSE
        END IF
        '
        udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnCheckBoxCounterLimit = VAL(strColumnCheckBoxCounterLimit)
        '
        IF strColumnPrimary = "1" THEN
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnPrimary = %TRUE
        ELSE
          udtApp.AppForm(lngFormCounter).FormGrid(lngGridCounter).GridTab(lngTabCounter).TabColumn(lngColumnCounter).ColumnPrimary = %FALSE
        END IF
        '
      NEXT lngR
      FUNCTION = %TRUE
    ELSE
    ' array is empty
      FUNCTION = %FALSE
    END IF
    '
  ELSE
  ' cant get the data
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetFormNumber(strFormName AS STRING) AS LONG
' return the form Number
  LOCAL lngForm AS LONG
  '
  FOR lngForm = 1 TO %Max_Forms
    IF TRIM$(udtApp.AppForm(lngForm).FormName) = strFormName THEN
      FUNCTION = lngForm
      EXIT FUNCTION
    END IF
  NEXT lngForm
  '
  FUNCTION = 0
END FUNCTION
'
FUNCTION funGetGridNumber(lngForm AS LONG, strGridName AS STRING) AS LONG
' return the Grid number
  LOCAL lngGrid AS LONG
  '
  FOR lngGrid = 1 TO %Max_Grids
    IF TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridName) = strGridName THEN
      FUNCTION = lngGrid
      EXIT FUNCTION
    END IF
  NEXT lngGrid
  '
  FUNCTION = 0
'
END FUNCTION
'
FUNCTION funGetTabNumber(lngForm AS LONG, lngGrid AS LONG, strTabName AS STRING) AS LONG
' return the tab number
  LOCAL lngTab AS LONG
  '
  FOR lngTab = 1 TO %Max_tabs
    IF TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabName) = strTabName THEN
      FUNCTION = lngTab
      EXIT FUNCTION
    END IF
  NEXT lngTab
  '
  FUNCTION = 0
  '
END FUNCTION
'
FUNCTION funGetTabColumnCount(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG _
                              , o_TabColumnNamelist AS STRING) AS LONG
' return the number of columns and their names on this grid tab
  LOCAL lngColumn AS LONG
  LOCAL lngColumnCount AS LONG
  LOCAL strColumnName AS STRING
  '
  FOR lngColumn = 1 TO %Max_Cols
  ' look through each column
    strColumnName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnName)
    IF strColumnName <> "" THEN
      INCR lngColumnCount
      o_TabColumnNamelist = o_TabColumnNamelist & "|" & strColumnName
    END IF
  '
  NEXT lngColumn
  '
  o_TabColumnNamelist = TRIM$(o_TabColumnNamelist,"|")
  FUNCTION = lngColumnCount
  '
END FUNCTION
'
FUNCTION funGetTabCount(lngForm AS LONG, lngGrid AS LONG, o_TabNamelist AS STRING) AS LONG
' return the number of tabs on this grid
  LOCAL lngTab AS LONG
  LOCAL lngTabCount AS LONG
  LOCAL strOldTabName AS STRING
  LOCAL strTabName AS STRING
  LOCAL strTabPos AS STRING        ' ordinal position of the tab
  '
  FOR lngTab = 1 TO %Max_Tabs
    ' get the tab name
    strTabName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabName)
    ' now get the ordinal position of the tab
    strTabPos = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(1).TabPos)
    '
    IF strTabName = "" THEN ITERATE FOR  ' skip past blank entries
    IF strOldTabName <> strTabName THEN
    ' another tab detected - so up the counter
      INCR lngTabCount
      o_TabNamelist = o_TabNamelist & "|" & strTabName & "/" & strTabPos
      strOldTabName = strTabName
    END IF
  NEXT lngTab
  '
  o_TabNamelist = TRIM$(o_TabNamelist, "/")
  o_TabNamelist = TRIM$(o_TabNamelist, "|")
  FUNCTION = lngTabCount
  '
END FUNCTION
'
FUNCTION funIsResultUserButton(lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG,lngColumn AS LONG) AS LONG
' return %TRUE if the result column holds a user button
  FUNCTION = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnUserButtonID
END FUNCTION
'
FUNCTION funGetGridResultNameFromColNumber(lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG, lngColNumber AS LONG) AS STRING
' return the Result name given the grid column position number
  LOCAL lngUdtColNumber AS LONG
  LOCAL lngColumn AS LONG
  '
  FOR lngColumn = 1 TO %Max_cols
    lngUdtColNumber = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
    IF lngUdtColNumber = lngColNumber THEN
      FUNCTION = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
END FUNCTION
'
FUNCTION funGetGridColumnPositionFromUDT(lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG, strResultName AS STRING) AS LONG
' return the grid column position given the ResultName
  LOCAL lngColumn AS LONG
  LOCAL strUdtResultName AS STRING
  '
  FOR lngColumn = 1 TO %Max_cols
    strUdtResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
    IF strUdtResultName = strResultName THEN
      FUNCTION = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
END FUNCTION
'
FUNCTION funGetUDT_TabPosFromOrdinalPosition(lngForm AS LONG,lngGrid AS LONG,lngTabPos AS LONG, _
                                             o_strTabname AS STRING) AS LONG
' return the tab position in the UDT given the Ordinal Tab position in the Grid
  LOCAL lngTab AS LONG
  FOR lngTab = 1 TO %Max_Tabs
    IF udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(1).TabPos = lngTabPos THEN
      o_strTabname = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabName)
      FUNCTION = lngTab
      EXIT FUNCTION
    END IF
  NEXT lngTab
  '
  FUNCTION = 0
END FUNCTION
'
FUNCTION funGetUdtColumnPositionFromGrid(lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG, strGridColumnName AS STRING) AS LONG
' return the column position in the UDT given the Grid Column name
  LOCAL lngColumn AS LONG
  LOCAL strResultName AS STRING
  '
  FOR lngColumn = 1 TO %Max_cols
    strResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnName)
    IF LCASE$(strResultName) = LCASE$(strGridColumnName) THEN
      FUNCTION = lngColumn
      EXIT FUNCTION
    END IF
  NEXT lngColumn
'
END FUNCTION
'
FUNCTION funGetUdtColumnPositionFromResult(lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG, strResultColumnName AS STRING) AS LONG
' return the column position in the UDT given the Result Column name
  LOCAL lngColumn AS LONG
  LOCAL strResultName AS STRING
  '
  FOR lngColumn = 1 TO %Max_cols
    strResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
    IF LCASE$(strResultName) = LCASE$(strResultColumnName) THEN
      FUNCTION = lngColumn
      EXIT FUNCTION
    END IF
  NEXT lngColumn
'
END FUNCTION

'
FUNCTION funGetGridPosition(lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG,BYVAL strResultColumnName AS STRING, o_lngColumn AS LONG) AS LONG
' get the grid position of this Result column
' where o_lngColumn is the position in the UDT
  LOCAL lngColumn AS LONG
  LOCAL strResultName AS STRING
  o_lngColumn = 0
  '
  'replace any "[]" with "" in  strResultColumnName
  '
  FOR lngColumn = 1 TO %Max_cols
    strResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
    IF LCASE$(strResultName) = LCASE$(strResultColumnName) THEN
      o_lngColumn = lngColumn
      FUNCTION = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
  FUNCTION = 0
  '
END FUNCTION
'
FUNCTION funGetResultNameOfPrimaryColumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, hGrid AS DWORD, _
                                    lngRow AS LONG) AS STRING
' return the name of the ResultColumn for the primary key
  LOCAL lngColumn AS LONG
  LOCAL lngGridPos AS LONG
  '
  FOR lngColumn = 1 TO %Max_cols
    IF ISTRUE udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnPrimary THEN
    ' found the Primary column - get the ResultName
      FUNCTION = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
  FUNCTION = ""
'
END FUNCTION
'
FUNCTION funSetValueOfResultColumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, hGrid AS DWORD, _
                                   lngRow AS LONG, strResultName AS STRING, strValue AS STRING, _
                                   OPTIONAL lngHighlight AS LONG) AS LONG
' set the value contained in a Row/Cell
' optional value when %TRUE will highlight the updated cell
  LOCAL lngColumn AS LONG
  LOCAL strUdtResultName AS STRING
  LOCAL lngGridPos AS LONG
  '
  FOR lngColumn = 1 TO %Max_cols
    strUdtResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
    IF strUdtResultName = strResultName THEN
      lngGridPos = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
      '
      MLG_PUT(hGrid,lngRow,lngGridPos, strValue,0)
      IF ISTRUE lngHighlight THEN
      ' highlight the cell as changed
        funMarkGridCell(hGrid ,lngRow , lngGridPos)
      END IF
      '
      FUNCTION = %TRUE
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
  ' if we get this far we couldnt find the column to update
  FUNCTION = %FALSE
END FUNCTION
'
FUNCTION funGetColNumberOfResultColumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, strResultName AS STRING) AS LONG
' return the result column position given the result name
  LOCAL lngColumn AS LONG
  LOCAL strUdtResultName AS STRING
  LOCAL lngGridPos AS LONG
  LOCAL strValue AS STRING
  '
  FOR lngColumn = 1 TO %Max_cols
    strUdtResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
    IF strUdtResultName = strResultName THEN
      FUNCTION = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultPos
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
END FUNCTION
'
FUNCTION funGetValueOfResultColumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, hGrid AS DWORD, _
                                   lngRow AS LONG, strResultName AS STRING) AS STRING
' return the value contained in a Row/Cell
  LOCAL lngColumn AS LONG
  LOCAL strUdtResultName AS STRING
  LOCAL lngGridPos AS LONG
  LOCAL strValue AS STRING
  '
  FOR lngColumn = 1 TO %Max_cols
    strUdtResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
    IF strUdtResultName = strResultName THEN
      lngGridPos = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
      '
      strValue = MLG_Get(hGrid,lngRow,lngGridPos)
      FUNCTION = strValue
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
END FUNCTION
'
FUNCTION funGetGridPositionOfPrimarycolumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, hGrid AS DWORD) AS LONG
' return the grid position of the primary key on this grid tab
  LOCAL lngColumn AS LONG
  LOCAL lngGridPos AS LONG
  '
  FOR lngColumn = 1 TO %Max_cols
    IF ISTRUE udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnPrimary THEN
    ' found the Primary column - get the grid position
      lngGridPos = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
      ' return the grid position
      FUNCTION = lngGridPos
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
  FUNCTION = 0
  '
END FUNCTION
'
FUNCTION funGetValueOfPrimaryColumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, hGrid AS DWORD, _
                                    lngRow AS LONG) AS STRING
' return the grid value of the primary key
  LOCAL lngColumn AS LONG
  LOCAL lngGridPos AS LONG
  '
  FOR lngColumn = 1 TO %Max_cols
    IF ISTRUE udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnPrimary THEN
    ' found the Primary column - get the grid position
      lngGridPos = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
      ' now get the value from the grid
      FUNCTION = MLG_Get(hGrid,lngRow,lngGridPos)
      EXIT FUNCTION
    END IF
  NEXT lngColumn
  '
  FUNCTION = ""
'
END FUNCTION
'
FUNCTION funSetProperty(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, strResultColumnName AS STRING , _
                        strProperty AS STRING, strValue AS STRING) AS LONG
' set the property given to the value provided for the Resultcolumn
  LOCAL lngGridPosition AS LONG
  LOCAL lngColumn AS LONG
  ' get back the Grid position and the lngColumn number in the UDT
  lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
  '
  SELECT CASE strProperty
    CASE "ColumnLock"
      udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnLock = VAL(strValue)
    CASE "ColumnUserButton"
      udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnUserButtonID = VAL(strValue)
  END SELECT
'
END FUNCTION
'
FUNCTION funGetProperty(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG,lngColumn AS LONG , _
                        strProperty AS STRING) AS STRING
  LOCAL strTemp AS STRING
  ' return the property of the column
  SELECT CASE strProperty
    CASE "ColumnCurrency"
    ' returns %TRUE if the column is a currency field e.g two decimal places rounding
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngcolumn).ColumnCurrency)
    '
    CASE "ColumnNote"
    ' returns %TRUE if the column is a Notes field
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngcolumn).ColumnNote)
    '
    CASE "ColumnSupressTime"
      ' returns %TRUE if the column is a datetime and the time is supressed
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnSupressTime)
    '
    CASE "ColumnDateTime"
      ' returns %TRUE if the column is a datetime column
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnDateTime)
    CASE "ColumnPrimary"
      ' returns %TRUE if the column is the primary column
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnPrimary)
      '
    CASE "ColumnCheckBoxCounterLimit"
      ' returns the number above which the checkbox should be ticked
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnCheckBoxCounterLimit)
      '
    CASE "ColumnLock"
      IF ISTRUE udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnLock THEN
        FUNCTION = FORMAT$(%MLG_LOCK)
      ELSE
        FUNCTION = FORMAT$(%MLG_NOLOCK)
      END IF
      '
    CASE "ColumnUserButton"
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnUserButtonID)
      '
    CASE "ColumnHide"
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnHide)
      '
    CASE "ColumnJustify"
      strTemp = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnJustify)
      SELECT CASE strTemp
        CASE "-1"
          FUNCTION = FORMAT$(%MLG_JUST_LEFT)
        CASE "0"
          FUNCTION = FORMAT$(%MLG_JUST_CENTER)
        CASE "1"
          FUNCTION = FORMAT$(%MLG_JUST_RIGHT)
        CASE "9"
          FUNCTION = FORMAT$(%MLG_JUST_WORDWRAP)
      END SELECT
      '
    CASE "ColumnColour"
      strTemp = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnColour)
      SELECT CASE strTemp
        CASE "0"
          FUNCTION = FORMAT$(%BLACK)
        CASE "1"
          FUNCTION = FORMAT$(%RED)
        CASE "2"
          FUNCTION = FORMAT$(%BLUE)
      END SELECT
      '
    CASE "ColumnCheckBox"
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnCheckBox)
      '
    CASE "ColumnDropdown"
      FUNCTION = FORMAT$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnDropDown)
      '
    CASE "ColumnDropdownSPR"
      FUNCTION = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ColumnDropDownSPR)
      '
    CASE "ResultName"
      strTemp = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
      REPLACE CHR$(0) WITH "" IN strTemp
      FUNCTION = strTemp
  END SELECT
  '
END FUNCTION
'
FUNCTION funPlaceGrid(hDlg AS DWORD,lngMLGGRID AS LONG,strSorting AS STRING,hGrid AS DWORD, _
                      strFormName AS STRING,strGridName AS STRING,lngX AS LONG, lngY AS LONG, _
                      lngWidth AS LONG, lngHeight AS LONG, sheetIDM AS LONG, _
                      strUserAccess AS STRING) AS LONG
' place a generic grid on the form
  LOCAL lngColumns AS LONG
  LOCAL lngRows AS LONG
  LOCAL aTab  AS ASCIIZ * 255
  LOCAL lngCount AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL RC AS RowColDataType
  LOCAL strDropDown AS ASCIIZ * 1024
  LOCAL lngTabCount AS LONG
  LOCAL o_TabNamelist AS STRING
  LOCAL lngColumnCount AS LONG
  LOCAL o_ColumnNameList AS STRING
  LOCAL strColumnName AS STRING
  LOCAL lngColWidth AS LONG
  LOCAL strTabName AS STRING
  LOCAL lngJustify AS LONG
  LOCAL lngColour AS LONG
  LOCAL lngColumnLock AS LONG
  LOCAL z AS LONG
  LOCAL strSQL AS STRING
  LOCAL strError AS STRING
  DIM a_strData() AS STRING
  LOCAL lngTabPos AS LONG
  LOCAL lngTabsCreated AS LONG
  '
  LOCAL lngForm AS LONG
  LOCAL lngGrid AS LONG
  LOCAL lngTab AS LONG
  ' pick up the form and grid pointers
  lngForm = funGetFormNumber(strFormName)
  lngGrid = funGetGridNumber(lngForm,strGridName)
  '
  lngRows = 500
  lngColumns = %Max_cols
  '
  CONTROL ADD "MYLITTLEGRID", hDlg, lngMLGGRID, _
          "x20/d-0/e1/r" & FORMAT$(lngRows) & strSorting & "/z1/c" & _
          FORMAT$(lngColumns) & "/a2/y3", _
          lngX, lngY, lngWidth, lngHeight, %MLG_STYLE
  CONTROL HANDLE hDlg, lngMLGGRID TO hGrid
  '
  funGridClear(hGrid)
  '
  MLG_ArrayRedim(hGrid, 1 , lngColumns, 1+10, lngColumns+2)   ' ensure dimensioned rows and columns are bigger
  ' set override slots for grey colours on name
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  '
  'SendMessage hGrid ,%MLG_CREATEFORMATOVERRIDE,%MAX_rows,lngColumns ' set up a max rows by 10 column array
  ' mirror the sheet for override
  SendMessage hGrid ,%MLG_CREATEFORMATOVERRIDE,0,0 ' set up a max rows by 10 column array
  '
  ' set cell for licence
  SendMessage hGrid,%MLG_SETCELL,0,0
  '
  SendMessage hGrid, %MLG_SETHEADERCOLOR , %LTGRAY,0
  '
  sheetIDM=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,1)
  ' get the number of tabs
  lngTabCount = funGetTabCount(lngForm, lngGrid, o_TabNamelist)

'  IF lngTabCount > 1 THEN
'    FOR lngR = 1 TO lngTabCount-1
'    ' add the worksheets
'      z=SendMessage(hGrid, %MLG_ADDSHEET, 0,0)
'      IF z=0 THEN EXIT FOR
'    NEXT lngR
'  END IF
  '
   ' display the tabs - 300 is the amount of room for the tabs - rest taken up by scroll bar
  SendMessage hGrid, %MLG_SHOWSHEETTABS,380,0
  '
  lngTabsCreated = 0
  FOR lngCount = 1 TO lngTabCount
    INCR lngTabsCreated
    '
    IF lngTabsCreated > 1 THEN
      z=SendMessage(hGrid, %MLG_ADDSHEET, 0,0)
  END IF
  NEXT lngCount
  '
  FOR lngCount = 1 TO lngTabCount
  ' for each tab to be processed
    lngTabPos = VAL(PARSE$(PARSE$(o_TabNamelist,"|",lngCount),"/",2))
    IF lngTabPos = 0 THEN ITERATE
    '
    aTab = "  " & PARSE$(PARSE$(o_TabNamelist,"|",lngCount),"/",1) & "  "
    SendMessage hGrid, %MLG_NAMESHEET , lngTabPos,VARPTR(aTab)
    SendMessage hGrid, %MLG_SELECTSHEET, lngTabPos,0
    SendMessage hGrid, %MLG_SHOWSPLITTERS,1,0
    '
    strTabName = PARSE$(PARSE$(o_TabNamelist,"|",lngCount),"/",1)
    lngTab = funGetTabNumber(lngForm,lngGrid,strTabName)
    '
    o_ColumnNameList = ""
    lngColumnCount = funGetTabColumnCount(lngForm, lngGrid , lngTab, o_ColumnNameList)
    '
    FOR lngR = 1 TO %Max_Cols
    ' for each column to be processed
      strColumnName = PARSE$(o_ColumnNameList,"|",lngR)
      IF strColumnName = "" THEN
      ' no name so hide it
        SendMessage hGrid ,%MLG_HIDECOLUMN, %MLG_HIDECOL, lngR
        ITERATE FOR
      ELSE
      ' name the column
        MLG_Put hGrid,0,lngR, PARSE$(o_ColumnNameList,"|",lngR),lngRefresh
        lngColWidth = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngR).ColumnWidth
        SendMessage hGrid, %MLG_SETCOLWIDTH,lngR,lngColWidth
      END IF
      '
      lngJustify = VAL(funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnJustify")) ' %MLG_JUST_LEFT
      '
      lngColour = VAL(funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnColour"))
      lngColumnLock = VAL(funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnLock")) ' %MLG_LOCK
      '
      IF VAL(funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnHide")) = %TRUE THEN
      ' is column to be hidden?
        SendMessage hGrid ,%MLG_HIDECOLUMN, %MLG_HIDECOL, lngR
        ITERATE FOR
      END IF
      '
      IF VAL (funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnDateTime")) = %TRUE THEN
      ' its a date
        MLG_FormatColDate hGrid,lngR,%DDMMYYYY,lngJustify, lngColour , lngColumnLock
      ELSE
      ' its text or number
        MLG_FormatColNumber hGrid,lngR,%MLG_NULL, lngJustify, lngColour , lngColumnLock
      END IF
      '
      IF VAL(funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnCheckBox")) = %TRUE THEN
      ' is this a checkbox
         MLG_FormatColCheck hGrid,lngR  ' set column to be checkbox
         ITERATE FOR
      END IF
      '
      IF VAL(funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnDropdown")) = %TRUE THEN
      ' is this a dropdown - is so get the spr to call
        IF lngColumnLock =%MLG_LOCK THEN EXIT IF
        ' handle dropdowns that are read only
        '
        strSQL = funGetProperty(lngForm, lngGrid, lngTab,lngR,"ColumnDropdownSPR")
        IF strSQL <>"" THEN
          IF ISTRUE funGetGenericData(strSQL ,BYREF a_strData(),1) THEN
            '
            IF UBOUND(a_strData) <> -1 THEN
            ' got the data
              strDropDown = ""
              FOR lngC = 1 TO UBOUND(a_strData)
                strDropDown = strDropDown & PARSE$(a_strData(lngC),"|",1) & ","
              NEXT lngC
              '
              strDropDown = TRIM$(strDropDown,",")
              IF strDropDown <>"" THEN
              ' is this a dropdown?
                'strDropDown = "|7/8," & strDropDown
                RC.CellType = %MLG_TYPE_COMBOSTATIC
                RC.List=VARPTR(strDropDown)
                SendMessage hGrid, %MLG_SETCOLFORMAT,lngR ,VARPTR(RC)  ' set the format of dropdown
              END IF
            '
            END IF
          END IF
        END IF
      END IF
    '
    NEXT lngR
    '
  NEXT lngCount


  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funGenericPopulateGridRow(strForm AS STRING, strGrid AS STRING, strTab AS STRING, lngRow AS LONG, _
                                   hGrid AS DWORD, strData AS STRING, strHeader AS STRING) AS LONG
' populate just the specified row
  LOCAL lngGridColumns AS LONG
  LOCAL strResultColumnName AS STRING
  LOCAL lngC AS LONG
  LOCAL lngGridPosition AS LONG
  LOCAL strValue AS STRING
  LOCAL lngRefresh AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngCounterLimit AS LONG
  '
  LOCAL lngForm AS LONG
  LOCAL lngGrid AS LONG
  LOCAL lngTab AS LONG
  ' get the form/grid/tab info
  lngForm = funGetFormNumber(strForm)
  lngGrid = funGetGridNumber(lngForm,strGrid)
  lngTab  = funGetTabNumber(lngForm, lngGrid,strTab)
  lngGridColumns = funGetColumnsInGrid(hGrid)
  '
  FOR lngC = 1 TO lngGridColumns
    strValue = ""
    ' first get the column name from the result
    strResultColumnName = PARSE$(strHeader,"|",lngC)
    ' now work out where to put it in the grid
    lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
    '
    IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab, lngColumn, "ColumnNote")) THEN
    ' is this a a notes field - if so put nothing in the field
      ITERATE FOR
    END IF
    '
    IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnCheckBox")) THEN
    ' is this a checkbox
      lngCounterLimit = VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnCheckBoxCounterLimit"))
      IF lngCounterLimit > 0 THEN
      ' does it has a counter limit on it?
        IF VAL(PARSE$(strData,"|",lngC)) > lngCounterLimit THEN
          strValue = "1"
        ELSE
          strValue = ""
        END IF
        '
      ELSE
        IF VAL(PARSE$(strData,"|",lngC)) = 0 THEN
          strValue = ""
        ELSE
          strValue = "1"
        END IF
      END IF
    ELSE
    ' some other data
      IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnDateTime")) THEN
      ' is column a date
        IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnSupressTime")) THEN
          strValue = LEFT$(PARSE$(strData,"|",lngC),10)
        ELSE
          strValue = PARSE$(strData,"|",lngC)
        END IF
      ELSE
        strValue = PARSE$(strData,"|",lngC)
      END IF
      '
      REPLACE "[NULL]" WITH "" IN strValue
    END IF
    '
    MLG_PUT hGrid,lngRow,lngGridPosition,strValue,lngRefresh
    '
  NEXT lngC
  '
  ' check for late formatting like user buttons
  FOR lngC = 1 TO lngGridColumns
  ' for each column
  ' get the name of this column from DB
    strResultColumnName = PARSE$(strHeader,"|",lngC)
    ' now work out where to put it in the array
    lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
     ' handle user buttons
     IF ISTRUE funIsResultUserButton(lngForm,lngGrid,lngTab,lngColumn) THEN
     ' its a user button field
       funAddUserButtonToCell(hGrid,lngRow, lngGridPosition)
     ELSE
       funRemoveUserButtonFromCell(hGrid,lngRow, lngGridPosition)
     END IF
     '
     ' check for word wrapping
     ' check justify setting
     lngColumn = funGetUdtColumnPositionFromResult(lngForm,lngGrid,lngTab, strResultColumnName)
     IF VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnJustify")) = %MLG_JUST_WORDWRAP THEN
     ' this is a word wrapped field
       SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(lngRow,lngGridPosition),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
     END IF
     '
   NEXT lngC
   ' colour bank the row
   funColourBankGridRow(hGrid, lngRow)
   '
   FOR lngC = 1 TO lngGridColumns
   ' first get the column name from the result
     strResultColumnName = PARSE$(strHeader,"|",lngC)

     ' now work out where to put it in the grid
     lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
     '
     IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab, lngColumn, "ColumnNote")) THEN
       IF VAL(PARSE$(strData,"|",lngC)) > 0 THEN
       ' there's a note
         SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngRow,lngGridPosition),1
       '
       ELSE
       ' no current note found - work out if white or green blank required
         IF (lngRow MOD 2) = 0 THEN
           SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngRow,lngGridPosition),3
         ELSE
           SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngRow,lngGridPosition),2
         END IF
       END IF
     END IF
   '
  NEXT lngC
  '
   funGridRefresh(hGrid) ' refresh the grid display
  FUNCTION = %TRUE
'
END FUNCTION
'
FUNCTION funGenericPopulateGrid(strForm AS STRING, strGrid AS STRING, strTab AS STRING,_
                                strSQL AS STRING, hGrid AS DWORD, lngDBref AS LONG, _
                                OPTIONAL lngTrimResults AS LONG, _
                                OPTIONAL strColumnName AS STRING, _
                                OPTIONAL strIncValue AS STRING, _
                                OPTIONAL lngWildCard AS LONG) AS LONG
' populate the grid based on the CDEF
  LOCAL strError AS STRING
  LOCAL lngGridColumns AS LONG
  LOCAL a_strData() AS STRING
  LOCAL a_strDataTemp() AS STRING
  LOCAL a_strDisplayGrid() AS STRING
  LOCAL lngRecordsReturned AS LONG
  LOCAL lngGridRows AS LONG
  LOCAL lngR AS LONG , lngC AS LONG
  LOCAL strResultColumnName AS STRING
  LOCAL lngGridPosition AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngCounterLimit AS LONG
  LOCAL lngUDT AS LONG
  LOCAL strValue AS STRING
  LOCAL lngTemp AS LONG
  LOCAL strCurrentTabName AS STRING
  LOCAL o_lngSheetSlot AS LONG
  LOCAL lngTabSwitch AS LONG
  '
  LOCAL lngForm AS LONG
  LOCAL lngGrid AS LONG
  LOCAL lngTab AS LONG
  ' get the form/grid/tab info
  lngForm = funGetFormNumber(strForm)
  lngGrid = funGetGridNumber(lngForm,strGrid)
  lngTab  = funGetTabNumber(lngForm, lngGrid,strTab)
  '
  ' first work out what tab we are on
  strCurrentTabName = funGetSelectedTabName(hGrid , o_lngSheetSlot)
  IF LCASE$(strCurrentTabName) <> LCASE$(strTab) THEN
  ' we are trying to populate a tab other than the one we are currently on
    lngTabSwitch = %TRUE
    SendMessage hGrid, %MLG_SELECTSHEET, lngTab,0
  END IF


  ' clear the grid tab first
  funEmptyGrid(hGrid)
  '
  lngGridColumns = funGetColumnsInGrid(hGrid)
  ERASE a_strData()
    IF ISTRUE funGetSQLResultset(strSQL, strError, a_strData(),lngDBref,1) THEN
    '
      IF UBOUND(a_strData) = -1 THEN
      ' empty result set
        REDIM a_strDisplayGrid( 1 TO 1,lngGridColumns) AS STRING
        lngRecordsReturned = 0
        lngGridRows = 1
        FOR lngC = 1 TO lngGridColumns
          a_strDisplayGrid(1,lngC)=""
          IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab, lngC, "ColumnNote")) THEN
          ' no current note found
            SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(1,lngC),2
          END IF
        NEXT lngC
        '
        funGridClear(hGrid)
        MLG_ArrayRedim(hGrid, lngGridRows , lngGridColumns , lngGridRows+10, lngGridColumns +2)   ' ensure dimensioned rows and columns are bigger
        MLG_PutEx (hGrid,a_strDisplayGrid(),4,1)
        '
        FUNCTION = %FALSE
      ELSE
        ' got some data
        ' decide to trim?
        IF ISFALSE ISMISSING(lngTrimResults) AND strColumnName <> "" AND strIncValue <> "" THEN
        ' we want to trim this data
          ' first find the named column
          LOCAL lngColumnNumber AS LONG
          LOCAL lngCount AS LONG
          '
          FOR lngR = 1 TO PARSECOUNT(a_strData(0),"|")
            IF PARSE$(a_strData(0),"|", lngR) = strColumnName THEN
              lngColumnNumber = lngR
              EXIT FOR
            END IF
          NEXT lngR
          '
          IF lngColumnNumber > 0 THEN
          ' column found
            ' prep then populate a temp array
            REDIM a_strDataTemp(UBOUND(a_strData)) AS STRING
            a_strDataTemp(0) = a_strData(0) ' save the headers
            FOR lngR = 1 TO UBOUND(a_strData)
            ' test on value of data against what is being looked for - make it case independant
              IF ISMISSING(lngWildCard) THEN
              ' looking for exact match
                IF LCASE$(PARSE$(a_strData(lngR),"|",lngColumnNumber)) = LCASE$(strIncValue) THEN
                  INCR lngCount
                  a_strDataTemp(lngCount) = a_strData(lngR)
                END IF
              ELSE
              ' its a wildcard search
                IF INSTR(LCASE$(PARSE$(a_strData(lngR),"|",lngColumnNumber)),LCASE$(strIncValue)) > 0 THEN
                  INCR lngCount
                  a_strDataTemp(lngCount) = a_strData(lngR)
                END IF
              END IF
            NEXT lngR
            ' rebuild the data array with whats left
            REDIM a_strData(lngCount) AS STRING
            a_strData(0) = a_strDataTemp(0)
            FOR lngR = 1 TO UBOUND(a_strDataTemp)
              a_strData(lngR) = a_strDataTemp(lngR)
            NEXT lngR
          ELSE
          ' no column found
            REDIM PRESERVE a_strData(0) AS STRING
          END IF
        '
        END IF
        '
        lngGridRows = UBOUND(a_strData)
        REDIM a_strDisplayGrid( 1 TO lngGridRows,lngGridColumns) AS STRING
        '
        FOR lngR = 1 TO lngGridRows
          '
          FOR lngC = 1 TO lngGridColumns
          ' first get the column name from the result
            strResultColumnName = PARSE$(a_strData(0),"|",lngC)
            ' now work out where to put it in the array
            lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
            IF lngGridPosition = 0 THEN ITERATE ' this result doesn't belong on this grid
            '
            IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab, lngColumn, "ColumnNote")) THEN
            ' is this a a notes field
              IF VAL(PARSE$(a_strData(lngR),"|",lngC)) > 0 THEN
              ' there's a note
                SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngR,lngGridPosition),1
                'a_strDisplayGrid(lngR,lngGridPosition) = "1"
              ELSE
              ' no current note found
                SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngR,lngGridPosition),2
                'a_strDisplayGrid(lngR,lngGridPosition) = "0"
              END IF
              '
              ITERATE FOR
            END IF
            '
            IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnCheckBox"))    THEN
            ' is this a checkbox
              '
              lngCounterLimit = VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnCheckBoxCounterLimit"))
              IF lngCounterLimit > 0 THEN
              ' does it has a counter limit on it?
                IF VAL(PARSE$(a_strData(lngR),"|",lngC)) > lngCounterLimit THEN
                  a_strDisplayGrid(lngR,lngGridPosition) = "1"
                ELSE
                  a_strDisplayGrid(lngR,lngGridPosition) = ""
                END IF
                '
              ELSE
                IF VAL(PARSE$(a_strData(lngR),"|",lngC)) = 0 THEN
                  a_strDisplayGrid(lngR,lngGridPosition) = ""
                ELSE
                  a_strDisplayGrid(lngR,lngGridPosition) = "1"
                END IF
              END IF
              '
            ELSE
            ' some other data
              IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnDateTime")) THEN
              ' is column a date
                IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnSupressTime")) THEN
                  a_strDisplayGrid(lngR,lngGridPosition) = LEFT$(PARSE$(a_strData(lngR),"|",lngC),10)
                ELSE
                  a_strDisplayGrid(lngR,lngGridPosition) = PARSE$(a_strData(lngR),"|",lngC)
                END IF
              ELSE
              a_strDisplayGrid(lngR,lngGridPosition) = PARSE$(a_strData(lngR),"|",lngC)
              END IF
              '
              IF ISTRUE VAL(funGetProperty(lngForm,lngGrid, lngTab,lngColumn,"ColumnCurrency")) THEN
                strValue = PARSE$(a_strData(lngR),"|",lngC)
                lngTemp = INSTR(strValue,".")
                IF lngTemp >0 THEN
                ' there is a decimal place
                  strValue = LEFT$(strValue,lngTemp+2)
                END IF
                a_strDisplayGrid(lngR,lngGridPosition) = FORMAT$(VAL(strValue),"#0.00")
              END IF
              '
              REPLACE "[NULL]" WITH "" IN a_strDisplayGrid(lngR,lngGridPosition)
              REPLACE "[ CHR$(130) ]" WITH "e" IN a_strDisplayGrid(lngR,lngGridPosition)
              REPLACE "[ CHR$(233) ]" WITH CHR$(233) IN a_strDisplayGrid(lngR,lngGridPosition)
              REPLACE "[ CHR$(0) ]" WITH "" IN a_strDisplayGrid(lngR,lngGridPosition)
              REPLACE "[ CHR$(13) ][ CHR$(10) ]" WITH " " IN a_strDisplayGrid(lngR,lngGridPosition)
            END IF
            '
          NEXT lngC
        NEXT lngR
        funGridClear(hGrid)
        '
        MLG_ArrayRedim(hGrid, lngGridRows , lngGridColumns , lngGridRows+10, lngGridColumns +2)   ' ensure dimensioned rows and columns are bigger
        MLG_PutEx (hGrid,a_strDisplayGrid(),4,1)
        '
        ' check for late formatting like user buttons
        FOR lngC = 1 TO lngGridColumns
        ' for each column
          strResultColumnName = PARSE$(a_strData(0),"|",lngC)
          ' now work out where to put it in the array
          lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
          IF lngGridPosition = 0 THEN ITERATE
          '
          ' handle column  notes
          IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab, lngColumn, "ColumnNote")) THEN
          ' is this a a notes field
            FOR lngR = 1 TO lngGridRows
              IF VAL(PARSE$(a_strData(lngR),"|",lngC)) > 0 THEN
              ' there's a note
                SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngR,lngGridPosition),1
                '
              ELSE
              ' no current note found - work out if white or green blank required
                IF (lngR MOD 2) = 0 THEN
                  SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngR,lngGridPosition),3
                ELSE
                  SendMessage hGrid ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(lngR,lngGridPosition),2
                END IF
              END IF
            NEXT lngR
            '
            ITERATE FOR
          END IF
          '
          ' handle user buttons
          IF ISTRUE funIsResultUserButton(lngForm,lngGrid,lngTab,lngColumn) THEN
          ' its a user button field
            FOR lngR = 1 TO lngGridRows
              funAddUserButtonToCell(hGrid,lngR, lngGridPosition)
            NEXT lngR
          ELSE
            FOR lngR = 1 TO lngGridRows
              funRemoveUserButtonFromCell(hGrid,lngR, lngGridPosition)
            NEXT lngR
          '
          END IF
          '
          ' check for word wrapping
          ' check justify setting
          IF VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnJustify")) = %MLG_JUST_WORDWRAP THEN
          ' this is a word wrapped field
            FOR lngR = 1 TO lngGridRows
              SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(lngR,lngGridPosition),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
            NEXT lngR
          END IF
          '
        NEXT lngC
        ' colour bank the rows
        funColourBankGridRows(hGrid)
        funGridRefresh(hGrid) ' refresh the grid display
        FUNCTION = %TRUE
      END IF
      '
    ELSE
      REDIM a_strDisplayGrid( 1 TO 1,lngGridColumns) AS STRING
      lngGridRows = 1
      FOR lngR = 1 TO lngGridColumns
        a_strDisplayGrid(1,lngR)=""
      NEXT lngR
      '
      funGridClear(hGrid)
      '
      MLG_ArrayRedim(hGrid, lngGridRows , lngGridColumns , lngGridRows+10, lngGridColumns +2)   ' ensure dimensioned rows and columns are bigger
      MLG_PutEx (hGrid,a_strDisplayGrid(),4,1)
      '
      ' colour bank the rows
      funColourBankGridRows(hGrid)
      funGridRefresh(hGrid) ' refresh the grid display
      FUNCTION = %FALSE
    END IF
    '
    IF ISTRUE lngTabSwitch THEN
    ' switch back to original tab?
      SendMessage hGrid, %MLG_SELECTSHEET, o_lngSheetSlot,0
      'funGridRefresh(hGrid) ' refresh the grid display
    END IF
    '
END FUNCTION
'
FUNCTION funDoLateFormattingOnRow(hGrid AS DWORD, lngRow AS LONG, strHeader AS STRING, _
                                  lngForm AS LONG,lngGrid AS LONG,lngTab AS LONG) AS LONG
' perform the late formating on the row
  LOCAL lngC AS LONG
  LOCAL lngColumn AS LONG
  LOCAL strResultColumnName AS STRING
  LOCAL lngGridPosition AS LONG
  LOCAL lngGridColumns AS LONG
  '
  lngGridColumns = funGetColumnsInGrid(hGrid)
  '
  FOR lngC = 1 TO lngGridColumns
  ' for each column where strHeader is a | delimted header list
    strResultColumnName = PARSE$(strHeader,"|",lngC)
    ' now work out where to put it in the array
    lngGridPosition = funGetGridPosition(lngForm,lngGrid,lngTab,strResultColumnName, lngColumn)
    IF lngGridPosition = 0 THEN ITERATE
    ' handle user buttons
    IF ISTRUE funIsResultUserButton(lngForm,lngGrid,lngTab,lngColumn) THEN
    ' its a user button field
      funAddUserButtonToCell(hGrid,lngRow, lngGridPosition)
    ELSE
      funRemoveUserButtonFromCell(hGrid,lngRow, lngGridPosition)
    END IF
    '
    ' check for word wrapping
    ' check justify setting
    IF VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumn,"ColumnJustify")) = %MLG_JUST_WORDWRAP THEN
    ' this is a word wrapped field
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(lngRow,lngGridPosition),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
    END IF
    '
  NEXT lngC

END FUNCTION

'FUNCTION funSetValueOfResultColumn(lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG, hGrid AS DWORD, _
'                                   lngRow AS LONG, strResultName AS STRING, strValue AS STRING) AS LONG
'' set the value contained in a Row/Cell
'  LOCAL lngColumn AS LONG
'  LOCAL strUdtResultName AS STRING
'  LOCAL lngGridPos AS LONG
'  '
'  FOR lngColumn = 1 TO %Max_cols
'    strUdtResultName = TRIM$(udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).ResultName)
'    IF strUdtResultName = strResultName THEN
'      lngGridPos = udtApp.AppForm(lngForm).FormGrid(lngGrid).GridTab(lngTab).TabColumn(lngColumn).GridPos
'      '
'      MLG_PUT(hGrid,lngRow,lngGridPos, strValue,0)
'      FUNCTION = %TRUE
'      EXIT FUNCTION
'    END IF
'  NEXT lngColumn
'  '
'  ' if we get this far we couldnt find the column to update
'  FUNCTION = %FALSE
'END FUNCTION
