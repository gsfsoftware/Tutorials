' PB_INI_Files.inc
'
' index to functions
' funDelete_INI_Partname - delete just a partname from an INI file
' funDelete_INI_Section - delete a section from an INI file
' funRead_INI_Data - read data from an INI file, quoting section & partname
' funReadTheINIFileIntoAnArray - read an INI file into a 1D array
' funSaveINIStringAsFile - save a string as an INI file
' funWrite_Ini_Data - write to INI file, quoting section & partname


FUNCTION funRead_INI_Data( strIniFile AS STRING, _
                           strSection AS STRING, _
                           strPartName AS STRING, _
                           strDefault AS STRING) AS STRING
' read data from an INI file
  '
  ' does INI file exist?
  IF ISFALSE ISFILE(strIniFile) THEN
    EXIT FUNCTION
  END IF
  '
  LOCAL lngResult  AS LONG
  LOCAL zSection   AS ASCIIZ * 125
  LOCAL zPartname  AS ASCIIZ * 125
  LOCAL zData      AS ASCIIZ * 150
  LOCAL zDefault   AS ASCIIZ * 150
  LOCAL zIniFile   AS ASCIIZ * 255
  '
  zSection   = strSection
  zPartname  = strPartName
  zIniFile   = strIniFile
  zDefault   = strDefault
  '
  lngResult = GetPrivateProfileString(zSection,_
                                      zPartname,_
                                      zDefault,_
                                      zData,_
                                      SIZEOF(zData),_
                                      zIniFile)
  FUNCTION = zData
  '
END FUNCTION
'
FUNCTION funWrite_Ini_Data(strIniFile AS STRING, _
                           strSection AS STRING, _
                           strPartname AS STRING, _
                           strValue AS STRING) AS LONG
' write to an INI file
'
  ' does INI file exist?
  IF ISFALSE ISFILE(strIniFile) THEN
    EXIT FUNCTION
  END IF
  '
  LOCAL zSection   AS ASCIIZ * 125
  LOCAL zPartname  AS ASCIIZ * 125
  LOCAL zValue     AS ASCIIZ * 150
  LOCAL zIniFile   AS ASCIIZ * 255
  '
  zSection  = strSection
  zPartname = strPartname
  zIniFile  = strIniFile
  zValue    = strValue
  '
  FUNCTION = WritePrivateProfileString(zSection,_
                                       zPartname,_
                                       zValue,_
                                       zIniFile)
END FUNCTION
'
FUNCTION funDelete_INI_Section(strIniFile AS STRING, _
                                BYVAL strSection AS STRING) AS LONG
' delete an entire section of the INI file
  LOCAL strFile AS STRING
  LOCAL strValue AS STRING
  LOCAL lngR AS LONG
  LOCAL strLocalSection AS STRING
  DIM a_strINI() AS STRING
  '
  ' does INI file exist?
  IF ISFALSE ISFILE(strIniFile) THEN
    EXIT FUNCTION
  END IF
  '
  ' lose any []
  strSection = UNWRAP$(strSection,"[","]")
  '
  ' read file into array
  IF ISTRUE funReadTheINIFileIntoAnArray(strIniFile, a_strINI()) THEN
  ' now sweep through and mark anything to be deleted
    FOR lngR = LBOUND(a_strINI) TO UBOUND(a_strINI)
      IF LEFT$(a_strINI(lngR),1) = "[" THEN
      ' pick up the local section name
        strLocalSection = LCASE$(UNWRAP$(a_strINI(lngR),"[","]"))
        '
        IF LCASE$(strSection) = strLocalSection THEN
        ' blank out the section line
          a_strINI(lngR) = ""
        END IF
        '
      ELSE
      ' partname line
        IF LCASE$(strSection) = strLocalSection THEN
        ' blank out the section line
          a_strINI(lngR) = ""
        END IF
        '
      END IF
    NEXT lngR
    '
    ' now write out the array to file minus any blank rows
    strFile = ""
    FOR lngR = LBOUND(a_strINI) TO UBOUND(a_strINI)
      IF a_strINI(lngR) <> "" THEN
        strFile = strFile & a_strINI(lngR) & $CRLF
      END IF
    NEXT lngR
    '
    strFile = RTRIM$(strFile,$CRLF)
    '
    FUNCTION = funSaveINIStringAsFile(strIniFile, _
                                      strFile)
    '
  ELSE
  ' unable to load the INI file
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funDelete_INI_Partname(strIniFile AS STRING, _
                                BYVAL strSection AS STRING, _
                                strPartName AS STRING) AS LONG
' delete a part of the INI file
  LOCAL strFile AS STRING
  LOCAL strValue AS STRING
  LOCAL lngR AS LONG
  LOCAL strLocalSection AS STRING
  DIM a_strINI() AS STRING
  '
  ' does INI file exist?
  IF ISFALSE ISFILE(strIniFile) THEN
    EXIT FUNCTION
  END IF
  '
  ' lose any []
  strSection = UNWRAP$(strSection,"[","]")
  '
  ' read file into array
  IF ISTRUE funReadTheINIFileIntoAnArray(strIniFile, a_strINI()) THEN
  ' now sweep through and mark anything to be deleted
    FOR lngR = LBOUND(a_strINI) TO UBOUND(a_strINI)
      IF LEFT$(a_strINI(lngR),1) = "[" THEN
      ' pick up the local section name
        strLocalSection = LCASE$(UNWRAP$(a_strINI(lngR),"[","]"))
      ELSE
        IF LCASE$(strSection) <> strLocalSection THEN ITERATE
        ' must be in section needed
        IF LCASE$(PARSE$(a_strINI(lngR),"=",1)) = LCASE$(strPartName) THEN
        ' found the part - so blank it out
          a_strINI(lngR) = ""
        END IF
        '
      END IF
    NEXT lngR
    '
    ' now write out the array to file minus any blank rows
    strFile = ""
    FOR lngR = LBOUND(a_strINI) TO UBOUND(a_strINI)
      IF a_strINI(lngR) <> "" THEN
        strFile = strFile & a_strINI(lngR) & $CRLF
      END IF
    NEXT lngR
    '
    strFile = RTRIM$(strFile,$CRLF)
    '
    FUNCTION = funSaveINIStringAsFile(strIniFile, _
                                      strFile)
    '
  ELSE
  ' unable to load the INI file
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funSaveINIStringAsFile(strFile AS STRING, _
                                strData AS STRING) AS LONG
' save a string to a file
  LOCAL lngFile AS LONG
  '
  lngFile = FREEFILE
  TRY
    OPEN strFile FOR OUTPUT LOCK SHARED AS #lngFile
    PRINT #lngFile, strData
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funReadTheINIFileIntoAnArray(strFilename AS STRING, _
                                      BYREF a_strWork() AS STRING) AS LONG
' Read the file into an array
  LOCAL lngFile AS LONG
  LOCAL lngRecords AS LONG

  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    REDIM a_strWork(1 TO lngRecords) AS STRING
    LINE INPUT #lngFile,a_strWork()
    FUNCTION = %TRUE
  CATCH
    #IF %DEF(%PB_CC32)
      CON.STDOUT ERROR$
    #ENDIF
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
