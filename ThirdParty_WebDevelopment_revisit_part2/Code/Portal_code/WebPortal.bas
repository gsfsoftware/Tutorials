#COMPILE EXE
#DIM ALL
'
#DEBUG ERROR ON
'
#TOOLS OFF
'
#IF %DEF(%PB_CC32)
' turn off the console
' if compiling in Console compiler
  #CONSOLE OFF
#ENDIF
'
#INCLUDE "win32api.inc"
#INCLUDE "GraphicSplashProgress.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
' show a graphics window as a splash screen
  LOCAL hWin AS DWORD
  LOCAL strText AS STRING
  LOCAL lngX, lngY AS LONG
  LOCAL strBodyText AS STRING
  LOCAL strWebsitePath AS STRING
  LOCAL zText AS ASCIIZ * 256
  '
  LOCAL strUser AS STRING
  LOCAL strComputer AS STRING
  LOCAL strDomain AS STRING
  '
  strUser = ENVIRON$("USERNAME")
  strComputer = ENVIRON$("COMPUTERNAME")
  strDomain = ENVIRON$("USERDOMAIN")
  '
  ' set the web site path
  strWebsitePath = "http://odroid007/CGI_BIN/ccCGI_Demo.EXE"
  '
  ' set the text for the splash screen title
  strText = "Web Portal for " & strUser & " in " & _
             strDomain & " on " & strComputer
             '
  ' set the parameters and pass to web site
  LOCAL strParams AS STRING ' used for parameters to web site
  strParams = strUser & "|" & strComputer & "|" & strDomain
  '
  strWebsitePath = strWebsitePath & "?" & strParams
  '
  strBodyText = "LOADING..."
  ' set splash screen location
  lngX = 100
  lngY = 100
  '
  funOpenGraphicProgress(hWin,strText,lngX,lngY,strBodyText)
  '
  funUpdateGraphicProgress("Launching Portal",30)
  SLEEP 1000
  funUpdateGraphicProgress("Launching Portal",80)
  SLEEP 1000
  '
  ' now launch the web page
  zText = strWebsitePath
  ShellExecute BYVAL %NULL, "open", zText, BYVAL %NULL, _
               BYVAL %NULL, %SW_SHOWNORMAL
               '
  funCloseGraphicProgress(hWin)
  '
END FUNCTION
