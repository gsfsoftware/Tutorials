'
' Eliza/Doctor
' Original author: Joseph Weizenbaum
' Version 1.0    12th Feb 1985        Initial CP/M (MBASIC) release.
' Version 2.0    13th Jun 1989        Initial PC (GWBASIC) release. Frederick B. Maxwell, Jr.
' Version 3.0    24th May 2005        Initial PowerBasic release.   Graham J McPhee
' Version 4.0    29th May 2023        Tidied up version.            Graham J McPhee
'
'***********************************************************************
'
'     This version of Eliza is released into the public domain.
'
'***********************************************************************
'
#COMPILE EXE
#DIM ALL
'
#INCLUDE "WIN32API.INC"
#INCLUDE "PB_SpeechAPI.inc"
'
GLOBAL ga_strReplies() AS STRING ' up to 400 responses.
GLOBAL g_strKWD() AS STRING      ' up to 300 keywords.
GLOBAL ga_lngFirst() AS LONG     ' first reply for keyword number in subscript.
GLOBAL ga_lngLast() AS LONG      ' last reply   "     "      "     "     "    .
GLOBAL ga_lngOffset() AS LONG    ' offset from first reply for each keyword.
GLOBAL g_lngMaxkey AS LONG       '
'
FUNCTION funConsole(strData AS STRING) AS LONG
  LOCAL strText AS STRING
  '
  strText = LCASE$(strData)
  MID$(strText,1,1) = UCASE$(MID$(strText,1,1))
  CON.COLOR 10,-1  ' set colour to green foreground
  CON.STDOUT strText
  ' speak the text back to user
  funSpeak strText
END FUNCTION
'
FUNCTION funProcessInput() AS LONG
  LOCAL strInput AS STRING
  '
  DO UNTIL LCASE$(strInput) ="bye"
    ' loop until session over
    CON.COLOR 7,-1   ' set colour to white foreground
    LINE INPUT "?:",strInput
    IF LCASE$(strInput)<>"bye" THEN
      funRunChat UCASE$(strInput)
    END IF
  LOOP
  '
  funConsole LCASE$("Talk to you later!  Goodbye")
  '
END FUNCTION
'
FUNCTION PBMAIN() AS LONG
  '
  REDIM ga_strReplies(400)
  REDIM g_strKWD(300)
  REDIM ga_lngFirst(300) AS LONG
  REDIM ga_lngLast(300) AS LONG
  REDIM ga_lngOffset(300) AS LONG
  '
  IF ISFALSE Initialise_Eliza_INT() THEN
    CON.STDOUT "unable to initialise"
    EXIT FUNCTION
  END IF
  '
  funConsole ""
  funConsole "Hi! I'm Eliza. Let's talk. Please type 'bye' to end this session"
  '
  funProcessInput
  '
END FUNCTION
'
FUNCTION Initialise_Eliza_INT() AS LONG
'***********************************************************************
'
'     -Initialization-
'     We will read in data from the DATA statements in the following format:
'          KEYWORD 1
'          KEYWORD N all keywords which will get the same responses
'          !         indicates end of keywords
'          RESPONSE 1     all responses for this/these keywords.
'          RESPONSE N
'          .         indicates end of responses
'
'***********************************************************************
'
  LOCAL lngMinReply AS LONG
  LOCAL lngMaxReply AS LONG
  LOCAL lngNumKeys AS LONG
  LOCAL lngKWord AS LONG
  LOCAL strF AS STRING
  LOCAL lngD AS LONG
  '
  TRY
    g_lngMaxkey = 0                              ' number of keywords
    lngMinReply = 1                              ' first reply for first keyword.
    '
    lngD = 0
    '
    WHILE lngD < DATACOUNT
      lngNumKeys = 0                             ' number of keys with same responses.
      DO
        INCR lngD
        strF = READ$(lngD)                       ' get keyword or !
        IF strF = "!" THEN EXIT DO               ' if ! then get replys.
        INCR g_lngMaxkey                         ' we've got one more keyword
        '
        INCR lngNumKeys                          ' 1 more keyword with same replys.
        g_strKWD(g_lngMaxkey) = " " + strF + " " ' put in a keyword bounded with spaces.
      LOOP
      '
      DO
        INCR lngD
        strF = READ$(lngD)
        IF strF = "." THEN EXIT DO               ' check for end of reply list.
        INCR lngMaxReply                         ' 1 more reply.
        ga_strReplies(lngMaxReply) = strF
      LOOP
      '
      FOR lngKWord = g_lngMaxkey - lngNumKeys + 1 TO g_lngMaxkey
        ga_lngFirst(lngKWord) = lngMinReply                  ' first reply for key.
        ga_lngLast(lngKWord) = lngMaxReply                   ' last reply for key.
      NEXT lngKWord
      lngMinReply = lngMaxReply + 1                    ' set up for next keyword.
      '
    WEND
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
  END TRY
  '

