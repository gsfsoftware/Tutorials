#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' n.b. this application uses the José Roca API libraries
' available from
' for latest version see link below
' http://www.jose.it-berater.org/smfforum/index.php?topic=5061.0
'
' https://breakingbadapi.com/documentation

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "httprequest.inc"
#INCLUDE "ole2utils.inc"
'
%HTTPREQUEST_SETCREDENTIALS_FOR_SERVER = 0
%HTTPREQUEST_SETCREDENTIALS_FOR_PROXY  = 1
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("TCP and APIs",0,0,40,120)
  '
  funLog("TCP and APIs")
  '
  LOCAL strURL AS ASCIIZ * 1024
  LOCAL strAPI AS STRING
  LOCAL wstrError AS WSTRING
  LOCAL strResult AS STRING
  '
  LOCAL pWHttp AS IWinHttpRequest
  '
  pWHttp = NEWCOM "WinHttp.WinHttpRequest.5.1"
  IF ISNOTHING(pWHttp) THEN EXIT FUNCTION
  '
  funLog "connecting to the API"
  '
  strURL = "https://www.breakingbadapi.com"
  'strAPI = "/api/characters/2"
  strAPI = "/api/characters?name=Walter"
  '
  IF ISTRUE funGetAPIOutput(pWHttp, _
                            strURL,_
                            strAPI, _
                            wstrError,_
                            strResult) THEN
    ' now parse the result
    strResult = funParseJSON(strResult)
    funAppendToFile(EXE.PATH$ & "OutputStart.txt", strResult)
    funlog strResult
  ELSE
  ' function failed?
    funlog(ACODE$(wstrError))
  '
  END IF
                            '
  funWait()
  '
END FUNCTION
'
FUNCTION funGetAPIOutput(pWHttp AS IWinHttpRequest, _
                         strURL AS ASCIIZ * 1024 ,_
                         strAPI AS STRING, _
                         wstrError AS WSTRING,_
                         strResult AS STRING) AS LONG
                         '
  LOCAL lngSucceeded AS LONG
  LOCAL vStream AS VARIANT
  LOCAL pIStream AS IStream
  LOCAL tstatstg AS STATSTG
  LOCAL strBuffer AS STRING
  LOCAL cbRead AS DWORD
  '
' connect to the web api
  TRY
  ' open connection to a HTTP resource
    pWHttp.Open "GET", strURL & strAPI, %FALSE
    '
    ' set credentials for server
    ' pWHttp.SetCredentials( strUsername, _
    '                        strPassword, _
    '                        %HTTPREQUEST_SETCREDENTIALS_FOR_SERVER)
                            '
    ' pWHttp.SetCredentials( "username", _
    '                        "password", _
    '                        %HTTPREQUEST_SETCREDENTIALS_FOR_PROXY)
    '
    pWHttp.Send
    '
    lngSucceeded = pWHttp.WaitForResponse(6)
    '
    vStream = pWHttp.ResponseStream
    IF VARIANTVT(vStream) = %VT_UNKNOWN THEN
      pIStream = vStream
      ' get the size of the stream
      pIStream.Stat(tstatstg, %STATFLAG_NONAME)
      strBuffer = SPACE$(tstatstg.cbsize)
      ' read the stream into buffer
      pIStream.Read STRPTR(strBuffer), LEN(strBuffer), cbRead
      '
      IF cbRead < tstatstg.cbsize THEN
        strBuffer = LEFT$(strBuffer, cbRead)
      END IF
      '
      pIStream = NOTHING
      '
      IF LEN(strBuffer) > 0 THEN
      ' save the buffer
        strResult = strBuffer
        wstrError = ""
        FUNCTION = %TRUE
      ELSE
      ' no data ?
        wstrError = ""
        FUNCTION = %TRUE
      END IF
      '
    ELSE
    ' ignore
    END IF

  '
  CATCH
    wstrError = funGetOleErrorInfo(OBJRESULT)
    FUNCTION = %FALSE
  FINALLY
  END TRY
'
END FUNCTION
'
FUNCTION funGetOleErrorInfo(OPTIONAL BYVAL nErrorcode AS LONG, _
                            OPTIONAL BYVAL pObj AS IUNKNOWN, _
                            OPTIONAL BYREF riid AS GUID) AS WSTRING
' return the error
  LOCAL bstrMsg AS WSTRING

  bstrMsg = OleGetErrorInfo(nErrorCode, pObj, BYVAL VARPTR(riid))
  FUNCTION = bstrMsg
'
END FUNCTION
'
FUNCTION funParseJSON(strResult AS STRING) AS STRING
' parse the JSON result
'
  LOCAL strSection AS STRING
  LOCAL lngSection AS LONG
  LOCAL strInput AS STRING
  LOCAL lngInsideBracket AS LONG
  LOCAL lngInsideQuote AS LONG
  LOCAL strCharacter AS STRING
  LOCAL lngR AS LONG
  '
  strInput = strResult
  '
  LOCAL sbOutput AS ISTRINGBUILDERA
  sbOutput = CLASS "StringBuilderA"
  '
  sbOutput.clear
  sbOutput.capacity = 5000
  '
  REPLACE "{" WITH "{" & $CRLF IN strInput
  REPLACE "}" WITH $CRLF & "}" IN strInput
  '
  FOR lngSection = 1 TO PARSECOUNT(strInput, $CRLF)
    strSection = PARSE$(strInput,$CRLF, lngSection)
    '
    SELECT CASE strSection
      CASE "[{", "}]"
        sbOutput.add strSection & $CRLF
        ITERATE FOR
    END SELECT
    '
    lngInsideBracket = %FALSE
    lngInsideQuote = %FALSE
    '
    FOR lngR = 1 TO LEN(strSection)
    ' look through the section one character at a time
      strCharacter = MID$(strSection,lngR,1)
      SELECT CASE strCharacter
        CASE $DQ
          IF ISTRUE lngInsideQuote THEN
            lngInsideQuote = %FALSE
          ELSE
            lngInsideQuote = %TRUE
          END IF
          '
          sbOutput.add strCharacter
        CASE "["
          lngInsideBracket = %TRUE
          sbOutput.add strCharacter
        CASE "]"
          lngInsideBracket = %FALSE
          sbOutput.add strCharacter
          '
        CASE ","
          IF ISTRUE lngInsideBracket OR ISTRUE lngInsideQuote THEN
            sbOutput.add strCharacter
          ELSE
            sbOutput.add strCharacter & $CRLF
          END IF
        CASE ELSE
          sbOutput.add strCharacter
          '
      END SELECT
    '
    NEXT lngR
    '
    sbOutput.add $CRLF
    '
  NEXT lngSection
  '
  FUNCTION = sbOutput.string
  '
END FUNCTION
