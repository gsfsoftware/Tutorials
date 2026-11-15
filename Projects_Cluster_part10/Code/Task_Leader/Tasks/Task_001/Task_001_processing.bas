#COMPILE EXE
#DIM ALL
' Task 001 processing task
#INCLUDE "Win32api.inc"
'
#INCLUDE "PB_FileHandlingRoutines.inc"  ' file handling library
#INCLUDE "PB_Txt_ConfigFile.inc"        ' load the config file library
#INCLUDE "PB_CommandLine.inc"           ' command line library

'
FUNCTION PBMAIN () AS LONG
  LOCAL strCommand AS STRING      ' command line parameters
  LOCAL strConfigFile AS STRING   ' config file name
  LOCAL strInputFile AS STRING    ' name of the input file
  LOCAL strOutput AS STRING       ' where output is to go
  LOCAL lngStartRow AS LONG       ' row to start processing at
  LOCAL lngRowsToProcess AS LONG  ' number of rows to process
  '
  strCommand = COMMAND$
   ' get the config file name
  strConfigFile = funReturnNamedParameterEXP("/Config#", _
                                             strCommand)
  lngStartRow = VAL(funReturnNamedParameterEXP("/Start#", _
                                             strCommand))
  lngRowsToProcess = VAL(funReturnNamedParameterEXP("/Rows#", _
                                             strCommand))
   '
  IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
  ' read data in and process data
    strInputFile = funTxtCfg_GetValue("Input")
    strOutput =  funTxtCfg_GetValue("Output")
    '
    IF ISTRUE funProcess(strInputFile,strOutput, _
                         lngStartRow,lngRowsToProcess) THEN
    ELSE
    END IF
    '
  END IF
  '
END FUNCTION
'
FUNCTION funProcess(strInputFile AS STRING, _
                    strOutput AS STRING, _
                    lngStartRow AS LONG, _
                    lngRowsToProcess AS LONG) AS LONG
' process the section of the file
  LOCAL strOutputFile AS STRING    ' name of the output results file
  LOCAL lngEndRow AS LONG          ' last row to process
  LOCAL lngRow AS LONG             ' Row being processed
  LOCAL lngInFile AS LONG          ' input file handle
  LOCAL lngOutFile AS LONG         ' output file handle
  LOCAL strInData AS STRING        ' contents of input data row
  LOCAL strOutData AS STRING       ' contents of output data row
  '
  ' work out the output file name
  strOutputFile = EXE.PATH$ & strOutput & "\" & _
                  "R" & RIGHT$("00000000" & FORMAT$(lngStartRow),8) & _
                  ".csv"
  '
  lngEndRow = lngStartRow + lngRowsToProcess -1
  '
  TRY
    lngInFile = FREEFILE
    ' open the file for read only access
    OPEN strInputFile FOR INPUT ACCESS READ LOCK WRITE AS #lngInFile

    ' open the output file
    lngOutFile = FREEFILE
    OPEN strOutputFile FOR OUTPUT AS #lngOutFile
    '
    WHILE lngRow < lngEndRow
      INCR lngRow
      '
      ' read a data line
      LINE INPUT #lngInFile,strInData
      '
      IF lngRow < lngStartRow THEN ITERATE
      '
      ' get the output data
      strOutData = funProcessData(strInData, lngRow)
      ' print it to the file
      PRINT #lngOutFile, strOutData
      '
    WEND
    '
    FUNCTION = %TRUE
    '
  CATCH
  ' error occurred
    FUNCTION = %FALSE
  '
  FINALLY
    CLOSE #lngInFile
    CLOSE #lngOutFile
  END TRY
  '
END FUNCTION
 '
FUNCTION funProcessData(strInData AS STRING, _
                        lngRow AS LONG) AS STRING
' take the input data and add the output data to it
' for each row
  LOCAL strOutput AS STRING ' output string
  LOCAL lngX , lngY, lngZ AS LONG  ' co-ordinates
  LOCAL sngDistance AS SINGLE
  '
  IF lngRow = 1 THEN
  ' handle first row
    strOutput = strInData & "," & $DQ & _
                "Distance" & $QCQ & _
                "Row" & $DQ
  '
  ELSE
  ' handle all other rows
    lngX = VAL(PARSE$(strInData,"",1))
    lngY = VAL(PARSE$(strInData,"",2))
    lngZ = VAL(PARSE$(strInData,"",3))
    '
    ' work out distance to 0,0,0
    sngDistance = SQR(lngX^2+lngY^2+lngZ^2)
    '
    strOutput = strInData & "," & $DQ & _
                FORMAT$(sngDistance) & $QCQ & _
                FORMAT$(lngRow) & $DQ
                '
  END IF
  '
  FUNCTION = strOutput
  '
END FUNCTION
