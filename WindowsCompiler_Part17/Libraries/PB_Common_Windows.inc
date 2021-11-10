' PB_Common_Windows.inc

FUNCTION funTempDirectory() AS STRING
  LOCAL zText AS ASCIIZ * 256
  GetTempPath 256, zText
  FUNCTION = zText
END FUNCTION
