#COMPILE EXE
#DIM ALL
' display dialogs part 1
'
FUNCTION PBMAIN () AS LONG
'
' DISPLAY BROWSE
  LOCAL strFolderPicked AS STRING
  strFolderPicked = funDisplay_Browse()
  '
  MSGBOX "Folder = " & strFolderPicked ,%MB_OK,"Folder Selected"
'
'
' DISPLAY OPENFILE
  LOCAL lngFileCount AS LONG     ' count of files selected
  LOCAL strFiles AS STRING       ' path & file name/s returned
  strFiles = funOpenFile(lngFileCount)
  '
  MSGBOX "File list = " & $CRLF & _
         funReturnFileList(lngFileCount,strFiles)
'
'
' DISPLAY SAVEFILE
  LOCAL strFileToSave AS STRING
  strFileToSave = "TestFile.txt"  ' default name of file
  LOCAL strFilePath AS STRING     ' path & file name/s returned
  '
  strFilePath = funSaveFile(strFileToSave, lngFileCount)
  MSGBOX "File list = " & $CRLF & _
         funReturnFileList(lngFileCount,strFilePath)
'
END FUNCTION
'
FUNCTION funSaveFile(strFileToSave AS STRING, _
                     o_lngFileCount AS LONG) AS STRING
' save the file to a specific location
  LOCAL hParent AS DWORD           ' the parent dialog
                                   ' X & Y position is relative to
                                   ' parent dialog
  LOCAL lngXpos AS LONG            ' the horizontal position
  LOCAL lngYpos AS LONG            ' the vertical position
  LOCAL strTitle AS STRING         ' the title of the dialog
  LOCAL strInitialFolder AS STRING ' initial folder start point
  LOCAL strFilter AS STRING        ' filter for files that can be
                                   ' selected
  LOCAL strDefaultExtension AS STRING ' default extension
  LOCAL lngFlags AS LONG           ' the style attributes of the dialog
  LOCAL strFiles AS STRING         ' path plus name of file or files
                                   ' selected
  LOCAL lngFilesSelected AS LONG   ' number of files selected
  '
  hParent = %HWND_DESKTOP          ' parent set to be the desktop
  lngXpos = 50                     ' set location of dialog
  lngYpos = 50
  strTitle = "Please select a File saving location"
  strInitialFolder = EXE.PATH$
  strFilter = "Text" & CHR$(0) & "*.TXT" + CHR$(0)
  strDefaultExtension = "TXT"
  lngFlags = %OFN_OVERWRITEPROMPT
  '
  ' prompt user for file/s to save
  DISPLAY SAVEFILE hParent, lngXpos, lngYpos, strTitle, _
                   strInitialFolder, strFilter, _
                   strFileToSave, strDefaultExtension, _
                   lngFlags TO strFiles ,lngFilesSelected
                   '
  o_lngFileCount = lngFilesSelected
  FUNCTION = strFiles
  '
END FUNCTION
'
FUNCTION funReturnFileList(lngFileCount AS LONG, _
                           strFiles AS STRING) AS STRING
' return a list of files selected
  IF lngFileCount = 1 THEN
  ' single file selected
    FUNCTION = strFiles
    '
  ELSEIF lngFileCount > 1 THEN
  ' multiple files selected
    LOCAL lngR AS LONG          ' parameter counter
    LOCAL strPath AS STRING     ' path to files
    LOCAL strFileList AS STRING ' list of files with their
                                ' paths
    ' store the path to the file/s
    strPath = PARSE$(strFiles,CHR$(0),1)
    strFileList = ""
    FOR lngR = 2 TO lngFileCount +1
    ' for each file returned
    ' build up a list of files with their path
      strFileList = strFileList & strPath & "\" & _
                    PARSE$(strFiles,CHR$(0),lngR) & $CRLF
                    '
    NEXT lngR
    '
    FUNCTION = strFileList
  '
  END IF
  '
END FUNCTION
'
FUNCTION funOpenFile(o_lngFileCount AS LONG) AS STRING
' present user with an open file dialog
'
  LOCAL hParent AS DWORD           ' the parent dialog
                                   ' X & Y position is relative to
                                   ' parent dialog
  LOCAL lngXpos AS LONG            ' the horizontal position
  LOCAL lngYpos AS LONG            ' the vertical position
  LOCAL strTitle AS STRING         ' the title of the dialog
  LOCAL strInitialFolder AS STRING ' initial folder start point
  LOCAL strFilter AS STRING        ' filter for files that can be
                                   ' selected
  LOCAL strStart AS STRING         ' starting file name
  LOCAL strDefaultExtension AS STRING ' default extension
  LOCAL lngFlags AS LONG           ' the style attributes of the dialog
  LOCAL strFiles AS STRING         ' path plus name of file or files
                                   ' selected
  LOCAL lngFilesSelected AS LONG   ' number of files selected
  '
  hParent = %HWND_DESKTOP          ' parent set to be the desktop
  lngXpos = 50                     ' set location of dialog
  lngYpos = 50
  strTitle = "Please select a File"
  strInitialFolder = EXE.PATH$
  '
  strFilter = "BASIC" & CHR$(0) & "*.BAS" + CHR$(0)
  '  OR use
  'strFilter = CHR$("BASIC", 0, "*.BAS", 0)
  ' OR use
  'strFilter = CHR$("BASIC", 0, "*.BAS;*.INC;*.BAK", 0)
  '
  strStart = ""
  strDefaultExtension = ""
  '
  lngFlags = %OFN_FILEMUSTEXIST OR %OFN_ALLOWMULTISELECT
  '
  ' prompt user for file/s to open
  DISPLAY OPENFILE hParent, lngXpos, lngYpos, strTitle, _
                   strInitialFolder, strFilter, strStart, _
                   strDefaultExtension, lngFlags _
                   TO strFiles ,lngFilesSelected
                   '
  ' return the number of files selected
  ' and the path/name
  o_lngFileCount = lngFilesSelected
  FUNCTION = strFiles
  '
END FUNCTION
'
FUNCTION funDisplay_Browse() AS STRING
' present user with folder selection dialog
' and return folder selected
  LOCAL hParent AS DWORD           ' the parent dialog
                                   ' X & Y position is relative to
                                   ' parent dialog
  LOCAL lngXpos AS LONG            ' the horizontal position
  LOCAL lngYpos AS LONG            ' the vertical position
  LOCAL strTitle AS STRING         ' the title of the dialog
  LOCAL strStartPath AS STRING     ' the starting folder path
  LOCAL lngFlags AS LONG           ' the style attributes of the dialog
  LOCAL strFolderPicked AS STRING  ' the folder selected
  '
  hParent = %HWND_DESKTOP
  lngXpos = 50
  lngYpos = 50
  strTitle = "Please select a Folder"
  strStartPath = EXE.PATH$
  lngFlags = %BIF_NEWDIALOGSTYLE '_
            ' or %BIF_NONEWFOLDERBUTTON
  '
  DISPLAY BROWSE hParent, lngXpos, lngYpos, strTitle, _
                          strStartPath, lngFlags TO strFolderPicked
                          '
  FUNCTION = strFolderPicked
  '
END FUNCTION
