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
  funPrepOutput("Disk Utilities",0,0,40,120)
  '
  funLog("Disk Utilities")
  '
  ' create a file
  IF ISFALSE funCreateAfile("TextFile.txt") THEN
    funWait()
    EXIT FUNCTION
  END IF
  '
  ' Does the source file exist?
  IF ISTRUE ISFILE(EXE.PATH$ & "TextFile.txt") THEN
    funLog("File found")
    '
    IF ISTRUE ISFOLDER(EXE.PATH$ & "SubFolder") THEN
    ' sub folder already exists
      funLog("Sub Folder already exists")
    ELSE
    ' not found so create the sub folder
      funLog("Sub Folder does not exist")
      '
      TRY
        MKDIR EXE.PATH$ & "SubFolder"
        funLog("Created the sub folder")
      CATCH
        funLog("Unable to create the sub folder")
        funWait()
        EXIT FUNCTION
      FINALLY
      END TRY
      '
    END IF
    '
    ' attempt to wipe the destination file
    TRY
      KILL EXE.PATH$ & "SubFolder\TextFile.txt"
      funLog("Destination File wiped")
    CATCH
      funLog("Destination file not wiped -> " & ERROR$)
    FINALLY
    END TRY
    '
    ' attempt to copy file to destination
    TRY
      FILECOPY EXE.PATH$ & "TextFile.txt", _
               EXE.PATH$ & "SubFolder\TextFile.txt"
      funLog("File copied")
    CATCH
      funLog ("Unable to copy file -> " & ERROR$)
    FINALLY
    END TRY
    '
    ' determine attribute of the file
    LOCAL lngAttribute AS LONG
    lngAttribute = GETATTR(EXE.PATH$ & "SubFolder\TextFile.txt")
    '
    IF (lngAttribute AND 1&) = 1& THEN
      funLog("File is Read-only")
    ELSE
      funLog("File is not Read-only")
    END IF
    '
    ' set the attribute of a file
    SETATTR EXE.PATH$ & "SubFolder\TextFile.txt" , %READONLY
    '
    lngAttribute = GETATTR(EXE.PATH$ & "SubFolder\TextFile.txt")
    IF (lngAttribute AND 1&) = 1& THEN
      funLog("File is Read-only")
    ELSE
      funLog("File is not Read-only")
    END IF
    '
  ELSE
    funLog("File does not exist")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funCreateAfile(strFilename AS STRING) AS LONG
  ' create a file in the current directory
  LOCAL lngFileOut AS LONG
  '
  lngFileOut = FREEFILE
  TRY
    OPEN strFilename FOR OUTPUT AS #lngFileOut
    funLog("File created successfully")
    FUNCTION = %TRUE
  CATCH
    funLog("Error creating file - error = " & ERROR$)
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFileOut
  END TRY
  '
END FUNCTION