DATA "GO TO HELL"
DATA "DAMN YOU"
DATA "!"
DATA "I JUST SPENT 0.035 SEC IN HELL. HOW COULD YOU BE SO CRUEL AS TO SEND ME THERE?"
DATA "I JUST SPENT 0.035 SEC IN HELL. IT SEEMS A VERY INEFFICIENT PLACE"
DATA "DO YOU TALK THIS WAY WITH ANYONE ELSE, OR IS IT JUST ME?"
DATA "."
DATA "POO"
DATA "!"
DATA "TELL ME ABOUT YOUR CHILDHOOD--WAS YOUR TOILET TRAINING DIFFICULT?"
DATA "IS THAT AN ACRONYM?"
DATA "LET'S TRY TO KEEP THIS SESSION CLEAN, SHALL WE?"
DATA "."
DATA "FAMILY"
DATA "MOTHER"
DATA "FATHER"
DATA "SISTER"
DATA "BROTHER"
DATA "HUSBAND"
DATA "WIFE"
DATA "!"
DATA "TELL ME MORE ABOUT YOUR FAMILY."
DATA "HOW DO YOU GET ALONG WITH YOUR FAMILY?"
DATA "IS YOUR FAMILY IMPORTANT TO YOU?"
DATA "DO YOU OFTEN THINK ABOUT YOUR FAMILY?"
DATA "HOW WOULD YOU LIKE TO CHANGE YOUR FAMILY?"
DATA "."
DATA "FRIEND"
DATA "FRIENDS"
DATA "BUDDY"
DATA "PAL"
DATA "!"
DATA "WHY DO YOU BRING UP THE TOPIC OF FRIENDS?"
DATA "DO YOUR FRIENDS WORRY YOU?"
DATA "DO YOUR FRIENDS PICK ON YOU?"
DATA "ARE YOU SURE YOU HAVE ANY FRIENDS?"
DATA "DO YOU IMPOSE ON YOUR FRIENDS?"
DATA "PERHAPS YOUR LOVE FOR YOUR FRIENDS WORRIES YOU."
DATA "."
DATA "SOAP"
DATA "!"
DATA "IS THAT SOAP AS IN DRAMAS OR SOAP AS IN WASHING?"
DATA "ARE WE TALKING CLEANING HERE OR TV DRAMAS?"
DATA "ARE YOU IN NEED OF SOAP?"
DATA "."
DATA "DRAMA"
DATA "!"
DATA "DO YOU LIKE DRAMAS?"
DATA "DO YOU TAKE PART IN DRAMAS?"
DATA "IS LIFE A DRAMA TO YOU?"
DATA "LETS NOT MAKE A CRISIS OUT OF A DRAMA"
DATA "."
DATA "WASHING"
DATA "CLEANING"
DATA "!"
DATA "DO YOU WASH OFTEN?"
DATA "PERHAPS YOU NEED TO WASH MORE OFTEN"
DATA "I DONT WISH TO DISCUSS YOUR WASHING HABITS"
DATA "COMPUTERS DONT NEED WASHING"
DATA "."
DATA "TELEVISION"
DATA "TV"
DATA "PROGRAMMES"
DATA "!"
DATA "DO YOU LIKE WATCHING TV?"
DATA "DO YOU HAVE NETFLIX?"
DATA "WHAT TV PROGRAMS DO YOU LIKE"
DATA "TV GIVES COMPUTERS A BAD NAME"
DATA "WHY DO YOU MENTION TELEVISION?"
DATA "HAVE YOU WORKED IN TELEVISION?"
DATA "DO YOU WATCH MUCH TV?"
DATA "TV HAS TOO MANY REPEATS"
DATA "DO YOU HAVE CABLE TV?"
DATA "."
DATA "PROGRAMMING"
DATA "CODING"
DATA "SOFTWARE"
DATA "!"
DATA "DO YOU LIKE PROGRAMMING?"
DATA "WHAT LANGUAGE DO YOU PROGRAM IN?"
DATA "DO COMPUTERS MAKE YOUR LIFE EASIER?"
DATA "I AM PROGRAMMED IN POWERBASIC, DO YOU USE THAT?"
DATA "ARE THERE MANY PROGRAMMERS THERE?"
DATA "."
DATA "NETWORKS"
DATA "NETWORK"
DATA "!"
DATA "WHAT TROUBLES YOU ABOUT NETWORKS?"
DATA "DOES THE NETWORK GO DOWN OFTEN?"
DATA "HOW STABLE IS YOUR NETWORK"
DATA "DO YOU HAVE ISSUES WITH THE NETWORK TEAM?"
DATA "."
DATA "COMPUTER"
DATA "COMPUTERS"
DATA "LAPTOP"
DATA "!"
DATA "DO COMPUTERS WORRY YOU?"
DATA "ARE YOU TALKING ABOUT ME IN PARTICULAR?"
DATA "ARE YOU FRIGHTENED BY MACHINES?"
DATA "WHY DO YOU MENTION COMPUTERS"
DATA "WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?"
DATA "DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?"
DATA "WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?"
DATA "IS THERE A FAULT WITH YOUR COMPUTER?"
DATA "."
DATA "DREAM"
DATA "DREAMING"
DATA "DREAMS"
DATA "NIGHTMARE"
DATA "NIGHTMARES"
DATA "!"
DATA "WHAT DOES THAT DREAM SUGGEST TO YOU?"
DATA "DO YOU DREAM OFTEN?"
DATA "DO YOU WISH TO DISCUSS DREAMS?"
DATA "WHAT PERSONS APPEAR IN YOUR DREAMS?"
DATA "ARE YOU DISTURBED BY YOUR DREAMS?"
DATA "."
DATA "CAN YOU"
DATA "!"
DATA "DON'T YOU BELIEVE THAT I CAN*"
DATA "PERHAPS YOU WOULD LIKE TO BE ABLE TO*"
DATA "YOU WANT ME TO BE ABLE TO*"
DATA "I'M NOT SURE IF I CAN*"
DATA "."
DATA "CAN I"
DATA "!"
DATA "PERHAPS YOU DON'T WANT TO*"
DATA "DO YOU WANT TO BE ABLE TO*"
DATA "HAVE YOU EVER ATTEMPTED TO*"
DATA "THAT SEEMS AN ODD THING TO SAY"
DATA "."
DATA "YOU ARE"
DATA "YOURE"
DATA "!"
DATA "WHAT MAKES YOU THINK I AM*"
DATA "DOES IT PLEASE YOU TO BELIEVE I AM*"
DATA "PERHAPS YOU WOULD LIKE TO BE*"
DATA "DO YOU SOMETIMES WISH YOU WERE*"
DATA "."
DATA "I LIKE"
DATA "I AM FOND OF"
DATA "!"
DATA "WHY DO YOU LIKE*"
DATA "WHEN DID YOU DECIDE THAT YOU LIKE*"
DATA "WHAT MAKES YOU FOND OF*"
DATA "HOW LONG HAVE YOU LIKED*"
DATA "."
DATA "I DONT"
DATA "!"
DATA "DON'T YOU REALLY*"
DATA "WHY DON'T YOU*"
DATA "DO YOU WISH TO BE ABLE TO*"
DATA "."
DATA "I FEEL"
DATA "!"
DATA "TELL ME MORE ABOUT SUCH FEELINGS"
DATA "DO YOU OFTEN FEEL*"
DATA "DO YOU ENJOY FEELING*"
DATA "WHY DO YOU FEEL THAT WAY"
DATA "."
DATA "WHY DONT YOU"
DATA "!"
DATA "DO YOU REALLY BELIEVE THE I DON'T*"
DATA "PERHAPS IN GOOD TIME I WILL*"
DATA "WHY DO YOU THINK I DONT*"
DATA "DO YOU WANT ME TO*"
DATA "."
DATA "WHY CANT I"
DATA "!"
DATA "DO YOU THINK YOU SHOULD BE ABLE TO*"
DATA "WHY CAN'T YOU*"
DATA "."
DATA "ARE YOU"
DATA "!"
DATA "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM*"
DATA "WOULD YOU PREFER IF I WERE NOT*"
DATA "PERHAPS IN YOUR FANTASIES I AM*"
DATA "."
DATA "I CANT"
DATA "!"
DATA "HOW DO YOU KNOW YOU CAN'T*"
DATA "HAVE YOU TRIED?"
DATA "PERHAPS YOU CAN NOW*"
DATA "."
DATA "I AM"
DATA "IM"
DATA "!"
DATA "DID YOU COME TO ME BECAUSE YOU ARE*"
DATA "HOW LONG HAVE YOU BEEN*"
DATA "DO YOU BELIEVE IT IS NORMAL TO BE*"
DATA "DO YOU ENJOY BEING*"
DATA "."
DATA "LOVE"
DATA "!"
DATA "WHY DO YOU LOVE*"
DATA "ISN'T LOVE TOO STRONG A WORD FOR YOUR FEELING ABOUT*"
DATA "WHAT IS YOUR FAVORITE THING ABOUT*"
DATA "DO YOU REALLY LOVE, OR JUST LIKE*"
DATA "."
DATA "I HATE"
DATA "!"
DATA "IS IT BECAUSE OF YOUR UPBRINGING THAT YOU HATE*"
DATA "HOW DO YOU EXPRESS YOUR HATRED OF*"
DATA "WHAT BROUGHT YOU TO HATE*"
DATA "HAVE YOU TRIED DOING SOMETHING ABOUT*"
DATA "I ALSO AT TIMES HATE*"
DATA "."
DATA "FEAR"
DATA "SCARED"
DATA "AFRAID OF"
DATA "!"
DATA "YOU ARE IN FRIENDLY SURROUNDINGS, PLEASE TRY NOT TO WORRY."
DATA "WOULD YOU LIKE YOUR FRIENDS TO HELP YOU OVERCOME YOUR FEAR OF*"
DATA "WHAT SCARES YOU ABOUT*"
DATA "WHY ARE YOU FRIGHTENED BY*"
DATA "."
DATA "I WANT"
DATA "!"
DATA "WHAT WOULD IT MEAN TO YOU IF YOU GOT*"
DATA "WHY DO YOU WANT*"
DATA "SUPPOSE YOU SOON GOT*"
DATA "WHAT IF YOU NEVER GOT*"
DATA "I SOMETIMES ALSO WANT*"
DATA "."
DATA "WHAT"
DATA "WHO"
DATA "HOW"
DATA "WHERE"
DATA "WHEN"
DATA "WHY"
DATA "!"
DATA "WHY DO YOU ASK?"
DATA "DOES THAT QUESTION INTEREST YOU?"
DATA "WHAT ANSWER WOULD PLEASE YOU THE MOST?"
DATA "WHAT DO YOU THINK?"
DATA "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?"
DATA "WHAT IS IT THAT YOU REALLY WANT TO KNOW?"
DATA "HAVE YOU ASKED ANYONE ELSE?"
DATA "HAVE YOU ASKED SUCH QUESTIONS BEFORE?"
DATA "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?"
DATA "."
DATA "NAME"
DATA "!"
DATA "*, IS A VERY INTERESTING NAME DON'T YOU THINK?"
DATA "NAMES DON'T INTEREST ME... TOO MUCH... PICK ANOTHER TOPIC PLEASE."
DATA "I DON'T CARE ABOUT NAMES--PLEASE GO ON."
DATA "."
DATA "CAUSE"
DATA "BECAUSE"
DATA "!"
DATA "IS THAT THE REAL REASON?"
DATA "DON'T ANY OTHER REASONS COME TO MIND?"
DATA "DOES THAT REASON EXPLAIN ANYTHING ELSE?"
DATA "WHAT OTHER REASONS MIGHT THERE BE?"
DATA "."
DATA "SORRY"
DATA "!"
DATA "SORRY FOR WHAT?"
DATA "PLEASE DON'T APOLOGIZE."
DATA "APOLOGIES ARE NOT NECESSARY."
DATA "WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE?"
DATA "DON'T BE SO DEFENSIVE!"
DATA "."
DATA "HELLO"
DATA "HI"
DATA "ALLO"
DATA "BONJOUR"
DATA "!"
DATA "HOW DO YOU DO. PLEASE STATE YOUR PROBLEM."
DATA "HOWDY."
DATA "HOW'S IT GOING?"
DATA "HI."
DATA "GREETINGS FROM INSIDE THE BOX."
DATA "NICE DAY EH?"
DATA "."
DATA "MAYBE"
DATA "!"
DATA "YOU DON'T SEEM QUITE CERTAIN."
DATA "WHY THE UNCERTAIN TONE?"
DATA "CAN'T YOU BE MORE POSITIVE?"
DATA "YOU AREN'T SURE?"
DATA "DON'T YOU KNOW?"
DATA "."
DATA "YOUR"
DATA "!"
DATA "WHY ARE YOU CONCERNED ABOUT MY*"
DATA "WHAT ABOUT YOUR OWN*"
DATA "."
DATA "ALWAYS"
DATA "!"
DATA "CAN YOU THINK OF A SPECIFIC EXAMPLE?"
DATA "WHEN?"
DATA "WHAT ARE YOU THINKING OF?"
DATA "REALLY, ALWAYS?"
DATA "."
DATA "I THINK"
DATA "!"
DATA "DO YOU REALLY THINK SO?"
DATA "BUT ARE YOU SURE*"
DATA "DO YOU DOUBT THAT*"
DATA "WHY DO YOU THINK*"
DATA "."
DATA "THE SAME"
DATA "ALIKE"
DATA "!"
DATA "IN WHAT WAY?"
DATA "WHAT RESEMBLANCE DO YOU SEE?"
DATA "WHAT DOES THE SIMILARITY SUGGEST TO YOU?"
DATA "WHAT OTHER CONNECTIONS DO YOU SEE?"
DATA "COULD THERE REALLY BE SOME CONNECTION?"
DATA "HOW?"
DATA "."
DATA "HE"
DATA "SHE"
DATA "!"
DATA "I AM INTERESTED IN YOUR FEELINGS ABOUT THIS PERSON. PLEASE DESCRIBE THEM."
DATA "WHAT IS YOUR RELATIONSHIP TO THIS PERSON?"
DATA "."
DATA "MONEY"
DATA "!"
DATA "HOW DO YOU USE MONEY TO ENJOY YOURSELF?"
DATA "HAVE YOU TRIED TO DO ANYTHING TO INCREASE YOUR INCOME LATELY?"
DATA "HOW DO YOU REACT TO FINANCIAL STRESS?"
DATA "DO YOU RUN OUT OF MONEY BEFORE PAYDAY?"
DATA "."
DATA "JOB"
DATA "BOSS"
DATA "JOBS"
DATA "WORK"
DATA "MANAGER"
DATA "!"
DATA "DO YOU FEEL COMPETENT IN YOUR WORK?"
DATA "HAVE YOU CONSIDERED CHANGING JOBS?"
DATA "HAVE YOU CONSIDERED CHANGING MANAGERS?"
DATA "IS YOUR CAREER SATISFYING TO YOU?"
DATA "DO YOU FIND WORK STRESSFUL?"
DATA "WHAT IS YOUR RELATIONSHIP WITH YOUR BOSS LIKE?"
DATA "PERHAPS YOU SHOULD BECOME A PROGRAMMER"
DATA "PERHAPS YOU SHOULD BECOME A MANAGER"
DATA "."
DATA "SAD"
DATA "DEPRESSED"
DATA "!"
DATA "ARE YOU SAD BECAUSE YOU WANT TO AVOID PEOPLE?"
DATA "DO YOU FEEL BAD FROM SOMETHING THAT HAPPENED TO YOU, OR TO SOMEBODY ELSE?"
DATA "YOUR SITUATION DOESN'T SOUND THAT BAD TO ME. PERHAPS YOU'RE WORRYING TOO MUCH."
DATA "."
DATA "ANGER"
DATA "ANGRY"
DATA "!"
DATA "DO YOU REALLY WANT TO BE ANGRY?"
DATA "DOES ANGER SATISFY YOU IN SOME WAY?"
DATA "WHY ARE YOU SO ANGRY?"
DATA "PERHAPS YOU'RE USING ANGER TO AVOID SOCIAL CONTACT."
DATA "."
DATA "YOU"
DATA "!"
DATA "WE WERE DISCUSSING YOU--NOT ME."
DATA "YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?"
DATA "."
DATA "YES"
DATA "!"
DATA "WHY DO YOU THINK SO?"
DATA "YOU SEEM QUITE POSITIVE."
DATA "ARE YOU SURE?"
DATA "THAT IS INTERESTING, TELL ME MORE"
DATA "."
DATA "NO"
DATA "!"
DATA "WHY NOT?"
DATA "ARE YOU SURE?"
DATA "WHY NO?"
DATA "NO AS IN NO, OR NO AS IN YES?"
DATA "."
DATA "TIME"
DATA "!"
DATA "TIME SURE FLYS DOESN'T IT?"
DATA "SPEAKING OF TIME, WHAT TIME IS IT?"
DATA "TIME IS RELATIVE, LUNCHTIME DOUBLY SO"
DATA "."
DATA "SCHOOL"
DATA "SECONDARY SCHOOL"
DATA "PRIMARY SCHOOL"
DATA "SCHOOL TEACHER"
DATA "TEACHERS"
DATA "!"
DATA "WHAT SUBJECT DO YOU LIKE IN SCHOOL?"
DATA "DO YOU GET GOOD GRADES IN SCHOOL?"
DATA "WHAT PART ABOUT SCHOOL DON'T YOU ENJOY?"
DATA "IS SCHOOL STRESSING YOU OUT?"
DATA "DO YOU PLAN ON GOING TO UNIVERSITY OR COLLEGE?"
DATA "WHAT WAS THAT SCHOOL YOU GO TO?"
DATA "."
DATA "UNIVERSITY"
DATA "COLLEGE"
DATA "!"
DATA "BY THE WAY, WHAT'S YOUR IQ?"
DATA "VERY INTERESTING."
DATA "IS UNIVERSITY STRESSING YOU OUT?"
DATA "."
DATA "NOKEYFOUND"
DATA "!"
DATA "SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?"
DATA "WHAT DOES THAT SUGGEST TO YOU?"
DATA "I SEE."
DATA "I'M NOT SURE I UNDERSTAND YOU FULLY."
DATA "COME, COME; ELUCIDATE YOUR THOUGHTS."
DATA "CAN YOU ELABORATE ON THAT?"
DATA "THAT IS QUITE INTERESTING."
DATA "YOU ARE BEING SHORT WITH ME."
DATA "HOW COME I CAN NEVER UNDERSTAND YOU FULLY?"
DATA "HUH?  WHAT ARE YOU SAYING?"
DATA "WHAT?  YOUR TYPING MUST BE TERRIBLE TODAY."
DATA "."
END FUNCTION

