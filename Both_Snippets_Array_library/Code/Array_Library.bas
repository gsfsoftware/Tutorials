#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
' add the Array functions library
%IndexedSearch = %FALSE      ' these constants are needed
%IndexStart = 0              ' within this library
%IndexEnd = 0                ' and only need populated
'                              if you are doing Indexed searches
' for example
'%IndexedSearch = %TRUE      ' flag for indexed search
'%IndexStart = 1             ' start and end of index
'%IndexEnd   = 2             ' for unique character
'
#INCLUDE "PB_ArrayFunctions.inc"

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array Library",0,0,40,120)
  '
  funLog("Array Library")
  '
  DIM a_strData() AS STRING
  'funPopulate_1D_array(a_strData())
  'funPopulate_2D_array(a_strData())
  funPopulate_3D_array(a_strData())
  '
  LOCAL strLocation AS STRING
  strLocation = EXE.PATH$ & "TestStringArray.txt"
  LOCAL strError AS STRING
  '
  ' print the array
  'funPrint_1D_array(a_strData())
  'funPrint_2D_array(a_strData())
  funPrint_3D_array(a_strData())
  '
  ' save the array with a header
  IF ISTRUE funBinarySaveTheStringArrayDataWithHeader(a_strData(), _
                                                      strLocation, _
                                                      strError) THEN
    funLog("String array saved")
  ELSE
    funLog("Unable to save string array " & strError)
  END IF
  '
  ' wipe the array
  funLog($CRLF & "Wiping the array")
  RESET a_strData()
  '
  ' print the array
  'funPrint_1D_array(a_strData())
  'funPrint_2D_array(a_strData())
  funPrint_3D_array(a_strData())
  '
  ' resize the array
  REDIM a_strData(10) AS STRING
  funLog("Array has " & FORMAT$(UBOUND(a_strData)) & " rows")
  '
  IF ISTRUE funBinaryLoadTheStringArrayDataWithHeader(a_strData(), _
                                                      strLocation, _
                                                      strError) THEN
    funLog($CRLF & "String array loaded")
    ' print the array
    'funPrint_1D_array(a_strData())
    'funPrint_2D_array(a_strData())
    funPrint_3D_array(a_strData())
  ELSE
    funLog($CRLF & "Unable to load string array")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funPopulate_3D_array(BYREF a_strData() AS STRING) AS LONG
' insert dummy data into array
  REDIM a_strData(100,5,2) AS STRING
  a_strData(0,0,0) = "Header"
  a_strData(1,1,1) = "A"
  a_strData(1,2,1) = "B"
  a_strData(1,3,1) = "C"
  a_strData(2,1,2) = "d"
  a_strData(2,2,2) = "e"
  a_strData(2,3,2) = "f"
  '
END FUNCTION
'
FUNCTION funPrint_3D_array(BYREF a_strData() AS STRING) AS LONG
' print out part of the 2D array
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngD AS LONG
  LOCAL strData AS STRING
  '
  strData = a_strData(0,0,0) & " "
  '
  FOR lngR = 1 TO 2
    FOR lngC = 1 TO 3
      FOR lngD = 1 TO 2
        strData = strData & a_strData(lngR,lngC, lngD) & " "
      NEXT lngD
    NEXT lngC
  NEXT lngR
  '
  strData = strData & "with " & FORMAT$(UBOUND(a_strData)) & " rows"
  '
  funLog("3D array = " & strData)
  '
END FUNCTION
'
FUNCTION funPopulate_2D_array(BYREF a_strData() AS STRING) AS LONG
' insert dummy data into array
  REDIM a_strData(100,5) AS STRING
  a_strData(0,0) = "Header"
  a_strData(1,1) = "A"
  a_strData(1,2) = "B"
  a_strData(1,3) = "C"
  a_strData(2,1) = "a"
  a_strData(2,2) = "b"
  a_strData(2,3) = "c"
  '
END FUNCTION
'
FUNCTION funPrint_2D_array(BYREF a_strData() AS STRING) AS LONG
' print out part of the 2D array
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strData AS STRING
  '
  strData = a_strData(0,0) & " "
  '
  FOR lngR = 1 TO 2
    FOR lngC = 1 TO 3
      strData = strData & a_strData(lngR,lngC) & " "
    NEXT lngC
  NEXT lngR
  '
  strData = strData & "with " & FORMAT$(UBOUND(a_strData)) & " rows"
  '
  funLog("2D array = " & strData)
  '
END FUNCTION
'
FUNCTION funPopulate_1D_array(BYREF a_strData() AS STRING) AS LONG
' insert dummy data into array
  REDIM a_strData(100) AS STRING
  ARRAY ASSIGN a_strData() = "Header","a","b","c","d","e","f"
  '
END FUNCTION
'
FUNCTION funPrint_1D_array(BYREF a_strData() AS STRING) AS LONG
' print out part of the 1D array
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  FOR lngR = 0 TO 5
    strData = strData & a_strData(lngR) & " "
  NEXT lngR
  '
  strData = strData & "with " & FORMAT$(UBOUND(a_strData)) & " rows"
  '
  funLog("1D array = " & strData)
  '
END FUNCTION
