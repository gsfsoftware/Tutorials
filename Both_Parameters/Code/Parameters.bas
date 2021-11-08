#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
TYPE udtCar
  strOwnername AS STRING * 150
  strColour AS STRING * 20
  strMake AS STRING * 150
  lngCarType AS LONG
END TYPE
'
ENUM CarType SINGULAR
  TwoDoor = 1
  ThreeDoor
  FourDoor
  FiveDoor
END ENUM
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Parameters",0,0,40,80)
  '
  funLog("Walk through on Parameters ")
  '
  LOCAL lngValue AS LONG
  lngValue = 15
  '
  funDisplay(lngValue)
  '
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
  '
  LOCAL pCars AS LONG
  pCars = VARPTR(uCars)
  subProcessCarsByPointer(pCars)
  '
  DIM a_strNames(10) AS STRING
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
  strNewName = " Byvalue -> " & strName
  funProcessNameByValue(BYVAL strNewName)
  funlog("Original -> " & strNewName)

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
  LOCAL strOwnerName AS STRING
  strOwnerName = TRIM$(@pCars.strOwnerName)
  funlog("By pointer -> " & strOwnerName)
END SUB
'
SUB subProcessCars(uCars AS udtCar)
  LOCAL strOwnerName AS STRING
  '
  strOwnerName = TRIM$(uCars.strOwnerName)
  funlog("By type -> " & strOwnerName)
  '
END SUB
'
FUNCTION funDisplay(BYREF lngValue AS LONG, _
                    OPTIONAL strValue AS STRING) AS LONG
  LOCAL strLocalValue AS STRING
  '
  IF ISTRUE ISMISSING(strValue) THEN
    strLocalValue = "some default value"
  ELSE
    strLocalValue = strValue
  END IF
  '


END FUNCTION