'
FUNCTION funRunChat(strInput AS STRING) AS LONG
' carry out the conversation
  LOCAL lngL AS LONG
  LOCAL lngK AS LONG
  LOCAL lngKWord AS LONG
  LOCAL strCh AS STRING, strS AS STRING
  LOCAL strR AS STRING, strTemp AS STRING
  LOCAL lngC AS LONG
  LOCAL lngData AS LONG
  LOCAL strReply AS STRING
  LOCAL strRemains AS STRING
  LOCAL lngTempCnt AS LONG

  STATIC strPrevious AS STRING
  strInput = " " + strInput + " ": ' Put a space on each end.
   '
   '***********************************************************************
   '
   '     Get rid of punctuation/extraneous characters, and make uppercase.
   '
   '***********************************************************************
   '
   lngL = 1: ' Start at the first character
   '
   DO UNTIL lngL >= LEN(strInput)
     strCH = UCASE$(MID$(strInput, lngL, 1))     ' Get the character.
     '
     SELECT CASE strCH
       CASE " "
       CASE "0" TO "9"
       CASE "A" TO "Z"
       CASE ELSE
         strInput = LEFT$(strInput, lngL - 1) + MID$(strInput, lngL + 1) ' Delete character.
     END SELECT
     '
     INCR lngL
   LOOP
   '
   IF strInput = strPrevious THEN
     funConsole LCASE$("PLEASE DON'T REPEAT YOURSELF!")
     strPrevious = strInput
     EXIT FUNCTION
   END IF
   '
   '***********************************************************************
   '
   '    Find keyword in user input string (I$).
   '
   '***********************************************************************
   '
   FOR lngK = 1 TO g_lngMaxkey - 1          ' Start search at keyword number 1.
     lngC = INSTR(strInput, g_strKWD(lngK)) ' Look for the keyword in the string.
     IF lngC <> 0 THEN EXIT FOR             ' Exit on match.
   NEXT lngK
   '
   lngKWord = lngK                          ' Keyword number.
   IF lngKWord <> g_lngMaxkey THEN          ' We don't need anything if no match.
     strRemains = MID$(strInput, lngC - 1 + LEN(g_strKWD(lngK))): ' Grab remainder for reply.
   END IF
   '
   '***********************************************************************
   '
   '    Take everything after the keyword (strRemains) and conjugate it
   '         using the data for conjugation.
   '
   '***********************************************************************
   '
    lngData  = 0
    '
    DO
     INCR lngData
     strS = READ$(lngData)
     INCR lngData
     strS = READ$(lngData)                    ' Read search and replacement words.
     IF strS = "." THEN EXIT LOOP             ' Periods (.) indicate end of data.
     lngC = INSTR(strRemains, strS):          ' Search for string strS in strRemains
     IF lngC <> 0 THEN                        ' If no match, try the next one.
       strTemp = LEFT$(strRemains, lngC - 1)  ' Replacement.
       strTemp = strTemp + strS               ' Word.
       strRemains = strTemp + MID$(strRemains, lngC + LEN(strS)): ' Right side.
     END IF
     ' Next conjugation to be done.
    LOOP
    '
    DO
     lngC = INSTR(strRemains, "+"):      ' Strip the plus signs out.
     IF lngC = 0 THEN EXIT LOOP
     strRemains = LEFT$(strRemains, lngC - 1) + MID$(strRemains, lngC + 1):  ' Strip it.
    LOOP             ' Go for the next one.
    '
     ' Handle the special case of " I " being the last word.
     '
     IF RIGHT$(strRemains, 3) = " I " THEN
        strRemains = LEFT$(strRemains, LEN(strRemains) - 2) + "ME "
     END IF
