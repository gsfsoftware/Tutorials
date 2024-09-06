#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
' User defined type for car details
TYPE udtCar
  strMake AS STRING   * 20
  strModel AS STRING  * 20
  strType AS STRING   * 20
  strColour AS STRING * 20
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Parameters",0,0,40,120)
  '
  funLog("Parameters")
  '
  LOCAL lngCount AS LONG
  '
  FOR lngCount = 1 TO 5
    funProcessCountByValue(lngCount)
  NEXT lngCount
  '
  ' call a subroutine. "CALL" is optional
  CALL subProcessCount(lngCount)
  '
  LOCAL lngValue AS LONG
  lngValue = 12
  LOCAL lngSpecialValue AS LONG
  lngSpecialValue = 13
  '
  ' you can pass up to 32 parameters
  'if istrue funIsValueEven(lngValue) then
  IF ISTRUE funIsValueEven(lngValue,lngSpecialValue) THEN
    funLog(FORMAT$(lngValue) & " is even")
  ELSE
    funLog(FORMAT$(lngValue) & " is odd")
  END IF
  '
  ' declare and populate the UDT
  LOCAL uCar AS udtCar
  PREFIX "uCar."
    strMake = "Ford"
    strModel = "Capri"
    strType = "Electric"
    strColour = "Silver"
  END PREFIX
  '
  ' show the details stored in the UDT
  funShowCarDetails(uCar)
  '
  '  handle an array of UDTs
  DIM a_uCars(2) AS udtCar
  '
  LOCAL lngC AS LONG
  '
  FOR lngC = 1 TO 2
    PREFIX "a_uCars(lngC)."
      strMake = "Ford " & FORMAT$(lngC)
      strModel = "Capri " & FORMAT$(lngC)
      strType = "Electric " & FORMAT$(lngC)
      strColour = "Silver " & FORMAT$(lngC)
    END PREFIX
  NEXT lngC
  '
  funShowAllCarDetails(a_uCars())
  '
  LOCAL lngCounter AS LONG
  LOCAL lngTotal AS LONG
  LOCAL lngLoop AS LONG
  LOCAL qTimer AS QUAD
  '
  ' call a Fast proc function
  lngCounter = 10
  lngTotal = 0
  '
  TIX qTimer
  FOR lngLoop = 1 TO 1000
    lngTotal = fprocProcess(lngTotal,lngCounter)
  NEXT lngLoop
  TIX END qTimer
  '
  funLog("FastProc Total = " & FORMAT$(lngTotal) & " in " & _
                               FORMAT$(qTimer))
                               '
  ' call a normal function
  lngCounter = 10
  lngTotal = 0
  '
  TIX qTimer
  FOR lngLoop = 1 TO 1000
    lngTotal = funProcess(lngTotal,lngCounter)
  NEXT lngLoop
  TIX END qTimer
  '
  funLog("Function Total = " & FORMAT$(lngTotal) & " in " & _
                               FORMAT$(qTimer))
  '

  '
  funWait()
  '
END FUNCTION
'
FASTPROC fprocProcess(BYVAL lngTotal AS LONG, _
                      BYVAL lngCounter AS LONG) AS LONG
' run as fast procedure
  '
  lngTotal = lngTotal + lngCounter
'
END FASTPROC = lngTotal
'
FUNCTION funProcess(lngTotal AS LONG, _
                    lngCounter AS LONG) AS LONG
' run as normal function
  lngTotal = lngTotal + lngCounter
  FUNCTION = lngTotal
  '
END FUNCTION
'
FUNCTION funShowAllCarDetails(a_uCars() AS udtCar) AS LONG
' display details of the cars
  LOCAL lngC AS LONG
  FOR lngC = 1 TO UBOUND(a_uCars)
    funLog(a_uCars(lngC).strMake & $CRLF & _
           a_uCars(lngC).strModel & $CRLF & _
           a_uCars(lngC).strType & $CRLF & _
           a_uCars(lngC).strColour)
  NEXT lngC
'
END FUNCTION
'
FUNCTION funShowCarDetails(uCar AS udtCar) AS LONG
' display details of the car
  funLog(uCar.strMake & $CRLF & _
         uCar.strModel & $CRLF & _
         uCar.strType & $CRLF & _
         uCar.strColour)
'
END FUNCTION
'
FUNCTION funIsValueEven(lngValue AS LONG, _
                        OPTIONAL lngSpecialValue AS LONG) AS LONG
' has optional parameter been passed
  IF ISTRUE ISMISSING(lngSpecialValue) THEN
    funLog("No optional parameter")
  ELSE
    funLog("Optional parameter = " & FORMAT$(lngSpecialValue))
  END IF
  '
' test if value is odd or even
  IF lngValue MOD 2 = 0 THEN
  ' no remainder when divided by 2 - so even
    FUNCTION = %TRUE
  ELSE
  ' there is some remainder - so odd
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
SUB subProcessCount(lngCount AS LONG)
' subroutine by Ref
  funLog("Sub Count Value = " & FORMAT$(lngCount))
'
END SUB
'
FUNCTION funProcessCountByRef(BYREF lngNewCount AS LONG) AS LONG
' process each count by reference
  LOCAL lngValue AS LONG
  '
  lngValue = lngNewCount + 1
  funLog("Count Value = " & FORMAT$(lngValue))
  '
  INCR lngNewCount
  '
END FUNCTION
'
FUNCTION funProcessCountByValue(BYVAL lngCount AS LONG) AS LONG
' process each count by value
  LOCAL lngValue AS LONG
  '
  lngValue = lngCount + 1
  funLog("Count Value = " & FORMAT$(lngValue))
  '
  INCR lngCount
'
END FUNCTION
