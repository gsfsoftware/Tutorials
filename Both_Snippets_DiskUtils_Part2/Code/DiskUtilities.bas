#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Disk Utilities",0,0,40,120)
  '
  funLog("Disk Utilities")
  '
  ' does a folder exist
  IF ISFALSE ISFOLDER(EXE.PATH$ & "SubFolder") THEN
  ' folder does not already exist
    TRY
    ' attempt to create the sub folder
      MKDIR EXE.PATH$ & "SubFolder"
      funLog("Subfolder created")
    CATCH
      funLog("Subfolder not created - error = " & ERROR$)
    FINALLY
    END TRY
  '
  ELSE
  ' folder already exists
    funLog("Subfolder already exists")
    '
'    try
'    ' attempt to delete the sub folder
'      rmdir exe.path$ & "Subfolder"
'      funLog("Subfolder deleted")
'    catch
'      funLog("Subfolder not deleted - error = " & ERROR$)
'    finally
'    end try
  END IF
  '
  ' create a file in the current directory
  funCreateAfile("TestFile.txt")
  '
  TRY
    KILL "TestFile.txt"
    funLog("File deleted successfully")
  CATCH
    funLog("Error deleting file - error = " & ERROR$)
  FINALLY
  END TRY
  '
  TRY
    CHDIR "SubFolder"
    funLog("Changed default to Subfolder")
    funLog("Current directory = " & CURDIR$)
  CATCH
    funLog("Unable to change to Subfolder - error = " & ERROR$)
  FINALLY
  END TRY
  '
  ' create a file in the current directory
  funCreateAfile("TestFile2.txt")
  '
  TRY
  ' change the current drive
    CHDRIVE "G"
    funLog("Changed to new drive")
    funLog("Current directory = " & CURDIR$)
  CATCH
    funLog("Unable to change drive - error = " & ERROR$ )
  FINALLY
  END TRY
  '
  funCreateAfile("TestFile3.txt")
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
  CATCH
    funLog("Error creating file - error = " & ERROR$)
  FINALLY
    CLOSE #lngFileOut
  END TRY
  '
END FUNCTION
'
