#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
'#INCLUDE "win32api.inc"
#IF NOT %DEF(%FALSE)
  %FALSE = 0
#ENDIF
'
#IF NOT %DEF(%TRUE)
  %TRUE = 1
#ENDIF
'
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "PB_Excel.inc"
'
$ExcelFile = "Test_spreadsheet.xlsx"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Excel Spreadsheets",0,0,40,120)
  '
  funLog("Excel Spreadsheets")
  '
  funProcessExcelSpreadsheet(EXE.PATH$ & $ExcelFile)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funProcessExcelSpreadsheet(strFile AS STRING) AS LONG
' load the excel spreadsheet
  ' define the objects we will be using
  LOCAL oExcelApp       AS Int__Application
  LOCAL oExcelWorkbook  AS Int__Workbook
  LOCAL oExcelWorkSheet AS Int__Worksheet
  '
  LOCAL vInFile AS VARIANT
  LOCAL vTrue   AS VARIANT
  LOCAL vFalse  AS VARIANT
  LOCAL eErr    AS LONG
  LOCAL vExSheet    AS VARIANT
  '
  LOCAL vOutFile    AS VARIANT
  LOCAL vFileformat AS VARIANT
  '
  LET vFalse = 0
  LET vTrue = 1
  '
  ' Open an instance of EXCEL
  oExcelApp = ANYCOM $PROGID_Excel_Application
  '
  ' Could EXCEL be opened? If not, terminate this app
  IF ISFALSE ISOBJECT(oExcelApp) OR ERR THEN
    funLog ("Excel could not be opened.")
    EXIT FUNCTION
  ELSE
    funLog("Opened Excel successfully")
  END IF
  '
  LET vInFile = strFile ' set location of excel file
  ' and open the Workbook
  OBJECT CALL oExcelApp.WorkBooks.Open(Filename = vInFile, _
                    UpdateLinks=vFalse) TO oExcelWorkbook
                    '
  eErr = ERR
  IF OBJRESULT OR eErr THEN
    funLog("Excel could not open the workbook: " )
  ELSE
  ' work book opened ok
    funLog("Workbook opened ok")
    '
    vExSheet = 1 ' set the sheet to work on
    ' open and activate the worksheet
    OBJECT GET oExcelWorkBook.WorkSheets.Item(vExSheet) _
               TO oExcelWorkSheet
    OBJECT CALL oExcelWorkSheet.Activate
    '
    eErr = ERR
    IF OBJRESULT OR eErr THEN
      funLog("Unable to set worksheet: " & OBJRESULT$)
    ELSE
      funLog("Worksheet set ok")
      '
      ' Save the XLS document to disk
      'LET vOutFile = EXE.PATH$ & "Output.txt"
      ' save as tab delimited
      'LET vFileformat = %XlFileFormat.xlTextWindows
      '
      LET vOutFile = EXE.PATH$ & "Output.csv"
      ' save as CSV delimited
      LET vFileformat = %XlFileFormat.xlCSVWindows
      '
      ' save the spreadsheet
      OBJECT CALL oExcelWorkSheet.SaveAs(Filename=vOutFile, _
                                    FileFormat=vFileformat)
                                    '
      eErr = ERR
      IF OBJRESULT OR eErr THEN
        funLog ("Excel could not save the workbook: " &  OBJRESULT$(eErr) )
      ELSE
        funLog ("Excel saved successfully")
        FUNCTION = %TRUE
      END IF
      '
    END IF
    '
  END IF
  '
  ' close down excel
  OBJECT CALL oExcelApp.ActiveWindow.Close(SaveChanges=vFalse)
  OBJECT CALL oExcelApp.Quit
  '
  oExcelApp       = NOTHING
  oExcelWorkbook  = NOTHING
  oExcelWorkSheet = NOTHING
'
END FUNCTION
