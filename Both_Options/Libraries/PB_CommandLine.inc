' PB_CommandLine.inc

FUNCTION funReturnNamedParameterEXP(strName AS STRING, _
                                    strCommand AS STRING) AS STRING
' return the named parameter where strCommand is in the form
' /D#"01/06/2004" /T#"22:00" /P#"*.*"
' where strName = /D#
  LOCAL str_funRNP_EXP_Result AS STRING
  LOCAL lng_funReturnNamedParameterEXP_Start AS LONG
  LOCAL strLocalCommand AS STRING
  '
  ' store local, case independant, version of command string
  strLocalCommand = UCASE$(strCommand)
  '
  ' now return the parameter where the strName
  ' is a case independant search
  strName = UCASE$(strName)
  '
  lng_funReturnNamedParameterEXP_Start = _
                    INSTR(strLocalCommand,strName)
  '
  IF lng_funReturnNamedParameterEXP_Start > 0 THEN
  ' only if a match has been found
    str_funRNP_EXP_Result = _
              MID$(strCommand,lng_funReturnNamedParameterEXP_Start)
              '
    str_funRNP_EXP_Result = _
              RIGHT$(str_funRNP_EXP_Result, _
              LEN(str_funRNP_EXP_Result)-LEN(strName))
              '
    str_funRNP_EXP_Result = PARSE$(str_funRNP_EXP_Result,"""",2)
    str_funRNP_EXP_Result = REMOVE$(str_funRNP_EXP_Result,"""")
    '
  ELSE
    str_funRNP_EXP_Result = ""
  END IF
  '
  FUNCTION = str_funRNP_EXP_Result
  '
END FUNCTION
