#COMPILE EXE
#DIM ALL
' Task 1 dummy task
#INCLUDE "Win32api.inc"
'
#INCLUDE "PB_FileHandlingRoutines.inc"  ' file handling library
#INCLUDE "PB_Txt_ConfigFile.inc"        ' load the config file library
#INCLUDE "PB_CommandLine.inc"           ' command line library
'
FUNCTION PBMAIN () AS LONG
  '
  LOCAL strCommand AS STRING
  LOCAL strConfigFile AS STRING
  LOCAL strInputFile AS STRING
  '
  strCommand = COMMAND$
  ' get the config file name
  strConfigFile = funReturnNamedParameterEXP("/Config#", _
                                             strCommand)
  strInputFile =  funReturnNamedParameterEXP("/Input#", _
                                             strCommand)
  '
  IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
  ' read data in
    LOCAL lngDelay AS LONG
    lngDelay = RND(8000,14000)
    SLEEP lngDelay ' simulate 8-10 seconds worth of processing

  ' process data

  ' output result
  END IF
  '
END FUNCTION
