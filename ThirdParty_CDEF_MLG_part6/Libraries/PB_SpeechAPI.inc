' speech library (PB_SpeechAPI.inc)
'
' library index
' funGetVoices() - return a | demlimited list of voice names
' funSpeak(strText) - speak text in the default voice, reading mode
' funSpeakExt(strText,oVFlag) - speak text with SPEAKFLAG
' funSpeakWithVoice(strTxt,
'                   strSelectedVoice ,
'                   oVFlag)   - speak using specific voice and SPEAKFLAG


GLOBAL g_lngSpeaking AS LONG
'
'Enumeration SPEAKFLAGS
%vtxtst_STATEMENT                                       = &H1
%vtxtst_QUESTION                                        = &H2
%vtxtst_COMMAND                                         = &H4
%vtxtst_WARNING                                         = &H8
%vtxtst_READING                                         = &H10
%vtxtst_NUMBERS                                         = &H20
%vtxtst_SPREADSHEET                                     = &H40
%vtxtsp_VERYHIGH                                        = &H80
%vtxtsp_HIGH                                            = &H100
%vtxtsp_NORMAL                                          = &H200
'
FUNCTION funGetVoices() AS STRING
' enumerate the list of voices available
  LOCAL strVoiceList AS STRING
  LOCAL oSp AS DISPATCH
  LOCAL vRes AS VARIANT
  LOCAL oTokens AS DISPATCH
  LOCAL lngCount AS LONG
  LOCAL lngI AS LONG
  LOCAL vIdx AS VARIANT
  LOCAL oToken AS DISPATCH
  LOCAL strDesc AS STRING
  '
  strVoiceList = ""
  LET oSP = NEWCOM "SAPI.SpVoice"
  IF ISFALSE ISOBJECT(oSp) THEN EXIT FUNCTION
  ' get a reference to the SAPI ISpeechObjectTokens colletion
  OBJECT CALL oSP.GetVoices() TO vRes
  IF ISFALSE OBJRESULT THEN
    SET oTokens = vRes
    vRes = EMPTY
    ' get the number of tokens
    OBJECT GET oTokens.Count TO vRes
    lngCount = VARIANT#(vRes)
    ' parse the collection
    FOR lngI = 0 TO lngCount -1
      vIdx = lngI AS LONG
      ' get item based on the index value
      OBJECT CALL oTokens.Item(vIdx) TO vRes
      IF ISFALSE OBJRESULT THEN
        SET oToken = vRes
        vRes = EMPTY
        IF ISFALSE OBJRESULT THEN
        ' get the description
          OBJECT CALL oToken.GetDescription() TO vRes
          IF ISFALSE OBJRESULT THEN
            strDesc = VARIANT$(vRes)
            strVoiceList = strVoiceList & strDesc & "|"
          END IF
        END IF
        SET oToken = NOTHING
      END IF
    NEXT lngI
    SET oTokens = NOTHING
  END IF
  '
  LET oSp = NOTHING
  strVoiceList = RTRIM$(strVoiceList,"|")
  FUNCTION = strVoiceList
  '
END FUNCTION
'
FUNCTION funSpeakWithVoice(strTxt AS STRING, _
                           strSelectedVoice AS STRING, _
                           oVFlag AS VARIANT) AS LONG
  LOCAL oSp AS DISPATCH
  LOCAL vRes AS VARIANT
  LOCAL vTxt AS VARIANT
  LOCAL vTime AS VARIANT
  LOCAL oTokens AS DISPATCH
  LOCAL oToken AS DISPATCH
  LOCAL vToken AS VARIANT
  LOCAL lngI AS LONG
  LOCAL vIdx AS VARIANT
  LOCAL nCount AS LONG
  LOCAL strDesc AS STRING
  '
  LET oSp = NEWCOM "SAPI.SpVoice"
  IF ISFALSE ISOBJECT( oSp ) THEN
    g_lngSpeaking = %FALSE
    EXIT FUNCTION
  END IF
  '
  g_lngSpeaking = %TRUE
    '
  ' Get a reference to the SAPI ISpeechObjectTokens collection
   OBJECT CALL oSp.GetVoices( ) TO vRes
    IF ISFALSE OBJRESULT THEN
      LET oTokens = vRes
      vRes = EMPTY
      ' Get the number of tokens
      OBJECT GET oTokens.Count TO vRes
      nCount = VARIANT#( vRes )
      ' Parse the collection (zero based)
      FOR lngI = 0 TO nCount - 1
        vIdx = lngI AS LONG
        ' Get the item by the index
        OBJECT CALL oTokens.Item( vIdx ) TO vRes
        IF ISFALSE OBJRESULT THEN
          LET oToken = vRes
          vRes = EMPTY
          IF ISFALSE OBJRESULT THEN
          ' Get the description
            OBJECT CALL oToken.GetDescription( ) TO vRes
            IF ISFALSE OBJRESULT THEN
              strDesc = VARIANT$( vRes )
              ' If its the token we are after, set the Voice property
                IF strDesc = strSelectedVoice THEN
                  LET vToken = oToken
                  OBJECT SET oSp.Voice = vToken
                  LET oToken = NOTHING
                  EXIT FOR
                END IF
            END IF
            LET oToken = NOTHING
          END IF
        END IF
      NEXT lngI
      LET oTokens = NOTHING
    END IF
    '
    ' now speak
    vTxt = strTxt
    '
    OBJECT CALL oSp.Speak(vTxt,oVFlag) TO vRes
    '
    ' wait until finishes
    vTime = -1 AS LONG
    OBJECT CALL oSp.WaitUntilDone(vTime) TO vRes
    LET oSp = NOTHING
    '
    g_lngSpeaking = %FALSE
  '
END FUNCTION
'
FUNCTION funSpeak(strText AS STRING) AS LONG
' speak the text
  '
  funSpeakExt(strText,%vtxtst_READING )
  '
END FUNCTION
'
FUNCTION funSpeakExt(strText AS STRING, _
                     oVFlag AS VARIANT) AS LONG
' speak the text where flag is one of the following
'%vtxtst_STATEMENT                                       = &H1
'%vtxtst_QUESTION                                        = &H2
'%vtxtst_COMMAND                                         = &H4
'%vtxtst_WARNING                                         = &H8
'%vtxtst_READING                                         = &H10
'%vtxtst_NUMBERS                                         = &H20
'%vtxtst_SPREADSHEET                                     = &H40
'%vtxtsp_VERYHIGH                                        = &H80
'%vtxtsp_HIGH                                            = &H100
'%vtxtsp_NORMAL                                          = &H200
'
  LOCAL oSp AS DISPATCH
  LOCAL vTxt AS VARIANT
  LOCAL vRes AS VARIANT
  LOCAL vTime AS VARIANT
  '
  LET oSP = NEWCOM "SAPI.SpVoice"
  IF ISFALSE ISOBJECT(oSp) THEN EXIT FUNCTION
  '
  vTxt = strText
  '
  OBJECT CALL oSp.Speak(vTxt,oVFlag) TO vRes
  ' wait until finishes
  vTime = -1 AS LONG
  OBJECT CALL oSp.WaitUntilDone(vTime) TO vRes
  LET oSp = NOTHING
  '
END FUNCTION
