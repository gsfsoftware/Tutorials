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
  RANDOMIZE TIMER ' see the random number generator
  '
  LOCAL strStartFile AS STRING
  ' set the name and path to start file
  strStartFile = EXE.PATH$ & "Testfile.txt"
  '
  IF ISTRUE funCreateAfile(strStartFile, 300) THEN
  ' scan the file
    funLog(funRunFileScan(EXE.PATH$ & "Testfile.txt"))
    '
    ' Name - rename a file
    LOCAL strNewFile AS STRING
    strNewFile = EXE.PATH$ & "NewTestfile.txt"
    '
    TRY
    ' attempt to delete the new filename
      KILL strNewFile
    CATCH
    FINALLY
    END TRY
    '
    TRY
      NAME strStartFile AS strNewFile
      funLog("File renamed successfully")
    CATCH
      funLog("Unable to rename file - " & ERROR$)
    FINALLY
    END TRY
    '
    ' Name - rename and move a file
    IF ISFALSE ISFOLDER(EXE.PATH$ & "Data") THEN
    ' first make a sub folder
      MKDIR EXE.PATH$ & "Data"
    END IF
    '
    ' set name of source and destination file
    strStartFile = EXE.PATH$ & "NewTestfile.txt
    strNewFile   = EXE.PATH$ & "Data\NewTestfile2.txt"
    '
    TRY
    ' attempt to delete the new filename
      KILL strNewFile
    CATCH
    FINALLY
    END TRY
    '
    TRY
    ' move and rename the file
      NAME strStartFile AS strNewFile
      funLog("File renamed and moved successfully")
    CATCH
      funLog("Unable to rename/move file - " & ERROR$)
    FINALLY
    END TRY
    '
  ELSE
  ' unable to create file?
  '
  END IF
  '
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funRunFileScan(strFile AS STRING) AS STRING
' run a scan on the file and report on rows
  LOCAL lngFile AS LONG
  LOCAL lngRowCount AS LONG
  LOCAL strResult AS STRING
  LOCAL lngWidestString AS LONG
  '
  lngFile = FREEFILE
  '
  TRY
    OPEN strFile FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRowCount , _
              WIDTH TO lngWidestString
    '
    strResult = "File " & PARSE$(strFile,"\",-1) & " has " & _
                 FORMAT$(lngRowCount) & " rows" & _
                 " - Widest string = " & FORMAT$(lngWidestString)
  CATCH
    strResult = "An error occurred " & ERROR$
  FINALLY
    CLOSE #lngFile
  END TRY
  '
  FUNCTION = strResult
  '
END FUNCTION
'
FUNCTION funCreateAfile(strFilename AS STRING, _
                        lngRows AS LONG) AS LONG
  ' create a file in the current directory
  ' with lngRows of random data
  '
  LOCAL lngFileOut AS LONG
  LOCAL lngR AS LONG
  '
  lngFileOut = FREEFILE
  TRY
    OPEN strFilename FOR OUTPUT AS #lngFileOut
    funLog("File created successfully")
    '
    FOR lngR = 1 TO lngRows
    ' print a random number from 1- 1000
      PRINT #lngFileOut, RND(1,1000)
    NEXT lngR
    '
    FUNCTION = %TRUE
    '
  CATCH
    funLog("Error creating file - error = " & ERROR$)
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFileOut
  END TRY
  '
END FUNCTION
