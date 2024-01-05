#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
' ' no need for console if running under Console compiler
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF
'
%Production = 1  ' set for production run
'                  comment out when testing/debug

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
#INCLUDE "httprequest.inc"
#INCLUDE "ole2utils.inc"
'
GLOBAL dwFont AS DWORD      ' handle of the font used
'
%HTTPREQUEST_SETCREDENTIALS_FOR_SERVER = 0
%HTTPREQUEST_SETCREDENTIALS_FOR_PROXY  = 1
'
' n.b. this application uses the José Roca API libraries
' available from
' for latest version see link below
' http://www.jose.it-berater.org/smfforum/index.php?topic=5061.0
'
' The web site we are using for the weather API is
' https://open-meteo.com/en/docs
'
' https://api.open-meteo.com
' /v1/forecast?latitude=55.8651&longitude=-4.2576&hourly=temperature_2m&forecast_days=1
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
'
  #IF NOT %DEF(%Production)
    funPrepOutput("Weather Web API",0,0,40,120)
    funLog("Weather Web API")
  #ENDIF
  '
  LOCAL strURL AS ASCIIZ * 1024  ' URL for web site
  LOCAL strAPI AS STRING         ' string for API
  LOCAL wstrError AS WSTRING     ' to hold any error msg
  LOCAL strResult AS STRING      ' output from API
  LOCAL hWin AS DWORD            ' handle of graphics window
  LOCAL lngLoopCount AS LONG     ' number of times loop executed
  '
  LOCAL pWHttp AS IWinHttpRequest
  '
  pWHttp = NEWCOM "WinHttp.WinHttpRequest.5.1"
  IF ISNOTHING(pWHttp) THEN EXIT FUNCTION
  '
  #IF NOT %DEF(%Production)
    funLog "connecting to the API"
  #ENDIF
  '
  ' set the web site
  strURL = "https://api.open-meteo.com"
  '
  ' get just temperature for 'today'
'  strAPI = "/v1/forecast?latitude=55.8651&longitude=-4.2576" & _
'           "&hourly=temperature_2m&forecast_days=1"
'           '
'  ' get temperature and rainfall
'  strAPI = "/v1/forecast?latitude=55.8651&longitude=-4.2576" & _
'           "&hourly=temperature_2m,rain&forecast_days=1"
  '
  ' get temperature and rainfall and probability of rain
  strAPI = "/v1/forecast?latitude=55.8651&longitude=-4.2576" & _
           "&hourly=temperature_2m,precipitation_probability" & _
           ",precipitation,cloud_cover&forecast_days=1"
           '
  hWin = funCreateGraphicsWindow()
  '
  lngLoopCount = 0 ' set starter value
  '
  DO UNTIL ISFALSE isWindow(hWin)
  ' loop until graphics window has been closed
    IF lngLoopCount = 20*15 THEN  ' only query web site every 15 mins
      lngLoopCount = 0
    END IF
    '
    IF lngLoopCount = 0 THEN
    ' only run once per 20*15 loops
    '
      IF ISTRUE funGetAPIOutput(pWHttp, _
                                strURL,_
                                strAPI, _
                                wstrError,_
                                strResult) THEN
        ' now parse the result
        'funAppendToFile(EXE.PATH$ & "OutputStart.txt", strResult & $CRLF)
        #IF NOT %DEF(%Production)
           funLog("Data Returned")
        #ENDIF
        strResult = funParseJSON(strResult)
        'funAppendToFile(EXE.PATH$ & "OutputStart.txt", strResult)
        funUpdateGraphicsWindow(strResult)
        '
      ELSE
        ' function failed?
        #IF NOT %DEF(%Production)
           funLog(ACODE$(wstrError))
        #ENDIF
        '
      END IF
    END IF
    '
    ' advance loop counter
    INCR lngLoopCount
    '
    ' check for graphics window closing every 3 seconds
    SLEEP 3000
    '
    IF ISFALSE isWindow(hWin) THEN
    ' check for graphics window closing every 3 seconds
      EXIT LOOP
    END IF
    '
  LOOP
  '
  'funWait()
  '
