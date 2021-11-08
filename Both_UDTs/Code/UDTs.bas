#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
ENUM CarType SINGULAR
  TwoDoor = 1
  FourDoor
  FiveDoor
END ENUM
'
TYPE udtCar
  strOwnername AS STRING * 150
  strColour AS STRING * 20
  strMake AS STRING * 150
  lngCarType AS LONG
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("UDTs",0,0,40,80)
  '
  funLog("Walk through on UDTs ")
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
  funLog(TRIM$(uCars.strOwnername) & "")
  funLog(TRIM$(uCars.strColour) & "")
  funLog(TRIM$(uCars.strMake) & "")
  funLog(FORMAT$(uCars.lngCarType))
  '
  DIM a_uCars(10) AS udtCar
  '
  PREFIX "a_uCars(1)."
    strOwnername = "Tom Smith"
    strColour = "Red"
    strMake = "Ford"
    lngCarType = %FourDoor
  END PREFIX
  '
  funLog(TRIM$(a_uCars(1).strOwnername) & "")
  funLog(TRIM$(a_uCars(1).strColour) & "")
  funLog(TRIM$(a_uCars(1).strMake) & "")
  funLog(FORMAT$(a_uCars(1).lngCarType))
  '

  '
  funWait()
'
END FUNCTION
'