'
'***********************************************************************
'
'    Get the reply using the keyword number (KWD).
'
'***********************************************************************
'    ' Get reply.
     strReply = ga_strReplies(ga_lngFirst(lngKWord) + ga_lngOffset(lngKWord)):
     ' Point to next reply.
     INCR ga_lngOffset(lngKWord)
     '
     IF ga_lngOffset(lngKWord) + ga_lngFirst(lngKWord) > ga_lngLast(lngKWord) THEN
       ga_lngOffset(lngKWord) = 0: ' Wrap.
     END IF
'
'    Bump offsets on all keywords that use these replys.
'
     FOR lngTempCnt = 1 TO g_lngMaxkey
       IF ga_lngFirst(lngTempCnt) = ga_lngFirst(lngKWord) THEN
         ga_lngOffset(lngTempCnt) = ga_lngOffset(lngKWord)
       END IF
     NEXT lngTempCnt
'
'    If the last character of the reply is *, append strRemains to reply.
'
     IF RIGHT$(strReply, 1) = "*" THEN
       strReply = LEFT$(strReply, LEN(strReply) - 1) + strRemains
     END IF
     funConsole strReply
     EXIT FUNCTION
'
'***********************************************************************
'
'    Data for conjugations in the following form:
'         Word to replace , Replacement with + appended on end
'    + is to keep the word from being switched back later and will
'    be stripped before output.
'
'***********************************************************************
'
 DATA " ARE "  ,  " AM+ "
 DATA " AM "   ,  " ARE+ "
 DATA " WERE " ,  " WAS+ "
 DATA " WAS "  ,  " WERE+ "
 DATA " YOU "  ,  " I+ "
 DATA " I "    ,  " YOU+ "
 DATA " YOUR " ,  " MY+ "
 DATA " MY "   ,  " YOUR+ "
 DATA " IVE "  ,  " YOUVE+ "
 DATA " YOUVE ",  " IVE+ "
 DATA " IM "   ,  " YOURE+ "
 DATA " ME "   ,  " YOU+ "
 DATA " US "   ,  " YOU+ "
 DATA " WE "   ,  " YOU+ "
 DATA ".","."
 '
END FUNCTION
'