END FUNCTION
'
FUNCTION funGetAPIOutput(pWHttp AS IWinHttpRequest, _
                         strURL AS ASCIIZ * 1024 ,_
                         strAPI AS STRING, _
                         wstrError AS WSTRING,_
                         strResult AS STRING) AS LONG
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
    pWHttp.OPEN "GET", strURL & strAPI, %FALSE
    ' set credentials for server
    ' pWHttp.SetCredentials( strUsername, _
    '                        strPassword, _
    '                        %HTTPREQUEST_SETCREDENTIALS_FOR_SERVER)
                            '
    ' pWHttp.SetCredentials( "username", _
    '                        "password", _
    '                        %HTTPREQUEST_SETCREDENTIALS_FOR_PROXY)
    '
    pWHttp.SEND
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
      pIStream.READ STRPTR(strBuffer), LEN(strBuffer), cbRead
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
        sbOutput.ADD strSection & $CRLF
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
          sbOutput.ADD strCharacter
        CASE "["
          lngInsideBracket = %TRUE
          sbOutput.ADD strCharacter
        CASE "]"
          lngInsideBracket = %FALSE
          sbOutput.ADD strCharacter
          '
        CASE ","
          IF ISTRUE lngInsideBracket OR ISTRUE lngInsideQuote THEN
            sbOutput.ADD strCharacter
          ELSE
            sbOutput.ADD strCharacter & $CRLF
          END IF
        CASE ELSE
          sbOutput.ADD strCharacter
          '
      END SELECT
    '
    NEXT lngR
    '
    sbOutput.ADD $CRLF
    '
  NEXT lngSection
  '
  FUNCTION = sbOutput.STRING
  '
END FUNCTION
'
FUNCTION funCreateGraphicsWindow() AS LONG
' create the graphics window
  LOCAL hWin AS DWORD
  GRAPHIC WINDOW "Weather Reporter", 50, 50, 300,200 TO hWin
  ' set window to be on top
  SetWindowPos(hWin, %HWND_TOPMOST, 0, 0, 0, 0, _
               %SWP_NOMOVE OR %SWP_NOSIZE)
               '
  GRAPHIC ATTACH hWin, 0, REDRAW
  '
  FONT NEW "Courier New",18,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  GRAPHIC REDRAW
  '
  FUNCTION = hWin
  '
