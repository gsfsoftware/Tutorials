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
' add an icon to the application
#RESOURCE ICON, AppIcon, "Add.ICO"
'
' prepare the version information
#RESOURCE VERSIONINFO
'
#RESOURCE FILEVERSION 1, 2, 3, 4
#RESOURCE PRODUCTVERSION 1, 2, 3, 4
'
' set language ID as U.S. English
' and character set as Unicode
#RESOURCE STRINGINFO "0409", "04B0"
'
#RESOURCE VERSION$ "CompanyName",      "My Company, Inc."
#RESOURCE VERSION$ "FileDescription",  "Program for doing neat stuff"
#RESOURCE VERSION$ "FileVersion",      "01.02.03.0004"
#RESOURCE VERSION$ "InternalName",     "ResourceCMD"
#RESOURCE VERSION$ "OriginalFilename", "ResourceCMD.EXE"
#RESOURCE VERSION$ "LegalCopyright",   "Copyright © 2024 My Company, Inc."
#RESOURCE VERSION$ "ProductName",      "My Product Name"
#RESOURCE VERSION$ "ProductVersion",   "01.02.03.0004"
#RESOURCE VERSION$ "Comments",         "This is a very fine program."
'
' embed files
#RESOURCE RCDATA, 4000 ,"TestDemo_2.csv"
#RESOURCE RCDATA, 4001 ,"TestDemo_3.csv"
#RESOURCE RCDATA, 4002 ,"SimpleDLL.dll"
'
'declare function funHalf_A_value import "SimpleDLL.DLL" _
'                 alias "funHalf_A_Value" _
'                 (sngValue as single) as single
'
' declare the function we are going to user in the DLL library
DECLARE FUNCTION funGetValue(sngValue AS SINGLE) AS SINGLE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Resource command",0,0,40,120)
  '
  funLog("Resource command")
  '
  funLog("Saving resource")
  funSaveResource("TestDemo_2.csv",4000)
  funSaveResource("TestDemo_3.csv",4001)
  funSaveResource("SimpleDLL.dll",4002)
  '
  LOCAL sngValue AS SINGLE    ' original value
  LOCAL sngNewValue AS SINGLE ' new value
  sngValue = 10
  '
  ' early binding
  'sngNewValue = funHalf_A_Value(sngValue)
  '
  ' late binding
  LOCAL hProc AS DWORD
  LOCAL ascFunction AS ASCIIZ * 100
  '
  ' name of the function to be called
  ascFunction = "funHalf_A_Value"
  '
  ' late binding to DLL
  LOCAL hLib AS DWORD
  hLib = LoadLibrary("SimpleDLL.dll")
  '
  IF hLib <> 0 THEN
    ' if library is loaded
    ' get the address of the function
    ' we want to call
    hProc = GetProcAddress(hLib, ascFunction)
    IF hProc <> 0 THEN
    ' if we've got the address to call the function
    ' within the loaded DLL
      CALL DWORD hProc USING funGetValue(sngValue) TO sngNewValue
    END IF
  END IF
  '
  funLog("New Value = " & FORMAT$(sngNewValue))
  '
  funWait()
  '
  ' drop the ref to the library
  IF hLib <> 0 THEN FreeLibrary hLib
  '
END FUNCTION
'
FUNCTION funSaveResource(strFilename AS STRING, _
                         lngHandle AS LONG) AS LONG
' Save the resource
  LOCAL lngFreeFile AS LONG
  LOCAL strData AS STRING
  '
  ' save resource file
  strData  = RESOURCE$(RCDATA, lngHandle)
  lngFreeFile = FREEFILE
  OPEN strFilename FOR OUTPUT AS lngFreeFile
  PRINT# lngFreeFile, strData  ;
  CLOSE lngFreeFile
  '
END FUNCTION
'
