#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Pointers",0,0,40,120)
  '
  funLog("Pointers")
  '
  DIM a_strList(1 TO 10) AS STRING
  ARRAY ASSIGN a_strList() = "one","two","four","eight", _
                             "ten","twelve","sixteen","twenty", _
                             "thirty","fifty"
  '
  DIM a_strList_new(1 TO 5) AS STRING
  ARRAY ASSIGN a_strList_new() = "1","2","4","8","10"
  '
  LOCAL lngValue AS LONG
  lngValue = 2
  '
  LOCAL pArray AS STRING POINTER
  LOCAL lngMax AS LONG
  '
  'lngMax = ubound(a_strList)
  '
  'pArray = VARPTR(a_strList(1))
  '
  IF lngValue = 1 THEN
  ' set parameters for first array
    pArray = VARPTR(a_strList(1))
    lngMax = UBOUND(a_strList)
  ELSE
  ' set parameters for second array
    pArray = VARPTR(a_strList_new(1))
    lngMax = UBOUND(a_strList_new)
  END IF
  '
  'funProcess(a_strList())
  ' call the generic array passing a pointer to
  ' the array to be processed
  funProcess_new(pArray,lngMax)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funProcess_new(BYVAL pArray AS STRING POINTER, _
                        lngMax AS LONG) AS LONG
' process the array pointed to by pArray
  LOCAL lngR AS LONG
  ' element will always start at 0
  FOR lngR = 0 TO lngMax - 1
    funLog( @pArray[lngR])
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funProcess(BYREF a_Data() AS STRING) AS LONG
' process the array passed by reference
  LOCAL lngR AS LONG
  ' element will start at the lower bounding of the array
  ' you could use
  ' FOR lngR = lbound(a_Data) to ubound(a_Data)
  '
  FOR lngR = 1 TO UBOUND(a_Data)
    funlog(a_Data(lngR))
  NEXT lngR
  '
END FUNCTION