END FUNCTION
'
FUNCTION funUpdateGraphicsWindow(strResult AS STRING) AS LONG
' update the graphics window
  LOCAL strIcon AS STRING        ' icon to be displayed
  LOCAL strTime AS STRING        ' current time
  LOCAL strDate AS STRING        ' current date
  LOCAL strTemperature AS STRING       ' Temp measure in °C or °F
  LOCAL strTimeSlots AS STRING         ' string of time slots
  LOCAL lngCurrentTimeSlot AS LONG     ' the current time slot number
  LOCAL strCurrentTimeSlot AS STRING   ' current time slot string
  LOCAL strPrecipitationProb AS STRING ' precipitation prob string
  LOCAL lngPrecipitationProb AS LONG   ' precipitation probability
  LOCAL strTemperatureData AS STRING   ' Temperature data
  LOCAL strCloudCoverData AS STRING    ' cloud cover data
  LOCAL lngCloudCover AS LONG          ' % slot cloud cover
  LOCAL lngX, lngY AS LONG             ' icon co-ords
  LOCAL lngIconsize AS LONG            ' size of icon in pixels
  '
  strTime = TIME$ ' get the current time
  strTime = LEFT$(strTime,2) & ":00"
  '
  ' and date
  strDate = DATE$
  strDate = RIGHT$(strDate,4) & "-" & _
            LEFT$(strDate,2) & "-" & _
            MID$(strDate,4,2)
            '
  strCurrentTimeSlot = strDate & "T" & strTime
  '
  strTemperature = MID$(funReadData(strResult, _
                          $DQ & "temperature_2m" & $DQ),5,2)
                          '
  GRAPHIC COLOR %BLACK,%RGB_LIGHTGRAY
  GRAPHIC CLEAR  ' clear ready for refresh
  '
  strTimeSlots = funReadData(strResult, _
                             $DQ & "time" & $DQ & ":[")
  '
  ' work out the time slot that contains the data
  lngCurrentTimeSlot = funParseFind(strTimeSlots ,"" _
                                   ,strCurrentTimeSlot)
                                   '
  INCR lngCurrentTimeSlot ' advance to next slot
  '
  GRAPHIC PRINT "In the next hour"
  strTemperatureData = funReadData(strResult, _
                    $DQ &"temperature_2m" & $DQ & ":[")
  '
  GRAPHIC PRINT "Temp = " & PARSE$(strTemperatureData,"", _
                            lngCurrentTimeSlot) & strTemperature
  '
  ' get precipitation
  strPrecipitationProb = funReadData(strResult, _
                    $DQ & "precipitation_probability" & $DQ & ":[")
  '
  lngPrecipitationProb = VAL(PARSE$(strPrecipitationProb,"",_
                                lngCurrentTimeSlot))
  GRAPHIC PRINT "Precip prob = " & _
                 FORMAT$(lngPrecipitationProb) & "%"
  '
  ' now get the cloud cover
  strCloudCoverData = funReadData(strResult, _
                    $DQ & "cloud_cover" & $DQ & ":[")
                    '
  lngCloudCover = VAL(PARSE$(strCloudCoverData,"",lngCurrentTimeSlot))
  '
  ' now decide on the icon to display
  strIcon = funDecideIcon(lngCloudCover,lngPrecipitationProb)
  lngX = 5: lngY = 90
  lngIconsize = 64
  '
  GRAPHIC RENDER ICON strIcon,(lngX,lngY)- _
                              (lngX + lngIconsize,lngY +lngIconsize)
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funDecideIcon(lngCloudCover AS LONG, _
                       lngPrecipitationProb AS LONG) AS STRING
' return the icon to match the prediction
'
  LOCAL strCloudy AS STRING  ' prob of cloud
  LOCAL strRain AS STRING    ' prob of rain
  '
  LOCAL lngCloud AS LONG     ' array values
  LOCAL lngRain AS LONG
  '
  ' define the icon array
  DIM strIcon(3,3) AS STRING
  '
  strIcon(1,1) = "Sun.ico"
  strIcon(1,2) = "Cloud_Rain.ico"
  strIcon(1,3) = "Cloud_Heavy_Rain.ico"
  '
  strIcon(2,1) = "Cloud_Sun.ico"
  strIcon(2,2) = "Cloud.ico"
  strIcon(2,3) = "Cloud_Rain.ico"
  '
  strIcon(3,1) = "Cloud.ico"
  strIcon(3,2) = "Cloud_Rain.ico"
  strIcon(3,3) = "Cloud_Heavy_Rain.ico"
  '
  SELECT CASE lngCloudCover
    CASE 0 TO 49
      strCloudy = "Low"
      lngCloud = 1
    CASE 50 TO 75
      strCloudy = "Medium"
      lngCloud = 2
    CASE > 75
      strCloudy = "High"
      lngCloud = 3
  END SELECT
  '
  SELECT CASE lngPrecipitationProb
    CASE 0 TO 29
      strRain = "Low"
      lngRain = 1
    CASE 30 TO 50
      strRain = "Medium"
      lngRain = 2
    CASE > 50
      strRain = "High"
      lngRain = 3
  END SELECT
  '
  ' return the icon needed
  FUNCTION = strIcon(lngCloud, lngRain)
  '
END FUNCTION
'
FUNCTION funReadData(strResult AS STRING, _
                     strCriteria AS STRING) AS STRING
' read through the Result to extract the data
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  FOR lngR = 1 TO PARSECOUNT(strResult,$CRLF)
    strData = PARSE$(strResult,$CRLF,lngR)
     IF LEFT$(strData,LEN(strCriteria)) = strCriteria THEN
      FUNCTION = MID$(strData,LEN(strCriteria))
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
END FUNCTION
