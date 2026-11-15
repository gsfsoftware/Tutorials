' PB_Txt_ConfigFile.inc
'
' Loading configuration information from text files
'
' Index to functions
' funTxtCfg_GetValue - return the value of a specified text config item
' funTxtCfg_LoadFile - load a specified config text file
' funTxtCfg_PutValue - replace a value in an existing config item
' funTxtCfg_SaveFile - save a loaded config file to disk

' ensure the File handling routines library is already loaded
' global array to hold Text Configuration info
GLOBAL g_a_strTxtConfiguration() AS STRING
'
%Item  = 1    ' item slot
%Value = 2    ' value slot
'
FUNCTION funTxtCfg_LoadFile(strFile AS STRING) AS LONG
' load a text config file to array
  FUNCTION = funReadTheCSVFileIntoAnArray(strFile, _
                                          BYREF g_a_strTxtConfiguration())
END FUNCTION
'
FUNCTION funTxtCfg_GetValue(strItem AS STRING) AS STRING
' return the string held for this item
  LOCAL lngRow AS LONG
  LOCAL strValue AS STRING
  '
  FOR lngRow = 1 TO UBOUND(g_a_strTxtConfiguration)
    IF LCASE$(g_a_strTxtConfiguration(lngRow,%Item)) = LCASE$(strItem) THEN
      strValue = g_a_strTxtConfiguration(lngRow,%Value)
      FUNCTION = strValue
      EXIT FUNCTION
    END IF
  NEXT lngRow
  '
  FUNCTION = strValue
'
END FUNCTION
'
FUNCTION funTxtCfg_PutValue(strItem AS STRING, _
                            strNewValue AS STRING) AS LONG
' save a new value to the array
   LOCAL lngRow AS LONG
  '
  FOR lngRow = 1 TO UBOUND(g_a_strTxtConfiguration)
    IF LCASE$(g_a_strTxtConfiguration(lngRow,%Item)) = LCASE$(strItem) THEN
    ' found a match
      g_a_strTxtConfiguration(lngRow,%Value) = strNewValue
      FUNCTION = %TRUE
      EXIT FUNCTION
    END IF
  NEXT lngRow
  '
END FUNCTION
'
FUNCTION funTxtCfg_SaveFile(strFile AS STRING) AS LONG
' save a specifed text config file to disk
  FUNCTION = funSaveTheArrayToCsvFile(strFile, _
                                      BYREF g_a_strTxtConfiguration())
END FUNCTION
