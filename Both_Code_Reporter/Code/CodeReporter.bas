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
' Use the DLL to convert code to HTML
DECLARE FUNCTION BasToSyntaxColHtml LIB "WebCoder.dll" _
          ALIAS "bastosyntaxcolhtml" (BYVAL strText AS STRING) AS STRING
'
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Code Reporter",0,0,40,120)
  '
  funLog("Code Reporter")
  '
  LOCAL lngFile AS LONG
  LOCAL strOutputFolder AS STRING
  strOutputFolder = EXE.PATH$ & "HTML\"
  DIM a_strFiles(1 TO 4) AS STRING
  '
  ARRAY ASSIGN a_strFiles() = EXE.PATH$ & EXE.NAME$ & ".bas" ,_
                              "D:\Youtube\PowerBasic\3rdParty_MLG_Lite_part4\Code\MLG_Lite.bas", _
                              "D:\Youtube\PowerBasic\Projects_CodeLibrary_part2\Code\MLG_CodeLibrary.bas", _
                              "D:\Youtube\PowerBasic\Projects_CodeLibrary_part2\Code\MLG.inc"
  '
  FOR lngFile = 1 TO UBOUND(a_strFiles)
    IF ISTRUE CreateHTMLDescriptions(a_strFiles(lngFile), _
                                     strOutputFolder) THEN
      funLog("html file " & FORMAT$(lngFile) & " created")
    ELSE
      funLog("unable to create html file " & FORMAT$(lngFile))
    END IF
  NEXT lngFile
  '
  funWait()
  '
END FUNCTION
'
FUNCTION CreateHTMLDescriptions(strCodeFile AS STRING, _
                                strOutputFolder AS STRING) AS LONG
' export the file to HTML format
  LOCAL strHTML AS STRING
  LOCAL strHeader AS STRING
  LOCAL strFileName AS STRING
  LOCAL strOutFile AS STRING
  LOCAL strFileContent AS STRING
  '
  ' does code file actually exist?
  IF ISFALSE ISFILE(strCodeFile) THEN EXIT FUNCTION
  '
  strFilename = PARSE$(strCodeFile,"\",-1)
  '
  strFileContent = TRIM$(funBinaryFileAsString(strCodeFile))
  '
  ' does code file have content?
  IF strFileContent = "" THEN EXIT FUNCTION
  '
  strHeader = "' " & strFilename & $CRLF & _
                     strFileContent
  '
  strHTML = BasToSyntaxColHtml(strHeader)
  '
  strOutFile = strFilename
  REPLACE "." WITH "_" IN strOutfile
  strOutFile = strOutputFolder & strOutFile & ".html"
  FUNCTION = funSaveStringAsFile(strOutFile, strHTML)
  '
END FUNCTION
