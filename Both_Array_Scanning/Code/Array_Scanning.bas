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
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array Scanning",0,0,40,120)
  '
  funLog("Array Scanning")
  '
  LOCAL strTarget AS STRING
  strTarget = "2025-11-02"
  funDo_1D_Scan(strTarget)
  '
  LOCAL lngColumn AS LONG
  lngColumn = 2
  strTarget = "2025-11-02"
  funDo_2D_Scan(strTarget, lngColumn)
  '
   ' look in another column
  lngColumn = 1
  strTarget = "1002"
  funDo_2D_Scan(strTarget, lngColumn)
  '
  ' look for something that doesn't exist
  lngColumn = 2
  strTarget = "2025-12-02"
  funDo_2D_Scan(strTarget, lngColumn)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funDo_2D_Scan(strTarget AS STRING, _
                       lngColumn AS LONG) AS LONG
  DIM a_strData() AS STRING     ' array for data
  ' where target is value to be scanned for
  funPrep_2D_Array(a_strData())
  '
  funLog($CRLF & "Scanning for -> " & strTarget)
  LOCAL lngElement AS LONG    ' element found
  lngElement = funScan_2D_Array(a_strData(),strTarget,lngColumn)
  '
  ' display the 2D array data
  LOCAL lngR, lngC AS LONG
  LOCAL strResult AS STRING
  funLog("2D Array data")
  FOR lngR = LBOUND(a_strData,1) TO UBOUND(a_strData,1)
    strResult = FORMAT$(lngR) & " "
    FOR lngC = LBOUND(a_strData,2) TO UBOUND(a_strData,2)
      strResult = strResult & a_strData(lngR, lngC) & " , "
    NEXT lngC
    funLog(strResult)
  NEXT lngR
  funLog("")
  '
  IF LBOUND(a_strData,1) = 0 AND lngElement > 0 THEN
  ' return correct array row number if 0 based array
    DECR lngElement
  END IF
  '
  funLog("Element found in 2D array = " & FORMAT$(lngElement))
  '
END FUNCTION
'
FUNCTION funScan_2D_Array(BYREF a_strData() AS STRING, _
                          strTarget AS STRING, _
                          lngColumn AS LONG) AS LONG
' scan the array for the target
  LOCAL lngElement AS LONG
  '
  ARRAY SCAN a_strData(0, lngColumn), COLLATE UCASE, = strTarget, _
                                      TO lngElement
  '
  FUNCTION = lngElement  ' return the element of the array found
  '
END FUNCTION
'
FUNCTION funPrep_2D_Array(BYREF a_strData() AS STRING) AS LONG
' prepare the 2 dimensional array with 5 rows
  REDIM a_strData(0 TO 5,0 TO 2) AS STRING
  ' populate the 2D array
  a_strData(0,1) = "A/C "
  a_strData(0,2) = "Date      "
  '
  a_strData(1,1) = "1000"
  a_strData(1,2) = "2025-11-01"
  '
  a_strData(2,1) = "1001"
  a_strData(2,2) = "2025-11-02"
  '
  a_strData(3,1) = "1002"
  a_strData(3,2) = "2025-11-03"
  '
  a_strData(4,1) = "1003"
  a_strData(4,2) = "2025-11-04"
  '
  a_strData(5,1) = "1004"
  a_strData(5,2) = "2025-11-05"
  '
END FUNCTION
'
FUNCTION funDo_1D_Scan(strTarget AS STRING) AS LONG
  DIM a_strData() AS STRING     ' array for data
  ' where target is value to be scanned for
  funPrep_1D_Array(a_strData())
  '
  funLog($CRLF & "Scanning for -> " & strTarget)
  LOCAL lngElement AS LONG    ' element found
  lngElement = funScan_1D_Array(a_strData(),strTarget)
  '
  ' display the 1D array data
  LOCAL lngR AS LONG
  funLog("1D Array data")
  FOR lngR = LBOUND(a_strData) TO UBOUND(a_strData)
    funLog(FORMAT$(lngR) & " " & a_strData(lngR))
  NEXT lngR
  funLog("")
  '
  funLog("Element found in 1D array = " & FORMAT$(lngElement))
  '
END FUNCTION
'
FUNCTION funScan_1D_Array(BYREF a_strData() AS STRING, _
                          strTarget AS STRING) AS LONG
' scan the array for the target
  LOCAL lngElement AS LONG
  '
  ARRAY SCAN a_strData(), COLLATE UCASE, = strTarget, TO lngElement
  '
  FUNCTION = lngElement  ' return the element of the array found
  '
END FUNCTION
'
FUNCTION funPrep_1D_Array(BYREF a_strData() AS STRING) AS LONG
' prepare the 1 dimensional array with 5 rows
  REDIM a_strData(1 TO 5) AS STRING
  ' populate the 1D array
  ARRAY ASSIGN a_strData() = "2025-11-01", _
                             "2025-11-02", _
                             "2025-11-03", _
                             "2025-11-04", _
                             "2025-11-05"
                             '
END FUNCTION
'
