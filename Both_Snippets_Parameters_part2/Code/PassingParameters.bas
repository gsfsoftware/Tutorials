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
' user defined type
TYPE udtCar
  strOwnername AS STRING * 150
  strColour AS STRING * 20
  strMake AS STRING * 150
  lngCarType AS LONG
END TYPE
'
' enumeration
ENUM CarType SINGULAR
  TwoDoor = 1
  ThreeDoor
  FourDoor
  FiveDoor
END ENUM
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Passing Parameters",0,0,40,120)
  '
  funLog("Passing Parameters")
  '
  ' simple parameters
  LOCAL lngData AS LONG
  lngData = 13
  '
  funDisplay(lngData)
  funLog("Updated Value = " & FORMAT$(lngData))
  '
  '
  LOCAL strData AS STRING
  strData = "String Test"
  funDisplayString(strData)
  funLog("Updated String value = " & strData)
  '
  funDisplayString_new(strData)
  funLog("Updated String value = " & strData)
  '
  ' passing UDTs
  funLog($CRLF)
  LOCAL uCars AS udtCar
  '
  PREFIX "uCars."
    strOwnername = "Fred Jones"
    strColour = "Blue"
    strMake = "Tesla Supercar"
    lngCarType = %TwoDoor
  END PREFIX
  '
  subProcessCars(uCars)
  funlog("Owner -> " & TRIM$(uCars.strOwnerName))
  '
  ' passing by pointer
  LOCAL pCars AS LONG
  pCars = VARPTR(uCars)
  subProcessCarsByPointer(pCars)
  funlog("Owner -> " & TRIM$(uCars.strOwnerName))
  '
  ' passing arrays
  funLog($CRLF)
  DIM a_strNames(1 TO 10) AS STRING
  a_strNames(1) = "Fred"
  a_strNames(2) = "Susan"
  '
  funProcessNames(BYREF a_strNames())
  funLog(a_strNames(1) & " and " & a_strNames(2))
  '
  funProcessName(a_strNames(1))
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funProcessName(BYREF strName AS STRING) AS LONG
  funlog("Element of array -> " & strName)
  '
  LOCAL strNewName AS STRING
  strNewName = " Value -> " & strName
  funProcessNameByValue(BYVAL strNewName)
  funlog("Original -> " & strNewName)

  '
END FUNCTION
'
FUNCTION funProcessNameByValue(BYVAL strNewName AS STRING) AS LONG
  strNewName = strNewName & "**"
  funlog("Amended -> " & strNewname)
END FUNCTION
'
FUNCTION funProcessNames(BYREF a_strNames() AS STRING) AS LONG
' passing by ref
  funLog(a_strNames(1) & " and " & a_strNames(2))
  a_strNames(1) = "Tom"

END FUNCTION
'
SUB subProcessCarsByPointer(BYVAL pCars AS udtCar POINTER)
' passing by pointer
  LOCAL strOwnerName AS STRING
  strOwnerName = TRIM$(@pCars.strOwnerName)
  funlog("Owner By pointer -> " & strOwnerName)
  ' update the owner
  @pCars.strOwnerName = "Tom Jones"
'
END SUB
'
'SUB subProcessCars(uCars AS udtCar)
SUB subProcessCars(BYVAL uCars AS udtCar)
' process cars UDT
  LOCAL strOwnerName AS STRING
  '
  strOwnerName = TRIM$(uCars.strOwnerName)
  funlog("Owner -> " & strOwnerName)
  uCars.strOwnerName = "no-one"
'
END SUB
'
FUNCTION funDisplayString_new(strString AS STRING) AS LONG
' display a string
  funLog("String value = " & strString)
  strString = strString & " - even more text"
'
END FUNCTION
'
FUNCTION funDisplayString(strData AS STRING) AS LONG
' display a string
  funLog("String value = " & strData)
  strData = strData & " - more text"
'
END FUNCTION
'
'FUNCTION funDisplay(BYREF lngData AS LONG) AS LONG
FUNCTION funDisplay(BYVAL lngData AS LONG) AS LONG
' display the value passed
  funLog("Value = " & FORMAT$(lngData))
  ' add one to the data variable
  INCR lngData
END FUNCTION
