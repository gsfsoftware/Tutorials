#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
'
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "PB_Excel.inc"           ' generated by COM browser
#INCLUDE "PB_Excel_functions.inc" ' helper functions
'
' define the name of the excel spreadsheet to open
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
FUNCTION funProcessExcelSpreadsheet(strFileName AS STRING) AS LONG
' load the excel spreadsheet
  ' define the objects we will be using
  LOCAL oExcelApp       AS Int__Application
  LOCAL oExcelWorkbook  AS Int__Workbook
  LOCAL oExcelWorkSheet AS Int__Worksheet
  '
  LOCAL strError AS STRING
  LOCAL lngSheet AS LONG
  LOCAL lngFileFormat AS LONG
  '
  IF ISTRUE funOpenExcelApp(oExcelApp, strError) THEN
    funLog("Excel opened successfully")
    '
    IF ISTRUE funOpenExcelWorkbook(oExcelApp,oExcelWorkbook, _
                                   strFileName,strError) THEN
      funLog("Workbook opened ok")
      '
      ' count how many worksheets are in this workbook
      funLog("Sheet Count = " & _
             FORMAT$(funGetWorksheetCount(oExcelWorkbook)))
      '
      lngSheet = 1  ' set to first sheet
      '
      IF ISTRUE funOpenExcelWorksheet(oExcelApp,oExcelWorkbook, _
                                      oExcelWorkSheet,lngSheet, _
                                      strError) THEN
                                      '
        ' worksheet loaded ok
        ' get the name of this worksheet
        funLog("Worksheet Name = " & _
               funGetCurrentWorksheetName(oExcelWorkSheet))
               '
        ' define the name of the output file
        strFilename = EXE.PATH$ & "Output.csv"
        '
        TRY
          KILL strFileName
        CATCH
        FINALLY
        END TRY
        '
        ' specify CSV windows file format
        lngFileFormat = %XlFileFormat.xlCSVWindows
        '
        IF ISTRUE funSaveExcelWorkSheet(oExcelWorkSheet, _
                                        strFilename, _
                                        lngFileFormat, _
                                        strError) THEN
          funLog("Worksheet saved successfully")
        ELSE
        ' unable to save
          funLog("unable to save Worksheet " & strError)
        END IF
        '
      ELSE
      ' worksheet not loaded
        funLog("unable to load worksheet " & strError)
      END IF
      '
    ELSE
      funLog("unable to open workbook " & strError)
    END IF
    '
    funCloseExcelApp(oExcelApp,oExcelWorkbook,oExcelWorkSheet)
    '
  ELSE
    funLog("Unable to open Excel " & strError)
  END IF
  '
END FUNCTION