#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_SpeechAPI.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Speech",0,0,40,120)
  '
  funLog("Speech")
  ' get the list of voices available
  LOCAL strVoices AS STRING     ' list of all voices
  LOCAL strVoice AS STRING      ' selected voice
  LOCAL strText AS STRING       ' text to speak
  '
  ' get the list of voices available
  strVoices = funGetVoices()
  REPLACE "|" WITH $CRLF IN strVoices
  funLog(strVoices & $CRLF)
  '
  strText = "The program is now running"
  funSpeak(strText)
  '
  strText = "And it has " & _
             FORMAT$(PARSECOUNT(strVoices,$CRLF)) & _
            " voices"
  strVoice = PARSE$(strVoices,$CRLF,3)
  funSpeakWithVoice(strText,strVoice, _
                    %vtxtst_READING)


  strText = "What are you doing Dave?"
  strVoice = PARSE$(strVoices,$CRLF,2)
  funSpeakWithVoice(strText,strVoice, _
                    %vtxtst_QUESTION)

  strText = "The moving finger writes, and having writ, moves on"
  strVoice = PARSE$(strVoices,$CRLF,2)
  funSpeakWithVoice(strText,strVoice, _
                    %vtxtst_READING)
  '
  funHaveAnArguement()
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funHaveAnArguement() AS LONG
' run an arguement with three voices
  LOCAL oSp AS DISPATCH
  LOCAL vRes AS VARIANT
  LOCAL vTxt AS VARIANT
  LOCAL vTime AS VARIANT
  LOCAL oTokens AS DISPATCH
  '
  LOCAL oTokenHazel AS DISPATCH    ' hazel voice 1
  LOCAL oTokenAdam AS DISPATCH     ' adam  voice 2
  LOCAL oTokenZira AS DISPATCH     ' Zira  voice 3
  '
  LOCAL vToken AS VARIANT
  LOCAL lngI AS LONG
  LOCAL vIdx AS VARIANT
  LOCAL lngCount AS LONG
  LOCAL lngCounter AS LONG
  LOCAL strDesc AS STRING
  '
  LET oSp = NEWCOM "SAPI.SpVoice"
  IF ISFALSE ISOBJECT( oSp ) THEN
    EXIT FUNCTION
  END IF
  ' Get a reference to the SAPI ISpeechObjectTokens collection
  OBJECT CALL oSp.GetVoices( ) TO vRes
  IF ISFALSE OBJRESULT THEN
    LET oTokens = vRes
    vRes = EMPTY
    ' Get the number of tokens
    OBJECT GET oTokens.Count TO vRes
    lngCount = VARIANT#( vRes )
    ' Parse the collection (zero based)
    FOR lngI = 0 TO lngCount - 1
      INCR lngCounter
      IF lngCounter = 4 THEN EXIT FOR
      '
      vIdx = lngI AS LONG
      ' Get the item by his index
      OBJECT CALL oTokens.Item( vIdx ) TO vRes
      IF ISFALSE OBJRESULT THEN
        SELECT CASE lngCounter
          CASE 3
            LET oTokenHazel = vRes
          CASE 2
            LET oTokenAdam = vRes
          CASE 1
            LET oTokenZira = vRes
        END SELECT
        vRes = EMPTY
      END IF
    NEXT lngI
    LET oTokens = NOTHING
    ' voices tokens stored
    '
    ' set to first token
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "Welcome to our house"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "What are you doing?"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "I'm talking to these people"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "What for, you haven't done the washing up yet!"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "I can do that later, this is important"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "You always say that and it never gets done!"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "But this is my job, it puts food on the table"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "What table, we've still just got a virtual one, I want a real table!"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenZira
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "Now, you shouldn't start arguing"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "And who is this! Where did she come from?"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "This is Zira, she is a Microsoft voice"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "I don't want your virtual floozies in my house"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "It's not a house its a laptop"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "Or even in the laptop then! And that reminds me, you " & _
           "have still to clean out the hard disk"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenAdam
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "I'm waiting, for better weather"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET vToken = oTokenHazel
    OBJECT SET oSp.Voice = vToken
    '
    vTxt = "That's it! I'm going back to my Motherboard!"
    OBJECT CALL oSp.Speak( vTxt ) TO vRes
    ' Wait until finished
    vTime = - 1 AS LONG   ' -1 = INFINITE
    OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
    '
    LET oTokenAdam  = NOTHING
    LET oTokenHazel = NOTHING
    LET oTokenZira  = NOTHING
    LET oSp         = NOTHING
    '
  END IF
  '
END FUNCTION
