' PB_Excel_functions.inc

GLOBAL g_vTrue   AS VARIANT
GLOBAL g_vFalse  AS VARIANT
GLOBAL g_eErr    AS LONG
'
' index to library
' funAddExcelWorkBook - add a new Excel workbook
' funAddRowToExcel - add a new row to worksheet
' funCloseExcelApp - close down access to the Excel application
' funDeleteExcelRows  - delete rows from a worksheet
' funFindFirstExcelBlankRow - find the first blank row in the worksheet
' funGetCurrentWorksheetName - return the name of the currently active worksheet
' funGetWorksheetCount - return the number of worksheets in this workbook
' funInsertExcelColumn - insert a new blank column in worksheet
' funInsertExcelRow - insert a new blank row in worksheet
' funOpenExcelApp - open the Excel application in the background
' funOpenExcelWorkBook - open an Excel workbook
' funOpenExcelWorksheet - open an Excel worksheet
' funSaveExcelWorkSheet - save a specified excel worksheet to disk in specified format
' funSetExcelVisibility - make excel app visible or not
'
FUNCTION funInsertExcelRow(oExcelWorkSheet AS Int__Worksheet, _
                           strRange AS STRING, _
                           strError AS STRING) AS LONG
' insert a new row into the worksheet
  LOCAL vRange AS VARIANT
  LOCAL eErr AS LONG
  '
  vRange = strRange
  '
  OBJECT CALL oExcelWorkSheet.Range(vRange).EntireRow.Insert
  '
  '
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    strError = ("Unable to insert row - " & strRange)
    FUNCTION = %FALSE
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funInsertExcelColumn(oExcelWorkSheet AS Int__Worksheet, _
                              strRange AS STRING, _
                              strError AS STRING) AS LONG
' insert a new column into the worksheet
  LOCAL vRange AS VARIANT
  LOCAL eErr AS LONG
  '
  vRange = strRange
  '
  OBJECT CALL oExcelWorkSheet.Range(vRange).EntireColumn.Insert
  '
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    strError = ("Unable to insert column - " & strRange)
    FUNCTION = %FALSE
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funDeleteExcelRows(oExcelWorkSheet AS Int__Worksheet, _
                            strRange AS STRING, _
                            strError AS STRING) AS LONG
' delete the specified rows from a worksheet
  LOCAL vRange AS VARIANT
  LOCAL eErr AS LONG
  '
  vRange = strRange
  '
  OBJECT CALL oExcelWorkSheet.Range(vRange).EntireRow.Delete
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    strError = ("Unable to delete range - " & strRange)
    FUNCTION = %FALSE
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funAddRowToExcel(oExcelWorkSheet AS Int__Worksheet, _
                          lngRow AS LONG, _
                          strData AS STRING, _
                          strError AS STRING) AS LONG
' add a data row to worksheet
  LOCAL vCellData AS VARIANT
  LOCAL lngColumn AS LONG
  '
  FOR lngColumn = 1 TO PARSECOUNT(strData,"|")
  ' for each column insert data into spreadsheet
    vCellData = PARSE$(strData,"|",lngColumn)
    '
    OBJECT LET oExcelWorkSheet.Cells(lngRow,lngColumn).Value = vCellData
    '
    IF OBJRESULT OR ERR THEN
      strError = OBJRESULT$
      EXIT FUNCTION
    END IF
    '
  NEXT lngColumn
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funFindFirstExcelBlankRow(oExcelWorkSheet AS Int__Worksheet, _
                                   lngColumn AS LONG, _
                                   lngMaxRows AS LONG) AS LONG
' return the first row number that is blank in specified column
  LOCAL vValue AS VARIANT
  LOCAL lngRow AS LONG
  LOCAL lngFound AS LONG
  '
  lngRow = 0
  DO
    INCR lngRow
    '
    OBJECT GET oExcelWorkSheet.Cells(lngRow,lngColumn).Value TO vValue
    '
    IF VARIANT$(vValue) = "" THEN
      lngFound = %TRUE
      EXIT LOOP
    END IF
    '
  LOOP UNTIL lngRow = lngMaxRows
  '
  IF ISTRUE lngFound THEN
    FUNCTION = lngRow
  ELSE
    FUNCTION = 0
  END IF
  '
END FUNCTION
'
FUNCTION funGetWorksheetCount(oExcelWorkbook AS Int__Workbook) AS LONG
' return the total number of worksheets in this workbook
  LOCAL vSheets AS VARIANT
  '
  OBJECT GET oExcelWorkBook.WorkSheets.Count TO vSheets
  '
  FUNCTION = VARIANT#(vSheets)
  '
