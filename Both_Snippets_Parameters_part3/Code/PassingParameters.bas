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
  RANDOMIZE TIMER  ' set random number generator
  '
  funLog("Passing Parameters")
  '
  ' undimensioned array
  DIM a_strData() AS STRING
  LOCAL lngRun AS LONG
  '
  FOR lngRun = 1 TO 4
    IF ISTRUE funPopulateArray(BYREF a_strData()) THEN
    ' array has been redimensioned
      LOCAL lngNumber_of_Dimensions AS LONG
      lngNumber_of_Dimensions = ARRAYATTR(a_strData(), 3)
      '
      funLog($CRLF & "Run -> " & FORMAT$(lngRun))
      SELECT CASE lngNumber_of_Dimensions
        CASE 1
          funLog("Array has " & FORMAT$(lngNumber_of_Dimensions) & _
                 " Dimension")
          funLog("Starts at row " & FORMAT$(LBOUND(a_strData)) & _
             " and ends at row " & FORMAT$(UBOUND(a_strData)))
        CASE 2
          funLog("Array has " & FORMAT$(lngNumber_of_Dimensions) & _
                 " Dimensions")
          funLog("Starts at row " & FORMAT$(LBOUND(a_strData)) & _
             " and ends at row " & FORMAT$(UBOUND(a_strData)))
          funLog("Starts at column " & FORMAT$(LBOUND(a_strData),2) & _
             " and ends at column " & FORMAT$(UBOUND(a_strData),2))
      END SELECT
      '
    END IF
    '
  NEXT lngR
  '
  ' prepare a udt array
  DIM a_udtArray() AS udtCar
  funPopulateUDTarray(BYREF a_udtArray())
  '
  funLog($CRLF)
  '
  LOCAL lngRow AS LONG
  FOR lngRow = 1 TO 2
    funLog("Car -> Owner = " & TRIM$(a_udtArray(lngRow).strOwnerName))
    funLog("       Make  = " & TRIM$(a_udtArray(lngRow).strMake))
    funLog("       Color = " & TRIM$(a_udtArray(lngRow).strColour))
    funLog("       Doors = " & FORMAT$(a_udtArray(lngRow).lngCarType))
    funLog($CRLF)
  NEXT lngRow
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funPopulateUDTarray(BYREF a_udtArray() AS udtCar) AS LONG
' populate a udt array
  LOCAL lngRows AS LONG
  LOCAL lngR AS LONG
  '
  lngRows = RND(5,10)
  '
  REDIM a_udtArray(1 TO lngRows) AS udtCar
  '
  DIM a_strColours(1 TO 5) AS STRING
  ARRAY ASSIGN a_strColours() = "Red","Blue","Black","Yellow","White"
  '
  DIM a_strMake(1 TO 5) AS STRING
  ARRAY ASSIGN a_strMake() = "Ford","Toyota","Jaguar","Renault","Tesla"
  '
  DIM a_strFirstname(1 TO 6) AS STRING
  ARRAY ASSIGN a_strFirstName() = "Tom","Harry","John","Susan","Amanda","Stacey"
  DIM a_strSurname(1 TO 6) AS STRING
  ARRAY ASSIGN a_strSurname() = "Jones","Smith","McDonald","Garcia","Brown","Williams"
  '
  FOR lngR = 1 TO lngRows
    PREFIX "a_udtArray(lngR)."
      strOwnername = a_strFirstName(RND(1,6)) & " " & a_strSurname(RND(1,6))
      strColour    = a_strColours(RND(1,5))
      strMake      = a_strMake(RND(1,5))
      lngCarType   = RND(%TwoDoor,%FiveDoor)
    END PREFIX
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funPopulateArray(BYREF a_strStringArray() AS STRING) AS LONG
' populate the array
  LOCAL lngDimensions AS LONG  ' number of array dimensions
  LOCAL lngRows AS LONG        ' number of rows
  LOCAL lngColumns AS LONG     ' number of columns
  LOCAL lngLowBound AS LONG    ' starting row number
  '
  lngDimensions = RND(1,2)
  lngRows = RND(10,20)
  lngLowBound = RND(0,10)
  lngColumns = RND(20,50)
  '
  SELECT CASE lngDimensions
    CASE 1
    ' one dimensional array
      REDIM a_strStringArray(lngLowBound TO lngLowBound + lngRows) AS STRING
    CASE 2
    ' two dimensional array
      REDIM a_strStringArray(lngLowBound TO lngLowBound + lngRows, _
                             lngColumns) AS STRING
  END SELECT
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
