'==============================================================================
' Example of how to create a zip file using Windows built in ZIP capabilities
'   Created by William Burns using PB 9.00 on 09/03/2008
'
'   Note:  Requires at least Windows XP or any newer version
'   amended 15/01/2022 to take command line parameters and
'                      handle error logging - GsfSoftware
'==============================================================================

#COMPILE EXE
#DIM ALL

#INCLUDE "WinShell.inc"  'created by the PowerBasic Com browser on Shell32 lib
#INCLUDE "..\Libraries\PB_CommandLine.inc"
'
' command line parameters that can be passed to this app
'
' /SOURCE#"E:\ZipTesting\ZipTest"
' /DEST#"E:\ZipTesting\ZipOutput\MyNewZip.ZIP"
' /LOG#"E:\ZipTesting\ZipLog.txt"
'
%TRUE  = 1
%FALSE = 0
'
FUNCTION PBMAIN () AS LONG
  LOCAL hFile     AS DWORD
  ' Object Variables
  LOCAL oShellClass     AS IShellDispatch
  LOCAL oSourceFolder   AS Folder
  LOCAL oTargetFolder   AS Folder
  LOCAL oItems          AS FolderItems
  ' variants
  LOCAL vSourceFolder   AS VARIANT
  LOCAL vTargetFolder   AS VARIANT
  LOCAL vOptions        AS VARIANT
  '
  LOCAL strCommand      AS STRING   ' for command line parameters
  LOCAL strDestination  AS STRING   ' Path to and name of Zipped output
  LOCAL strSourceFolder AS STRING   ' Path to and name of sourceFolder
  LOCAL strLogFile      AS STRING   ' Optional Path to and name of log file
  LOCAL strErrText      AS STRING   ' Holds text of error generated
  '
  strCommand = COMMAND$             ' capture command line
  '
  ' pick up the command line parameters
  strSourceFolder = funReturnNamedParameterEXP("/SOURCE#", _
                                             strCommand)
  strDestination = funReturnNamedParameterEXP("/DEST#", _
                                             strCommand)
  strLogFile = funReturnNamedParameterEXP("/LOG#", _
                                             strCommand)
  '
  'First create a empty ZIP file using a standard zip file header
  TRY
    hFile = FREEFILE
    OPEN strDestination FOR OUTPUT AS #hFile
    PRINT #hFile, CHR$(80,75,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    CLOSE #hFile
    '
  CATCH
  '
    strErrText = "Error creating Zip file."
   #IF %DEF(%PB_CC32)
     CON.STDOUT strErrText & ERROR$(ERR)
   #ELSE
     MSGBOX strErrText & $CRLF & _
             ERROR$(ERR),%MB_ICONERROR,"Zip Error"
   #ENDIF
   '
   strErrText = strErrText & " " & strDestination
   funLog(strLogFile,strErrText)
   EXIT FUNCTION
   '
  END TRY
  '
  ' Get an instance of our Windows Shell
  oShellClass = ANYCOM $PROGID_SHELL32_SHELL
   ' Did we get the object? If not, terminate this app
  IF ISFALSE ISOBJECT(oShellClass) OR ERR THEN
    strErrText = "Could not get the Windows Shell object."
    #IF %DEF(%PB_CC32)
      CON.STDOUT strErrText & ERROR$(ERR)
    #ELSE
      MSGBOX strErrText & $CRLF & _
               ERROR$(ERR),%MB_ICONERROR,"Zip Error"
    #ENDIF
    '
    funLog(strLogFile,strErrText)
    '
    EXIT FUNCTION
  END IF
  '
  'assign the source folder we want to zip up
  vSourceFolder = strSourceFolder
  oSourceFolder = oShellClass.NameSpace(vSourceFolder)
  '
  IF ISFALSE ISOBJECT(oSourceFolder) OR ERR THEN
    strErrText = "Could not get the Source folder object."
    #IF %DEF(%PB_CC32)
      CON.STDOUT strErrText
    #ELSE
      MSGBOX strErrText & $CRLF & "Error: " _
             ,%MB_ICONERROR,"Zip Error"
    #ENDIF
    '
    funLog(strLogFile,strErrText)
    '
  ELSE
  ' assign the target folder we want to create
  ' (in this case it is a zip file)
    vTargetFolder = strDestination
    oTargetFolder = oShellClass.NameSpace(vTargetFolder)
    '
    strErrText = "Could not get the Target folder object."
    IF ISFALSE ISOBJECT(oTargetFolder) OR ERR THEN
      #IF %DEF(%PB_CC32)
         CON.STDOUT strErrText & ERROR$(ERR)
      #ELSE
         MSGBOX strErrText & $CRLF & "Error: " & _
                ERROR$(ERR), %MB_ICONERROR,"Zip Error"
      #ENDIF
      '
      funLog(strLogFile,strErrText)
      '
    ELSE
    '  assign all the items in the source folder
    '  to the Items object
      oItems = oSourceFolder.Items()
      IF ISFALSE ISOBJECT(oItems) OR ERR THEN
       strErrText = "Could not get the Items object."
       #IF %DEF(%PB_CC32)
          CON.STDOUT strErrText & ERROR$(ERR)
       #ELSE
         MSGBOX strErrText & $CRLF & "Error: " & _
                ERROR$(ERR),%MB_ICONERROR,"Zip Error"
       #ENDIF
       '
       funLog(strLogFile,strErrText)
       '
     ELSE
     '
     'now we start the copy in to the new zip file
     ' options (4) = Do not display a progress dialog box.
     '         (16) = Respond with "Yes to All" for any
     '                dialog box that is displayed.
     ' https://docs.microsoft.com/en-us/windows/win32/shell/folder-copyhere
       vOptions = 20
       oTargetFolder.CopyHere(oItems, vOptions)
       '
       IF ERR THEN
         strErrText = "An Error occurred during the CopyHere method."
         #IF %DEF(%PB_CC32)
            CON.STDOUT strErrText & ERROR$(ERR)
         #ELSE
           MSGBOX strErrText & $CRLF & "Error: " _
                  & ERROR$(ERR), %MB_ICONERROR,"Zip Error"
         #ENDIF
         '
         funLog(strLogFile,strErrText)
         '
       ELSE
       'NOTE:  the above copyhere method starts a seperate thread to do the copy
       ' No notification is given to the calling program to indicate that the copy
       ' has completed.
       '
         SLEEP 2000 ' increase where needed
         funLog(strLogFile,"Completed " & strDestination)
         '
       END IF
     END IF
     '
    END IF
  END IF
  '
  ' Close all of the Interfaces
  oItems = NOTHING
  oTargetFolder  = NOTHING
  oSourceFolder  = NOTHING
  oShellClass  = NOTHING
  '
