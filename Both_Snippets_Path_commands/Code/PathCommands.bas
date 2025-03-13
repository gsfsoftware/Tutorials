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
  funPrepOutput("Path commands",0,0,40,120)
  '
  funLog("Path commands")
  '
  ' PathName$
  ' parse a file name or path & filename
  ' without the file needing to exist in a
  ' storage medium
  '
  LOCAL strFile AS STRING
  '
  strFile = "X:\FirstFolder\Sub_Folder\a_file.txt"
  '
  funLog("PathName:")
  funPathName(strFile)
  '
  ' PathScan$
  ' search for a named file and parse
  ' what is returned
  funLog($CRLF & "PathName:")
  strFile = "PathCommands.bas"
  LOCAL strPathSpecification AS STRING
  ' set the path to search
  strPathSpecification = EXE.PATH$
  ' scan for the file
  funPathScan(strFile,strPathSpecification)
  '
  funLog($CRLF & "PathName:")
  ' convert paths if they are mapped drives.
  strPathSpecification = _
        funPath2UNC(EXE.PATH$) & ";" & _
        funPath2UNC("H:\Youtube\PowerBasic\Both_Snippets_" & _
                  "Path_commands\Code\SubFolder_1")
  strFile = "Test_File.txt"
  '
  funPathScan(strFile,strPathSpecification)
  '
  funLog($CRLF & "PathName mapped URL:")
  strPathSpecification = _
            "Z:"
  strFile = "Test_File.txt"
  ' convert mapped drive to UNC
  strPathSpecification = funPath2UNC(strPathSpecification)
  ' scan for the file
  funPathScan(strFile,strPathSpecification)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funPath2UNC (BYVAL strInputPath AS STRING) AS STRING
' take an input path and return the UNC
' (Universal Naming Convention) version of this
'
  LOCAL pUni AS UNIVERSAL_NAME_INFO PTR
  LOCAL az AS ASCIIZ * %MAX_PATH
  LOCAL lngR AS LONG
  pUni = VARPTR(az)
  '
  LOCAL strOutput AS STRING
  '
  WNetGetUniversalName BYVAL STRPTR(strInputPath), _
                       %UNIVERSAL_NAME_INFO_LEVEL, _
                       BYVAL pUni, %MAX_PATH TO lngR
  strOutput = @pUni.@lpUniversalName
  '
  IF strOutput = "" THEN
  ' it's not a mapped drive
  ' so return the input path
    FUNCTION = strInputPath
  ELSE
  ' is is a mapped drive so return
  ' the true path
    FUNCTION = strOutput
  END IF
  '
END FUNCTION
'
FUNCTION funPathScan(strFile AS STRING, _
                     strPathSpecification AS STRING) AS LONG
' scan for the file and report
'
' Path specification is optional parameter
' if not given or if is zero length string then
' the directories searched, as below are searched
' until a match is found
' note that the search is not recursive
'
' 1. The directory from which the application was loaded.
' 2. The current directory.  As returned by CURDIR$
' 3. The Windows System32 directory.
' 4. The Windows System16 directory.
' 5. The Windows directory.
' 6. The directories in the PATH environment variable.
'
  LOCAL strValue AS STRING
  strValue = PATHSCAN$(FULL,strFile,strPathSpecification)
  funLog("Full = " & strValue)
  '
  strValue = PATHSCAN$(PATH,strFile,strPathSpecification)
  funLog("Path = " & strValue)
  '
  strValue = PATHSCAN$(NAME,strFile,strPathSpecification)
  funLog("Name = " & strValue)
  '
  strValue = PATHSCAN$(EXTN,strFile,strPathSpecification)
  funLog("Extn = " & strValue)
  '
  strValue = PATHSCAN$(NAMEX,strFile,strPathSpecification)
  funLog("NameX = " & strValue)
  '
END FUNCTION
'
FUNCTION funPathName(strFile AS STRING) AS LONG
' parse out the parts of a file name/path
  LOCAL strValue AS STRING
  strValue = PATHNAME$(FULL,strFile)
  funLog("Full = " & strValue)
  '
  strValue = PATHNAME$(PATH,strFile)
  funLog("Path = " & strValue)
  '
  strValue = PATHNAME$(NAME,strFile)
  funLog("Name = " & strValue)
  '
  strValue = PATHNAME$(EXTN,strFile)
  funLog("Extn = " & strValue)
  '
  strValue = PATHNAME$(NAMEX,strFile)
  funLog("NameX = " & strValue)
'
END FUNCTION
