#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
#INCLUDE "win32api.inc"
' include the common display library
#INCLUDE "CommonDisplay.inc"
'
' include file hashing libraies
#INCLUDE "Base32Str.inc"
#INCLUDE "PB_FileHash.inc"
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
#RESOURCE VERSION$ "FileDescription",  "Program for doing things"
#RESOURCE VERSION$ "FileVersion",      "01.02.03.0004"
#RESOURCE VERSION$ "InternalName",     "Resources"
#RESOURCE VERSION$ "OriginalFilename", "Resources.EXE"
#RESOURCE VERSION$ "LegalCopyright",   "Copyright © 2026 My Company, Inc."
#RESOURCE VERSION$ "ProductName",      "My Product Name"
#RESOURCE VERSION$ "ProductVersion",   "01.02.03.0004"
#RESOURCE VERSION$ "Comments",         "This is a very useful program."
'
' embed files
#RESOURCE RCDATA, 4000 ,"TestData.csv"
#RESOURCE RCDATA, 4001 ,"SimpleDLL.dll"
'
' declare the function we are going to user in the DLL library
' by defining the function name referenced in this program
DECLARE FUNCTION funGetValue(sngValue AS SINGLE) AS SINGLE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Resources",0,0,40,120)
  '
  funLog("Resources")
  '
  IF ISFALSE ISFILE(EXE.PATH$ & "SimpleDLL.dll") THEN
  ' file does not exist so save it
    IF ISTRUE funSaveResource("SimpleDLL.dll",4001) THEN
      funLog("Resource DLL saved")
    ELSE
      funLog("Unable to save dll")
    END IF
  ELSE
  ' file does exist but is it correct?
    IF ISFALSE funCheckHashValue("SimpleDLL.dll",4001) THEN
    ' hash value is incorrect
      funLog("Hash value of SimpleDLL.dll is NOT correct")
      '
      ' so save the resource to file
      IF ISTRUE funSaveResource("SimpleDLL.dll",4001) THEN
        funLog("Resource DLL saved")
      ELSE
        funLog("Unable to save dll")
      END IF
      '
    ELSE
    ' hash value is correct
      funLog("Hash value of SimpleDLL.dll is correct")
    '
    END IF
  '
  END IF
  '
  IF ISFALSE ISFILE(EXE.PATH$ & "TestData.csv") THEN
  ' file does not exist so save it
    IF ISTRUE funSaveResource("TestData.csv",4000) THEN
      funLog("Resource data csv saved")
    ELSE
      funLog("Unable to save data CSV")
    END IF
  ELSE
  ' file already exists
  END IF
  '
  ' Test the dll
  LOCAL sngNewValue AS SINGLE ' new value
  LOCAL sngValue AS SINGLE    ' initial value
  sngValue = 10
  funLog("Initial value = " & FORMAT$(sngValue))
  '
  ' late binding
  LOCAL hProc AS DWORD
  LOCAL ascFunction AS ASCIIZ * 100
  '
  ' name of the function to be called
  ascFunction = "funHalf_A_Value"
  '
  ' late binding to DLL
  LOCAL hLib AS DWORD    ' library handle
  ' load the library into memory
  hLib = LoadLibrary("SimpleDLL.dll")
  '
  IF hLib <> 0 THEN
    ' if library is loaded
    ' get the address of the function
    ' we want to call
    hProc = GetProcAddress(hLib, ascFunction)
    IF hProc <> 0 THEN
    ' we've got the address to call the function
    ' within the loaded DLL
      CALL DWORD hProc USING funGetValue(sngValue) TO sngNewValue
      funLog("New Value = " & FORMAT$(sngNewValue))
    ELSE
      funLog("Unable to find the function in the DLL")
    END IF
    '
  ELSE
    funLog("Unable to load library")
  END IF
  '
  ' free up the library when finished with it
  FreeLibrary(hLib)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funSaveResource(strFilename AS STRING, _
                         lngHandle AS LONG) AS LONG
' Save the resource to disk
  LOCAL lngFreeFile AS LONG  ' file handle
  LOCAL strData AS STRING    ' string for resource
  '
  TRY
  ' save resource file
    strData  = RESOURCE$(RCDATA, lngHandle)
    lngFreeFile = FREEFILE
    OPEN strFilename FOR OUTPUT AS lngFreeFile
    PRINT# lngFreeFile, strData  ;
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE lngFreeFile
  END TRY
  '
END FUNCTION
'
FUNCTION funCheckHashValue(strFilename AS STRING, _
                           lngHandle AS LONG) AS LONG
' check the hash value of the file
  LOCAL strFileHash AS STRING
  strFileHash = funGetSHA(strFilename)
  funlog("File Hash     = " & strFileHash)
  '
  ' get the string the resource
  LOCAL strResource AS STRING
  strResource  = RESOURCE$(RCDATA, lngHandle)
  '
  ' determine the hash using library functions
  LOCAL strResourceHash AS STRING
  LOCAL SHA1 AS SHA
  CalcSHA strResource, SHA1
  strResourceHash = SHABase16ToBase32(tSHA(SHA1))
  funLog("Resource Hash = " & strResourceHash )                          '
  '
  IF strFileHash <> strResourceHash THEN
    FUNCTION = %FALSE
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