END FUNCTION
'
FUNCTION funLog(strLogFile AS STRING, _
                strText AS STRING) AS LONG
' write to log file if it has been specified
  LOCAL strDateTime AS STRING
  '
  IF strLogFile <> "" THEN
  ' get the date and time
    strDateTime = funUKDate & " " & TIME$ & " "
    '
    FUNCTION = funAppendToFile(strLogFile, _
                       strDateTime & strText)
  END IF
'
END FUNCTION
'
FUNCTION funAppendToFile(strFilePathToAddTo AS STRING, _
                         strData AS STRING) AS LONG
' append strData to the file if it exists or create a new one if it doesn't
  LOCAL lngFile AS LONG
  LOCAL strError AS STRING
  '
  lngFile = FREEFILE
  TRY
   IF ISTRUE ISFILE(strFilePathToAddTo) THEN
      OPEN strFilePathToAddTo FOR APPEND LOCK SHARED AS #lngFile
    ELSE
      OPEN strFilePathToAddTo FOR OUTPUT AS #lngFile
    END IF
    '
    PRINT #lngFile, strData
    '
    FUNCTION = %TRUE
  CATCH
    strError = ERROR$   ' trap error for debug purposes
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funUKDate AS STRING
' return the current date in dd/mm/yyyy UK format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = MID$(strDate,4,2) & "/" & _
             LEFT$(strDate,2) & "/" & _
             RIGHT$(strDate,4)
END FUNCTION
