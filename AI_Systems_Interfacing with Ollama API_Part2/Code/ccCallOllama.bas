#COMPILE EXE
#DIM ALL
'
#INCLUDE "Win32api.inc"
'
FUNCTION PBMAIN () AS LONG
 ' start processing
  CON.STDOUT "Processing"
  ' call the curl app
  'funCallCurl()
  '
  ' call Command line Ollama
  'funCallOllama()
  '
  ' call Command line with input
  LOCAL strInputFile AS STRING
  strInputFile = EXE.PATH$ & "Document.txt"
  '
  IF ISTRUE funCallOllama_withInput(strInputFile) THEN
    CON.STDOUT "File processed"
  ELSE
    CON.STDOUT "Input file does not exist"
  END IF
  '
  ' finished
  CON.STDOUT "Finishing processing"
  SLEEP 3000

END FUNCTION
'
FUNCTION funCallOllama_withInput(strInputFile AS STRING) AS LONG
' call Ollama on the command line an give it an input
  LOCAL strCMD AS STRING         ' holds command line string
  LOCAL strOllamaBatch AS STRING ' batch file to run
  LOCAL strModel AS STRING       ' name of model to be used
  LOCAL strPrompt AS STRING      ' prompt to be used
  LOCAL strResponse AS STRING    ' file for output
  '
  IF ISFALSE ISFILE(strInputFile) THEN
  ' ensure input file exists
    EXIT FUNCTION
  END IF
  '
  strModel = "gpt-oss:120b"
  strPrompt     = "Please summarise this document and provide "  & _
                  "output in HTML format"
  strResponse = EXE.PATH$ & "DocumentSummary.html"
  strOllamaBatch = EXE.PATH$ & "Ollama_Batch.bat
  '
  strCMD = "ollama run " & strModel & " " & _
           $DQ & strPrompt & $DQ & _
           " < " & $DQ & strInputFile & $DQ & _
           " >>" & $DQ & strResponse & $DQ
           '
  TRY
    KILL strOllamaBatch
  CATCH
  FINALLY
  END TRY
  '
  TRY
    KILL strResponse
  CATCH
  FINALLY
  END TRY
  '
  funAppendToFile(strOllamaBatch,strCMD)
  funExecCmd(strOllamaBatch & "")
  '
END FUNCTION
'
FUNCTION funCallOllama() AS LONG
' call Ollama on the command line
  LOCAL strCMD AS STRING         ' holds command line string
  LOCAL strOllamaBatch AS STRING ' batch file to run
  LOCAL strModel AS STRING       ' name of model to be used
  LOCAL strPrompt AS STRING      ' prompt to be used
  LOCAL strResponse AS STRING    ' file for output
  '
  strModel = "gpt-oss:120b"
  strPrompt = "Tell me a joke about cats"
  strResponse = EXE.PATH$ & "Ollama_Response.txt"
  strOllamaBatch = EXE.PATH$ & "Ollama_Batch.bat
  '
  strCMD = "ollama run " & strModel & " " & _
           $DQ & strPrompt & $DQ & _
           " >>" & $DQ & strResponse & $DQ
           '
  TRY
    KILL strOllamaBatch
  CATCH
  FINALLY
  END TRY
  '
  TRY
    KILL strResponse
  CATCH
  FINALLY
  END TRY
  '
  funAppendToFile(strOllamaBatch,strCMD)
  funExecCmd(strOllamaBatch & "")
  '
END FUNCTION
'
FUNCTION funCallCurl() AS LONG
' call Ollama via CURL
'
  LOCAL strCMD AS STRING      ' holds command line string
  LOCAL strModel AS STRING    ' name of model to be used
  LOCAL strPrompt AS STRING   ' prompt to be used
  LOCAL strStream AS STRING   ' true or false to stream output
  LOCAL strURL AS STRING      ' url for Ollama
  LOCAL strOutput AS STRING   ' path/name of output file
  '
  strURL    = "http://localhost:11434/api/generate"
  strModel  = "gpt-oss:120b"
  strPrompt = "Tell me a joke about cats"
  strStream = "true"
  strOutput = "output.txt"
  '
  strCMD = "curl " & $DQ & strURL & $DQ & _
           " --header " & $DQ & "Content-Type: application/json" & $DQ & _
           " -d " & $DQ & _
           "{\" & $DQ & "model\" & $DQ & ":\" & _
           $DQ & strModel & "\" & $DQ & "," & _
           "\" & $DQ & "prompt\" & $DQ & ":\" & _
           $DQ & strPrompt & "\" & $DQ & "}" & $DQ & _
           " \ --output " & $DQ & strOutput & $DQ
  funAppendToFile("command.txt",strCMD)
  '
  funExecCmd(strCMD & "")
  '
END FUNCTION
'
FUNCTION funExecCmd(cmdLine1 AS ASCIIZ, OPTIONAL BYVAL lngConsole AS LONG) AS LONG
  DIM rcProcess AS Process_Information
  DIM rcStart AS startupInfo
  DIM Retc AS LONG
  '
  DIM lngWindow AS LONG
  '
  IF lngConsole = 0 OR lngConsole = %CREATE_NO_WINDOW THEN
    lngWindow = %CREATE_NO_WINDOW
  ELSE
    lngWindow = %CREATE_NEW_CONSOLE
  END IF
  '
  rcStart.cb = LEN(rcStart)
  '
  RetC = CreateProcess(BYVAL %NULL, CmdLine1, BYVAL %NULL, BYVAL %NULL, 1&, lngWindow OR _
                       %NORMAL_PRIORITY_CLASS, _
                       BYVAL %NULL, BYVAL %NULL, rcStart, rcProcess)
  RetC = %WAIT_TIMEOUT
  DO WHILE RetC = %WAIT_TIMEOUT
    RetC = WaitForSingleObject(rcProcess.hProcess,-1)
    SLEEP 50
  LOOP
  CALL GetExitCodeProcess(rcProcess.hProcess, RetC)
  CALL CloseHandle(rcProcess.hThread)
  CALL CloseHandle(rcProcess.hProcess)
  '
END FUNCTION
'
FUNCTION funAppendToFile(strFilePathToAddTo AS STRING, _
                         strData AS STRING) AS LONG
' append strData to the file if it exists or create a new one if it doesn't
  DIM intFile AS INTEGER
  DIM strError AS STRING
  '
  intFile = FREEFILE
  TRY
   IF ISTRUE ISFILE(strFilePathToAddTo) THEN
      OPEN strFilePathToAddTo FOR APPEND LOCK SHARED AS #intFile
    ELSE
      OPEN strFilePathToAddTo FOR OUTPUT AS #intFile
    END IF
    '
    PRINT #intFile, strData
    '
    FUNCTION = %TRUE
  CATCH
    strError = ERROR$   ' trap error for debug purposes
    FUNCTION = %FALSE
  FINALLY
    CLOSE #intfile
  END TRY
  '
END FUNCTION
