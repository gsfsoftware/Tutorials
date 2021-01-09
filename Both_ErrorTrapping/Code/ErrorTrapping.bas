#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Code Templates",0,0,40,120)
  '
  funLog("Code Templates")
  '
  LOCAL strFile AS STRING
  '
  strFile = EXE.PATH$ & "Myfile2.txt"
  '
  IF ISTRUE ISFILE(strFile) THEN
    funReadFile3(strFile)
  ELSE
    funLog("File does not exist")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funReadFile(strFile AS STRING) AS LONG
' read the file
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  '
  lngFile = FREEFILE
  '
  OPEN strFile FOR INPUT AS #lngFile
    LINE INPUT #lngFile , strData
  CLOSE #lngFile
  '
  funLog("We got here ->" & ERROR$)
'
END FUNCTION
'
FUNCTION funReadFile2(strFile AS STRING) AS LONG
' read the file
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  '
  lngFile = FREEFILE
  '
  TRY
   OPEN strFile FOR INPUT AS #lngFile
   LINE INPUT #lngFile , strData
  CATCH
    funLog("We've had an error -> " & ERROR$)
  FINALLY
    CLOSE #lngFile
  END TRY
  '
  funLog("We got here ->" & ERROR$)
'
END FUNCTION
'
FUNCTION funReadFile3(strFile AS STRING) AS LONG
' read the file
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  '
  lngFile = FREEFILE
  '
  TRY
   OPEN strFile FOR INPUT AS #lngFile
   TRY
     LINE INPUT #lngFile , strData
   CATCH
     funlog("Unable to read data ->" & ERROR$)
   END TRY
   '
  CATCH
    funLog("We've had an error -> " & ERROR$)
  FINALLY
    CLOSE #lngFile
  END TRY
  '
  funLog("We got here ->" & ERROR$)
'
END FUNCTION
