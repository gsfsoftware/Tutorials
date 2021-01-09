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
' load the wave file into the resource at compile time
' using a named resource
#RESOURCE WAVE MISSED,"Missed.wav"
' load the wave file into the resource at compile time
' using a numbered resource
#RESOURCE WAVE 2000,"Hit.wav"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Wave files",0,0,40,120)
  '
  funLog("Wave files")
  '
  LOCAL lngResult AS LONG
  '
  PLAY WAVE "Missed" ' play the named resource
  SLEEP 1000         ' and wait for 1 second
  '
  PLAY WAVE "#2000"  ' play the numbered resource
  SLEEP 1000         ' and wait for 1 second
  '
  ' play a file from disk (in same folder as EXE)
  ' and wait till sound is finished played before
  ' continuing in code by using SYNCH
  ' and the result (true/false) into lngResult
  PLAY WAVE "Fanfare.wav", SYNCH TO lngResult
  IF ISFALSE lngResult THEN
    funlog "No file"
  END IF
  '
  SLEEP 500 ' wait half a second
  ' play another file from disk
  PLAY WAVE "c:\Windows\Media\Ring06.wav"
  ' attempt to play another Wav file but dont stop Ring06
  ' if it is still playing
  PLAY WAVE "Fanfare.wav", NOSTOP
  ' attempt to play another Wav file but if previous file
  ' is still playing then wait 2 seconds - if its still playing
  ' after that then skip over this command
  PLAY WAVE "c:\Windows\Media\Ring06.wav", YIELDMS(2000)
  '
  SLEEP 3000
  ' play a wav file in a loop continually
  PLAY WAVE "#2000", LOOP
  SLEEP 1000
  ' force any playing wav file to stop playing
  PLAY WAVE END
  '
  funlog "Completed"
  '
  funWait()
  '
END FUNCTION
'