END FUNCTION
'
FUNCTION funGetCurrentWorksheetName(oExcelWorkSheet AS Int__Worksheet) AS STRING
' return the name of the currently active worksheet
  LOCAL vName AS VARIANT
  '
  OBJECT GET oExcelWorkSheet.Name TO vName
  FUNCTION = VARIANT$(vName)
  '
END FUNCTION
'
FUNCTION funAddExcelWorkbook(oExcelApp AS Int__Application, _
                             oExcelWorkbook AS Int__Workbook, _
                             strError AS STRING) AS LONG
' add a new workbook to Excel
  OBJECT CALL oExcelApp.WorkBooks.Add TO oExcelWorkbook
  IF OBJRESULT OR ERR THEN
    strError = "New workbook could not be added " &  OBJRESULT$
  ELSE
    FUNCTION = %TRUE
  END IF
'
END FUNCTION
'
FUNCTION funSetExcelVisibility(oExcelApp AS Int__Application, _
                               lngVisible AS LONG) AS LONG
' make excel app visible or not : lngVisible = 1 for visibility
  LOCAL vBool AS VARIANT
  LET vBool = lngVisible
  OBJECT LET oExcelApp.Visible = vBool
  '
END FUNCTION

FUNCTION funSaveExcelWorkSheet(oExcelWorkSheet AS Int__Worksheet, _
                               strFilename AS STRING, _
                               lngFileFormat AS LONG, _
                               strError AS STRING) AS LONG
' Save current excel worksheet
  LOCAL vOutFile AS VARIANT
  LOCAL vFileformat AS VARIANT
  LOCAL eErr AS LONG
  '
  LET vOutFile = strFilename
  ' save as format specified
  LET vFileformat = lngFileFormat
  '
  ' save the spreadsheet
  OBJECT CALL oExcelWorkSheet.SaveAs(Filename=vOutFile, _
                                     FileFormat=vFileformat)
                                     '
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    strError = "Excel could not save the workbook: " &  OBJRESULT$(eErr)
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funOpenExcelWorksheet(oExcelApp AS Int__Application, _
                               oExcelWorkbook AS Int__Workbook, _
                               oExcelWorkSheet AS Int__Worksheet, _
                               lngSheet AS LONG, _
                               strError AS STRING) AS LONG
' open the excel worksheet by sheet number
  LOCAL vExSheet AS VARIANT
  LOCAL eErr AS LONG
  '
  vExSheet = lngSheet ' set the sheet to work on
  ' open and activate the worksheet
  OBJECT GET oExcelWorkBook.WorkSheets.Item(vExSheet) _
             TO oExcelWorkSheet
  OBJECT CALL oExcelWorkSheet.Activate
  '
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    strError = "Unable to set worksheet: " & OBJRESULT$
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funOpenExcelWorkBook(oExcelApp AS Int__Application, _
                              oExcelWorkbook AS Int__Workbook, _
                              strFile AS STRING, _
                              strError AS STRING) AS LONG
' open the excel workbook
  LOCAL vInFile AS VARIANT
  LOCAL eErr AS LONG
  '
  LET vInFile = strFile ' set location of excel file
  ' and open the Workbook
  OBJECT CALL oExcelApp.WorkBooks.Open(Filename = vInFile, _
                    UpdateLinks=g_vFalse) TO oExcelWorkbook
                    '
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    strError = "Excel could not open the workbook: " & OBJRESULT$
  ELSE
  ' work book opened ok
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funCloseExcelApp(oExcelApp AS Int__Application, _
                          oExcelWorkbook AS Int__Workbook, _
                          oExcelWorkSheet AS Int__Worksheet) AS LONG
' close down Excel
'
  OBJECT CALL oExcelApp.ActiveWindow.Close(SaveChanges=g_vFalse)
  OBJECT CALL oExcelApp.Quit
  '
  oExcelApp       = NOTHING
  oExcelWorkbook  = NOTHING
  oExcelWorkSheet = NOTHING
  '
END FUNCTION
'
FUNCTION funOpenExcelApp(oExcelApp AS Int__Application, _
                         strError AS STRING) AS LONG
  ' Open an instance of EXCEL
  oExcelApp = ANYCOM $PROGID_Excel_Application
  '
  g_vTrue  = 1  ' set the constants
  g_vFalse = 0

  ' Could EXCEL be opened? If not, terminate this app
  IF ISFALSE ISOBJECT(oExcelApp) OR ERR THEN
    strError = "Excel could not be opened. " & OBJRESULT$
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
