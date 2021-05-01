'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
'  PBcodec, Source Code Checker, v1.5
'-----------------------------------------------------------------------------
'  Scans a main source file and all its include files for Un-used Subs,
'  Functions, and variables. Version 1.1 also has ability to extract string
'  literals, that is, strings withing double-quotes.
'
'  PBcodec will save the result in a file ending with --LOG.TXT and also show
'  this file in associated texteditor.
'
'  This version does not process any Conditional Compiling statements, so far,
'  but all files are properly scanned and it even handles "DIM x AS GLOBAL in
'  a correct way. Tested on my own projects, all reports so far has been correct.
'
'  The output will show the SUB,FUNCT and VAR name followed by  [FileName: 565
'  where the last number is the line number where the item is declared. It will
'  also present a list of all Includes, Global vars, Subs and Functions, this
'  part originally written by Wayne Diamond.
'
'  Public Domain, this version by Borje Hagsten, July 2001, but main credits
'  goes to Scott Slater for showing us it could be done (and how to do it).
'  Parts of this program has been copied from his version, but parsing and
'  some other things has been totally rewritten, my way..
'  Many have been involved, giving many valuable tips and providing code,
'  so one could say this is the result of a joined PB community effort.. :)
'
'  Tip: Prog launches txt-associated texteditor to show report. Standard is
'  NotePad. I have set mine to use Courier New, 9p, which gives nice output..
'
'  A few notes: Exported subs/functions, or ones inside "public" include files,
'  may have a reference count of zero and still not be un-used, since some other
'  program may be using them.
'
'  Also, since one of the advantages with the PB language is almost unlimited
'  flexibility to do things, there's no guaranties everything will be found,
'  or even be 100% correct. It has proved to be successful on my projects,
'  but please, use this (and similar) programs with extreme care..
'
' LOG:
'  Aug 11, 2003 - added some extrs checks for line wraps, _ to DoProcess
'  Jan 23, 2002 - added support for relative include paths, plus optimized
'          some for better speed, etc.
'  Jan 23, 2002 - added support for relative include paths, plus optimized
'          some for better speed, etc.
'  Jan 17, 2002 - changed to use IsCharAlphaNumeric in ANSItrim, to include
'          leading/trailing digits in string literals. Also had to change
'          UCASER function a bit, so all now can be compiled in PBDLL 6.1 too..
'  Oct 17, Corrected error in DoSaveResults, where global/local name mix warning
'          could end up pointing at wrong file for first local declare.
'  Oct 10, added exclude() array to avoid some of the most common include file
'          names when extracting string literals. Possible to expand - see WinMain.
'          Also set string literal extraction checkbox as checked from start.
'  Oct 09, added possibility to extract string literals, that is, text within
'          double-quotes. Added AnsiTRIM function for this purpose.
'  Aug 01, in DoSaveResults, moved REDIM PRESERVE lVars out from loop in first
'          IF/THEN block and reversed loop, because it sometimes GPF'd there.
'          Of course it could GPF. Must run such loops backwards, silly me.
'  Aug 01, removed AllLocals array and use lVars to store all locals instead.
'          Changed report accordingly and now, Global/Local name mix lists
'          Line number for local representations too.
'  Jul 31, excluded declarations of Subs/Function from usage check
'  Jul 31, re-fixed previous stupid fix of GLOBAL DIM, so it works this time..
'  Jul 29, fixed code in DoProcess - ExtractLocals, to check DIM more carefully,
'          since DIM/REDIM may have been preceeded with a GLOBAL declare of same variable.
'  Jul 29, added support for multiple include file paths in WinMain and DoGetIncFiles
'          Added check for trailing backslash to fExist, so paths are handled correctly
'  Jul 29, added code to DoProcess - ExtractSub, to exclude declares for external
'          procedures (in DLL's etc.) from being counted as "declared but un-used".
'          Also added code to DoProcess - ExtractLine, to replace colons within
'          paranthesis, which could cause weird results when parsing a line for colons.
'  Jul 29, added "Scan" button to enable easy rescanning of a file, since I
'          have found this useful to do after changes have been made. Also did
'          some minor tweaking of the code to enhance performance.
'  Jul 28, major trimming of parser, to ensure results and improve performance.
'  Sep 22 2009 IsMainFile() will no longer balk at $TAB before #compile - Nathan Maddox
'  Sep 26 2009 Added ReadFile() to simplify development going forward
'  Sep 26 2009 Added support for #IF %ABC conditional compile (to exclude includes)
'  Sep 26 2009 Added support for #IF NOT %ABC conditional compiles (to exclude includes)
'  Sep 26 2009 Added Support for #IF %Def(%ABC) conditional compiles  (to exclude includes)
'  Sep 26 2009 Added Support for #IF NOT %Def(%ABC) conditional compiles  (to exclude includes)
'  Sep 26 2009 Added support for #ELSE  (to exclude includes)
'  Sep 26 2009 Added checkbox to control whether or not the
'              "Existing Function()'s and Subs()'s that are not Declared Report"
'              PB 9.0 eliminated the need for Declaring all Sub()'s and Function()'s
'  Jul 06 2010 Cloned Conditional Compile code to work with Subs, Functions, Locals, & Globals
'  Jul 07 2010 Added Checkboxes for all reports and Select All and UnSelect All Buttons
'  Jul 25 2010 Added Compound Conditional compiler checking code:
'      #IF %ABC AND %DDD
'      #IF %Def(%ABC) AND %DEF(%DDD)
'      #IF NOT %ABC AND NOT %DDD
'      #IF NOT %DEF(%ABC) AND NOT %DEF(%DDD)
'
'      #IF %ABC OR %DDD
'      #IF %Def(%ABC) OR %DEF(%DDD)
'      #IF NOT %ABC OR NOT %DDD
'      #IF NOT %DEF(%ABC) OR NOT %DEF(%DDD)
'  Jul 25 2010 Fixed comment in resulting file that mentions lines scanned per minute.
'  Jul 30 2010 Bug fixes - larger dialog - Unused and Reports Button
' Aug 2, 2010 Bug fixes for when Equates were parameters to Functions (functions/subs weren't
'                        being marked as used when they really were).
' Aug 4, 2010 Pesky line numbers - work now
' Apr 28, 2021 - Changes to allow compilation under PowerBasic 10.03
'                Amended name of POS variable to lngPOS
'                Amended REDIM Arr(1:COUNT) AS STRING to
'                        REDIM Arr(1 TO COUNT) AS STRING
'
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


#COMPILE EXE

#INCLUDE "PBCODEC.INC"  'Basic Win API definitions

TYPE InfoStruct
   uName       AS ASCIIZ * 100 'is 100 enough? For me it is, but if not for you, increase..
   zName       AS ASCIIZ * 100
   inFunct     AS ASCIIZ * 100
   IsUsed      AS LONG
   iType       AS LONG
   FileNum     AS LONG
   LineNum     AS LONG
   SubEnd      AS LONG
   Exported    AS LONG
END TYPE

TYPE EquateCnsts
   EquateName  AS STRING * 50
   EquateVal   AS LONG
END TYPE

TYPE CondCompType
   EquateName AS STRING * 50
   IncludeIt  AS LONG
END TYPE

TYPE StackType
   PreNot     AS LONG
   PreDef     AS LONG
   EquateName AS STRING * 50
END TYPE

GLOBAL Vars()         AS InfoStruct  ' All Locals in Current Proc (TEMP)
GLOBAL gVars()        AS InfoStruct  ' All Globals
GLOBAL gDbl()         AS InfoStruct  ' Duplicate Global names
GLOBAL gDecl()        AS InfoStruct  ' Declared Subs/Functions
GLOBAL lVars()        AS InfoStruct  ' Un-Used Locals
GLOBAL Functs()       AS InfoStruct  ' All Functions
GLOBAL EqCnst()       AS EquateCnsts
GLOBAL CComp()        AS CondCompType
GLOBAL CondCompile2() AS CondCompType
GLOBAL EquateConst2() AS EquateCnsts

GLOBAL Files()        AS STRING
GLOBAL inFile()       AS STRING
GLOBAL sIncDir()      AS STRING
GLOBAL sString()      AS STRING   'for string literals
GLOBAL exclude()      AS STRING   'for exclude strings
GLOBAL getStrings     AS LONG, sStrCount AS LONG
GLOBAL NotDecl        AS LONG

GLOBAL  Do_Includes_Rpt                 AS LONG
GLOBAL  Do_UnusedFxs_Rpt                AS LONG
GLOBAL  Do_UnusedSubs_Rpt               AS LONG
GLOBAL  Do_DeclaredButNonExistant_Rpt   AS LONG
GLOBAL  Do_UnusedGlobals_Rpt            AS LONG
GLOBAL  Do_UnusedLocals_Rpt             AS LONG
GLOBAL  Do_GlobalLocalMix_Rpt           AS LONG
GLOBAL  Do_DupeGlobal_Rpt               AS LONG
GLOBAL  Do_TotRefCount_Rpt              AS LONG
GLOBAL  Do_SubRefCount_Rpt              AS LONG
GLOBAL  Do_GlobalVariableRpt_Rpt        AS LONG
GLOBAL  Do_StringLiterals_Rpt           AS LONG
GLOBAL  Do_Constants_Rpt                AS LONG
GLOBAL  gCountCRLFs                     AS LONG
'GLOBAL  sFlag                           As Long 'NNM 7/30/2010 (hopefully)

GLOBAL FilePathStr AS STRING, FileNameStr AS STRING, DestFile AS STRING
GLOBAL sWork AS STRING, LineStr AS STRING
GLOBAL Done AS LONG

GLOBAL igDbl     AS LONG       ' # of Duplicate Globals
GLOBAL iVars     AS LONG       ' # of Vars
GLOBAL ilVars    AS LONG       ' # of lVars
GLOBAL igVars    AS LONG       ' # of gVars
GLOBAL iFuncts   AS LONG       ' # of Functs
GLOBAL DeclCount AS LONG
GLOBAL gTotLines AS LONG, t AS SINGLE
'GLOBAL True, False AS LONG

DECLARE CALLBACK FUNCTION WinMainProc() AS LONG
DECLARE FUNCTION AnsiTRIM(BYVAL TXT AS STRING) AS STRING
DECLARE FUNCTION DoGetIncFiles(BYVAL TheFile AS STRING) AS LONG
DECLARE FUNCTION DoProcess(BYVAL TheFile AS STRING, BYVAL fNum AS LONG, WhatRun AS LONG) AS LONG
DECLARE FUNCTION GetCommandFile(BYVAL CmdStr AS STRING, Fi() AS STRING) AS LONG
DECLARE FUNCTION GetDroppedFile(BYVAL hDrop AS LONG, Fi() AS STRING) AS LONG
DECLARE FUNCTION GetIncludeDir AS STRING
DECLARE FUNCTION IniGetString(BYVAL sSection AS STRING, BYVAL sKey AS STRING, _
                              BYVAL sDefault AS STRING, BYVAL sFile AS STRING) AS STRING
DECLARE FUNCTION IsFileMain(BYVAL fName AS STRING) AS LONG
DECLARE FUNCTION UCASER(BYVAL st AS STRING) AS STRING
DECLARE SUB DoInitProcess(BYVAL hDlg AS LONG, BYVAL fName AS STRING)
DECLARE SUB DoSaveResults


FUNCTION ReadFile(BYVAL FileName AS STRING, BYREF Arr() AS STRING) AS LONG
    LOCAL FileNum       AS LONG
    LOCAL FileSiz       AS LONG
    LOCAL COUNT         AS LONG
    LOCAL Buf           AS STRING

    Filenum=FREEFILE
    OPEN FileName FOR BINARY ACCESS READ SHARED AS #FileNum
        FileSiz=LOF(FileNum)
        GET$ #FileNum, FileSiz, Buf
    CLOSE #FileNum

    buf=REMOVE$(buf, ANY $TAB)
    buf=UCASE$(buf)
    '---- Parse the Records
    REPLACE $CRLF WITH $CR IN Buf
    COUNT=PARSECOUNT(Buf, $CR)
    IF gCountCRLFs>0 THEN gTotLines+=COUNT 'Counting Source code lines processed
    REDIM Arr(1 TO COUNT) AS STRING
    PARSE Buf, Arr(), $CR

    FOR COUNT=1 TO UBOUND(Arr)
        Arr(COUNT)=TRIM$(Arr(COUNT))
        DO WHILE INSTR(Arr(COUNT),SPACE$(2))>0 : REPLACE SPACE$(2) WITH $SPC IN Arr(COUNT) : LOOP
    NEXT

    '---- Set Function Result
    FUNCTION=COUNT

END FUNCTION

FUNCTION GetADollarfromDEF(LineStr AS STRING) AS STRING
  LOCAL J, K, L, M AS LONG
  LOCAL A$

  J=INSTR(1,LineStr,"%DEF(") : J+=5
  K=INSTR(J,LineStr,")")
  L=LEN(LineStr)
  M=IIF(K>0,MIN(K,L),L)
  A$=MID$(LineStr,J,L-J+1)     'Name of Equate (everything btwn % and ($SPC or end of String)
  FUNCTION=REMOVE$(A$,")")
END FUNCTION

FUNCTION GetADollar(BYVAL LineStr AS STRING) AS STRING
    LOCAL J, K, L, M AS LONG
    LOCAL A$

    J=INSTR(1,LineStr,"%")
    K=INSTR(J,LineStr," ")
    L=LEN(LineStr)
    M=IIF(K>0,MIN(K,L),L)
    A$=MID$(LineStr,J,L-J+1)     'Name of Equate (everything btwn % and ($SPC or end of String)
    A$=REMOVE$(A$,ANY ")")
    FUNCTION=A$
END FUNCTION


FUNCTION CheckForCompoundCompDirective(BYVAL TXT AS STRING) AS LONG
    FUNCTION=0
    SELECT CASE %TRUE
       CASE INSTR(1, TXT, " OR ")>0
         '? "Conditional Compiler Directive Found. Incorrect results may occur"+$CRLF+Txt
         FUNCTION=1
       CASE INSTR(1, TXT, " AND ")>0
         '? "Conditional Compiler Directive Found. Incorrect results may occur"+$CRLF+Txt
         FUNCTION=1
    END SELECT
END FUNCTION

TYPE StackType
   PreNot     AS LONG
   PreDef     AS LONG
   EquateName AS STRING * 50
END TYPE

FUNCTION EvalStack(BYVAL Stk      AS StackType,_
                   BYREF EQCnst() AS EquateCnsts) AS LONG

      LOCAL I, Found AS LONG
      LOCAL A$, B$

      A$=Stk.EquateName   : A$=TRIM$(A$)

      Found=0
      FOR I=1 TO UBOUND(EqCnst)
         B$=EqCnst(I).EquateName : B$=TRIM$(B$)
         IF A$=B$ THEN
            Found=I
            EXIT FOR
         END IF
      NEXT

      FUNCTION=%FALSE
      SELECT CASE %TRUE
         CASE Found=0 AND Stk.PreNot AND Stk.PreDef=1 :            FUNCTION=%TRUE
         CASE Found>0
              IF Stk.PreNot=1 AND EqCnst(Found).EquateVal=0   THEN FUNCTION=%TRUE
              IF STK.PreDef=1                                 THEN FUNCTION=%TRUE
              IF EqCnst(Found).EquateVal<>0                   THEN FUNCTION=%TRUE
      END SELECT

END FUNCTION


FUNCTION CompoundCompDirective(BYVAL LineStr  AS STRING,_
                               BYREF CComp()  AS CondComptype, _
                               BYREF EQCnst() AS EquateCnsts) AS LONG

     LOCAL Ands, Ors, AllAnds, AllOrs, Temp   AS LONG

     LOCAL PVar, PDefVar, PNotVar, PNotDefVar AS LONG
     LOCAL What, Tot, I, J                    AS LONG
     LOCAL A$, B$, C$

     Ands   =TALLY(LineStr," AND ")     'How many And conditions do we have?
     Ors    =TALLY(LineStr," OR ")      'How many Or Conditions do we have?
     Tot    =Ands+Ors+1

     DIM   TStack(Tot)        AS StackType
     LOCAL Pieces$()
     LOCAL TStk               AS StackType

     AllAnds=IIF(Ors=0,%TRUE,%FALSE)
     AllOrs =IIF(Ands=0,%TRUE,%FALSE)

     I=INSTR(1,LineStr,"#ELSEIF") : IF I>=1 THEN LineStr=REMOVE$(LineStr,"#ELSEIF ")
     I=INSTR(1,LineStr,"#IF")     : IF I>=1 THEN LineStr=REMOVE$(LineStr,"#IF ")

     GOSUB GimmeTheStack                'Parse LineStr into Stack()

     SELECT CASE %TRUE
         CASE AllOrs     'First True = Good To Go
             FUNCTION=%FALSE
             FOR I=1 TO UBOUND(TStack)
                 IF EvalStack(TStack(I),EQCnst())=%TRUE THEN FUNCTION=%TRUE : EXIT FUNCTION
             NEXT
         CASE AllAnds    'First %FALSE = Bad
             FUNCTION=%TRUE
             FOR I=1 TO UBOUND(TStack)
                 IF EvalStack(TStack(I),EQCnst())=%FALSE THEN FUNCTION=%TRUE : EXIT FUNCTION
             NEXT
         CASE ELSE
             ?  "Mixed AND/OR Compiler Directives Found!"+$CRLF+_
                "Code not implemented yet"+$CRLF+_
                "LineStr="+LineStr
            'FOR I=1 TO UBOUND(TStack)
            'NEXT
     END SELECT

     EXIT FUNCTION

GimmeTheStack:
     J=PARSECOUNT(LineStr," ") 'How many words are there?
     REDIM Pieces$(J)
     PARSE LineStr, Pieces$(), " "

     I=1
     FOR J=1 TO UBOUND(Pieces$)

         SELECT CASE %TRUE
            CASE Pieces$(I)="NOT"
                IF INSTR(1,Pieces$(I+1),"%DEF(")>0  THEN   'NOT %Def(
                    A$=GetADollarFromDEF(Pieces$(J+1))
                    TStack(I).PreNot      =1
                    TStack(I).PreDef      =1
                    J+=1
                ELSE                                       'NOT %ABC
                    A$=Pieces$(J+1)
                    TStack(I).PreNot      =1
                    TStack(I).PreDef      =0
                    J+=1
                END IF
            CASE INSTR(1,Pieces$(I),"%DEF(")>0 :          '%DEF(
                A$=GetADollarFromDEF(Pieces$(J))
                TStack(I).PreNot      =0
                TStack(I).PreDef      =1
            CASE Pieces$(I)="OR"    : ITERATE
            CASE Pieces$(I)="AND"   : ITERATE
            CASE ELSE                           :         '%ABC
                A$=Pieces$(J)
                TStack(I).PreNot      =0
                TStack(I).PreDef      =0
         END SELECT

         TStack(I).EquateName=A$
         INCR I
     NEXT

RETURN


END FUNCTION


FUNCTION SeeIfIncludingIt(BYREF CComp() AS CondCompType) AS LONG
  LOCAL RR, IncludingIt AS LONG
  IncludingIt=%TRUE
  RR=UBOUND(CComp)
  IF RR>=1 THEN
     IF CComp(RR).IncludeIt=%FALSE THEN
        IncludingIt=%FALSE
     END IF
  END IF
  FUNCTION=IncludingIt
END FUNCTION

FUNCTION FindEquate(BYVAL A$, BYREF EQCnst() AS EquateCnsts) AS LONG
  LOCAL QQ1, Found AS LONG
  LOCAL B$, C$
  Found=0
  IF UBOUND(EqCnst)<=0 THEN FUNCTION=0
  FOR QQ1=1 TO UBOUND(EqCnst)
     C$     =SPACE$(50)
     LSET C$=EQCNST(QQ1).EquateName
     B$=TRIM$(C$)
     IF A$=B$ THEN Found=QQ1 : EXIT FOR
  NEXT
  FUNCTION=Found
END FUNCTION


SUB GetEquate(LineStr AS STRING, BYREF EQCnst() AS EquateCnsts)
  LOCAL J, K, M, N, O, L, QQ AS LONG
  LOCAL A$

  J=INSTR(1,  LineStr,"%")     'Position of % (important)
  K=INSTR(J+1,LineStr,"=")     'Position of = (equal sign)
  IF J>=1 AND K>=J THEN
     A$=TRIM$(MID$(LineStr,J,K-J))  'Get Equate Name  'everything btwn % and =
     SELECT CASE %TRUE
       CASE INSTR(1,A$,"(")>0      :  'ie.. IF JulianDate%("01-01-2010)>=5000 THEN
       CASE INSTR(1,A$," THEN ")>0 :  'ie.. IF %ABC THEN Function=0
       CASE INSTR(1,A$,",")>0      :  ' following line continuation %KEY_QUERY_VALUE, hKey) = %ERROR_SUCCESS THEN
       CASE A$="%"                 :  '?? nothing
       CASE ELSE                   :
         M=LEN(LineStr)         'Length of line
         N=INSTR(1,LineStr,":") ': continuation ?
         O=IIF(N>0,MIN(N,M),M)
         L=UBOUND(EqCnst)+1 : REDIM PRESERVE EqCnst(L) AS EquateCnsts
         EqCnst(L).EquateName=A$
         QQ                  =VAL(TRIM$(MID$(LineStr,K+1,M-O-1)))
         EqCnst(L).EquateVal =QQ
         IF N>0 AND N<M THEN  'More to come ?  ie.. %ABC=1 : %DEF=2 etc
           LineStr=RIGHT$(LineStr,M-N)
           CALL GetEquate(LineStr, EqCnst())    'Recursive Call ****
         END IF
     END SELECT
  END IF
END SUB

FUNCTION CheckEquateElseIfDef(BYVAL LineStr  AS STRING, _
                              BYREF CComp()  AS CondCompType, _
                              BYREF EqCnst() AS EquateCnsts) AS LONG
  LOCAL A$
  LOCAL IncludingIt, Found, QQ AS LONG
  LOCAL retval AS LONG

  QQ=UBOUND(CComp)

  A$=GetADollarfromDef(LineStr)                 'A$ has Equate Name in it

  IncludingIt=SeeIfIncludingIt(CComp())         'Returns IncludingIt (see if nested and including in upper level or not)

  IF IncludingIt=%FALSE THEN

     RetVal=CheckForCompoundCompDirective(LineStr)
     IF RetVal>0 THEN
        CComp(QQ).IncludeIt=CompoundCompDirective(LineStr, CComp(), EQCnst())
     ELSE
        Found=FindEquate(A$,EqCnst())              'Returns Found

        IF Found>0 THEN                            'If Found then Defined
           CComp(QQ).IncludeIt =%TRUE
        ELSE
           IF QQ>1 THEN                            '----Nesting
              IF CComp(QQ-1).IncludeIt=%TRUE THEN   'One level up is active
                 CComp(QQ).IncludeIt=%TRUE
              ELSE                                 'One level up is Not Active
                 CComp(QQ).IncludeIt=%FALSE
              END IF
           ELSE                                    '----Not nested
              CComp(QQ).IncludeIt =%FALSE
           END IF
         END IF
     END IF
  ELSE
     CComp(QQ).IncludeIt=%FALSE
  END IF

  FUNCTION=CComp(QQ).IncludeIt

END FUNCTION


FUNCTION CheckEquateElseIfNotDef(BYVAL LineStr AS STRING, _
                                 BYREF CComp() AS CondCompType, _
                                 BYREF EQCnst() AS EquateCnsts) AS LONG

  LOCAL A$
  LOCAL Found, Includingit, QQ AS LONG
  LOCAL retval AS LONG

  A$=GetADollarfromdEF(LineStr)      'Returns A$ (contains the Equatename)

  IncludingIt=SeeIfIncludingIt(CComp())       'Returns IncludingIt (see if nested and including in upper level or not)

  QQ=UBOUND(CComp)

  IF IncludingIt=%FALSE THEN

     RetVal=CheckForCompoundCompDirective(LineStr)
     IF RetVal=%TRUE THEN
        CComp(QQ).IncludeIt=IIF(CompoundCompDirective(LineStr, CComp(), EQCnst())=%TRUE, %FALSE, %TRUE)
     ELSE
        Found=FindEquate(A$, EqCnst())             'Returns Found
        IF Found>0 THEN              'If Found then Defined
           CComp(QQ).IncludeIt =%FALSE
        ELSE
           IF QQ>1 THEN                            '----Nesting
              IF CComp(QQ-1).IncludeIt=%TRUE THEN   'One level up is active
                 CComp(QQ).IncludeIt=%TRUE
              ELSE                                 'One level up is Not Active
                 CComp(QQ).IncludeIt=%FALSE
              END IF
           ELSE                                    '----Not nested
             CComp(QQ).IncludeIt =%TRUE
           END IF
        END IF
     END IF
  ELSE
     CComp(QQ).IncludeIt=%FALSE
  END IF
  FUNCTION=CComp(QQ).IncludeIt
END FUNCTION



SUB CheckEquateIfNotDef(BYVAL LineStr  AS STRING, _
                        BYREF CComp()  AS CondCompType, _
                        BYREF EQCnst() AS EquateCnsts)

  LOCAL retval AS LONG
  LOCAL A$
  LOCAL IncludingIt, Found, QQ AS LONG

  A$         =GetADollarfromDEF(LineStr)      'Returns A$ (Equatename in A$)

  IncludingIt=SeeIfIncludingIt(CComp())       'Returns IncludingIt (see if nested and including in upper level or not)

  QQ=UBOUND(CComp)+1 : REDIM PRESERVE CComp(QQ)
  CComp(QQ).EquateName=A$

  IF IncludingIt=%TRUE THEN

     RetVal=CheckForCompoundCompDirective(LineStr)
     IF RetVal=%TRUE THEN
        CComp(QQ).IncludeIt=IIF(CompoundCompDirective(LineStr, CComp(), EQCnst())=%TRUE, %FALSE, %TRUE)
     ELSE
        Found=FindEquate(A$,EqCnst())             'Returns Found

        IF Found>0 THEN              'If Found then Defined
           CComp(QQ).IncludeIt =%FALSE
        ELSE
           IF QQ>1 THEN  '----Nesting
              IF CComp(QQ-1).IncludeIt=%TRUE THEN   'One level up is active
                 CComp(QQ).IncludeIt=%TRUE
              ELSE                                 'One level up is Not Active
                 CComp(QQ).IncludeIt=%FALSE
              END IF
           ELSE          '----Not nested
              CComp(QQ).IncludeIt =%TRUE
           END IF
        END IF
     END IF
  ELSE
     CComp(QQ).IncludeIt=%FALSE
  END IF


END SUB

SUB CheckEquateIfDef(BYVAL LineStr  AS STRING, _
                     BYREF CComp()  AS CondComptype, _
                     BYREF EQCnst() AS EquateCnsts)

  LOCAL retval, QQ, Found, IncludingIt AS LONG
  LOCAL A$

  A$=GetADollarFromDef(LineStr)

  IncludingIt=SeeIfIncludingIt(CComp())       'Returns IncludingIt (see if nested and including in upper level or not)

  QQ=UBOUND(CComp)+1 : REDIM PRESERVE CComp(QQ)
  CComp(QQ).EquateName=A$

  IF IncludingIt=%TRUE THEN
     RetVal=CheckForCompoundCompDirective(LineStr)
     IF RetVal=%TRUE THEN
        CComp(QQ).EquateName=LineStr
        IF CompoundCompDirective(LineStr, CComp(), EQCnst())=%TRUE THEN
           IF QQ>1 THEN  'We are nesting
              IF CComp(QQ-1).IncludeIt=%TRUE THEN
                 CComp(QQ).Includeit=%TRUE
              ELSE
                 CComp(QQ).Includeit=%FALSE
              END IF
           ELSE          'Not nesting
              CComp(QQ).IncludeIt =%TRUE
           END IF
        ELSE
           CComp(QQ).IncludeIt=%FALSE
        END IF
     ELSE
        Found=FindEquate(A$,EQCnst())

        IF Found>0 THEN              'If Found then Defined
           IF QQ>1 THEN  'We are nesting
              IF CComp(QQ-1).IncludeIt=%TRUE THEN
                 CComp(QQ).Includeit=%TRUE
              ELSE
                 CComp(QQ).Includeit=%FALSE
              END IF
           ELSE          'Not nesting
              CComp(QQ).IncludeIt =%TRUE
           END IF
        ELSE
           CComp(QQ).IncludeIt =%FALSE
        END IF
     END IF
   ELSE
      CComp(QQ).IncludeIt=%FALSE
   END IF
END SUB



SUB CheckEquateNotIf(BYVAL lineStr  AS STRING, _
                     BYREF CComp()  AS CondCompType, _
                     BYREF EqCnst() AS EquateCnsts)
  LOCAL retval AS LONG

  LOCAL QQ, IncludingIt, Found AS LONG
  LOCAL A$

  A$=GetADollarFromDEF(LineStr)

  QQ=UBOUND(CComp)+1 : REDIM PRESERVE CComp(QQ)
  CComp(QQ).EquateName=A$

  IncludingIt=SeeIfIncludingIt(CComp())       'Returns IncludingIt (see if nested and including in upper level or not)

  RetVal=CheckForCompoundCompDirective(LineStr)

  IF IncludingIt=%TRUE THEN
     IF RetVal=%TRUE THEN
        CComp(QQ).EquateName=LineStr
        IF CompoundCompDirective(LineStr, CComp(), EQCnst())=%FALSE THEN
           CComp(QQ).IncludeIt=%TRUE
        ELSE
           CComp(QQ).IncludeIt=%FALSE
        END IF
     ELSE
        Found=FindEquate(A$,EQCnst())

        IF Found>0 THEN
           CComp(QQ).IncludeIt =IIF(EqCnst(Found).EquateVal<>0,%FALSE,%TRUE)
        END IF
     END IF
  ELSE
     CComp(QQ).IncludeIt=%FALSE
  END IF

END SUB


SUB CheckEquateIf(BYVAL LineStr  AS STRING, _
                  BYREF CComp()  AS CondCompType, _
                  BYREF EqCnst() AS EquateCnsts)

  LOCAL QQ, Found, IncludingIt AS LONG
  LOCAL A$

  LOCAL retval AS LONG


  A$=GetADollar(LineStr)

  QQ=UBOUND(CComp)+1 : REDIM PRESERVE CComp(QQ)
  CComp(QQ).EquateName=A$

  IncludingIt=SeeIfIncludingIt(CComp())       'Returns IncludingIt (see if nested and including in upper level or not)

  IF IncludingIt=%TRUE THEN

     RetVal  =CheckForCompoundCompDirective(LineStr)
     IF RetVal>0 THEN

        RetVal=compoundcompDirective(LineStr, CComp(), EQCnst())

        CComp(QQ).IncludeIt =RetVal

     ELSE
        Found=FindEquate(A$,EQCnst())

        IF Found>0 THEN
           CComp(QQ).IncludeIt =IIF(EqCnst(Found).EquateVal<>0,%TRUE,%FALSE)
        END IF
     END IF
  ELSE
     CComp(QQ).IncludeIt=%FALSE
  END IF
END SUB


FUNCTION ChkCondCompile(BYVAL LineStr   AS STRING, _
                        BYREF CComp()   AS CondCompType, _
                        BYREF EqCnsts() AS EquateCnsts) AS LONG

      LOCAL QQ AS LONG
      '------ Conditionally compiled code ??
      FUNCTION=1
      QQ=UBOUND(CComp)   'UDT Array of conditional compiles
      IF QQ>=1 THEN
         SELECT CASE %TRUE
            CASE INSTR(1,LineStr,"#ELSEIF %DEF(")>0
                FUNCTION=CheckEquateElseIfDef(LineStr, CComp(), EqCnst())
            CASE INSTR(1,LineStr,"#ELSEIF NOT %DEF(")>0
                FUNCTION=CheckEquateElseIfNotDef(LineStr, CComp(), EQCnst())
            CASE INSTR(1,LineStr,"#ELSE") >0 :
                'CComp(QQ).IncludeIt=IIF(CComp(QQ).IncludeIt=%TRUE,%FALSE,%TRUE) (Doesn't allow for nesting)
                IF CComp(QQ).IncludeIt=%TRUE THEN  'If you were including... Then now don't
                   CComp(QQ).IncludeIt=%FALSE
                ELSE
                   IF QQ>1 THEN     '----doing nested stuff
                      IF CComp(QQ-1).IncludeIt=%FALSE THEN  'Weren't doing anything before
                         'Weren't doing anything before.. still not supposed to include it
                      ELSE                                 'Were including
                         CComp(QQ).IncludeIt=IIF(CComp(QQ).IncludeIt=%TRUE,%FALSE,%TRUE) 'Works for Not Nested
                      END IF
                   ELSE             '----not nested
                      CComp(QQ).IncludeIt=IIF(CComp(QQ).IncludeIt=%TRUE,%FALSE,%TRUE) 'Works for Not Nested
                   END IF
                END IF
                FUNCTION=IIF(QQ>0,CComp(QQ).IncludeIt,%TRUE)
                EXIT FUNCTION
            CASE INSTR(1,LineStr,"#ENDIF")>0 :
                QQ-=1
                IF QQ<0 THEN ? "Err="+STR$(ERR)
                REDIM PRESERVE CComp(QQ)
                FUNCTION=IIF(UBOUND(CComp)>0,CComp(QQ).IncludeIt,%TRUE)
                EXIT FUNCTION
            CASE INSTR(1,LineStr,"#IF %")>0 :
                CALL CheckEquateIf(LineStr, CComp(), EqCnst())
                FUNCTION=IIF(UBOUND(CComp)>0,CComp(UBOUND(CComp)).IncludeIt,%TRUE)
            CASE ELSE
                IF CComp(QQ).IncludeIt=%FALSE THEN
                   FUNCTION=0
                   EXIT FUNCTION
                ELSE
                   'Keep on Rolling
                END IF
         END SELECT
      END IF

END FUNCTION




'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Main entrance - create dialog, etc.
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
FUNCTION WINMAIN (BYVAL hCurInstance  AS LONG, _
                  BYVAL hPrevInstance AS LONG, _
                  BYVAL lpszCmdLine         AS ASCIIZ PTR, _
                  BYVAL nCmdShow      AS LONG) AS LONG

  LOCAL hDlg AS LONG, iCnt AS LONG, rc AS RECT, tmpIncDir AS STRING, tmpStr AS STRING
  LOCAL I AS LONG
  REDIM sIncDir(0)
  REDIM EqCnst(0)       AS EquateCnsts
  REDIM CComp(0)        AS CondCompType

  'False=0 : True= NOT False

  DIALOG NEW 0, "PBcodec v1.5", , , 200,200, %WS_CAPTION OR %WS_MINIMIZEBOX OR %WS_SYSMENU TO hDlg
  IF hDlg = 0 THEN EXIT FUNCTION

  CONTROL ADD LABEL,    hDlg, 114, "",              2,  2, 192, 20, %SS_CENTER, %WS_EX_CLIENTEDGE
  CONTROL ADD LABEL,    hDlg, 115, " Main file: ",  2, 27, 161, 10

  CONTROL ADD CHECKBOX, hDlg, %CheckBox_UnusedFxs,     "Unused Functions",           6, 54, 80, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_UnusedSubs,    "Unused Subs ",               6, 64, 80, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_UnusedGlobals, "Unused Globals",             6, 74, 80, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_UnusedLocals,  "Unused Locals",              6, 84, 80, 10



  CONTROL ADD CHECKBOX, hDlg, %IDC_CheckBox2, "Non-Declared Subs/Fcns",                      6,107, 90, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_DeclaredButNonExistant, "Declared but non-existant", 6,117, 94, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_GlobalLocalMix, "Global/Local Mix",                  6,127, 80, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_DupeGlobal,     "Duplicate Globals",                 6,137, 90, 10


  CONTROL ADD CHECKBOX, hDlg, %CheckBox_GlobalVariableRpt, "Global Variable", 102, 54, 75, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_ConstantsRpt,      "Constants " ,     102, 64, 75, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_Includes,          "Includes ",       102, 74, 75, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_StringLiterals,    "String Literal ", 102, 84, 75, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_TotRefCount,       "Functions ",      102, 94, 75, 10
  CONTROL ADD CHECKBOX, hDlg, %CheckBox_SubRefCount,       "Subroutines",     102,104, 75, 10


  CONTROL ADD FRAME,    hDlg, %Frame1, "Options",  2, 36, 193, 145
  CONTROL ADD FRAME,    hDlg, %Frame2, "Unused",   4, 45,  94,  53
  CONTROL ADD FRAME,    hDlg, %Frame3, "Reports",100, 45,  80,  75


  CONTROL SET CHECK     hDlg, %IDC_CheckBox2                   , 1
  CONTROL SET CHECK     hDlg, %CheckBox_Includes               , 1
  CONTROL SET CHECK     hDlg, %CheckBox_UnusedFxs              , 1
  CONTROL SET CHECK     hDlg, %CheckBox_UnusedSubs             , 1
  CONTROL SET CHECK     hDlg, %CheckBox_DeclaredButNonExistant , 1
  CONTROL SET CHECK     hDlg, %CheckBox_UnusedGlobals          , 1
  CONTROL SET CHECK     hDlg, %CheckBox_UnusedLocals           , 1
  CONTROL SET CHECK     hDlg, %CheckBox_GlobalLocalMix         , 1
  CONTROL SET CHECK     hDlg, %CheckBox_DupeGlobal             , 1
  CONTROL SET CHECK     hDlg, %CheckBox_TotRefCount            , 1
  CONTROL SET CHECK     hDlg, %CheckBox_SubRefCount            , 1
  CONTROL SET CHECK     hDlg, %CheckBox_GlobalVariableRpt      , 1
  CONTROL SET CHECK     hDlg, %CheckBox_StringLiterals         , 1
  CONTROL SET CHECK     hDlg, %CheckBox_ConstantsRpt           , 1



  CONTROL ADD BUTTON,   hDlg, %Btn_Unused,  "Unused"           , 120, 121, 45, 13
  CONTROL ADD BUTTON,   hDlg, %Btn_Reports, "Reports"          , 120, 135, 45, 13
  CONTROL ADD BUTTON,   hDlg, %Btn_SelectAll, "Select All",      120, 149, 45, 13
  CONTROL ADD BUTTON,   hDlg, %Btn_UnSelectAll, "UnSelect All",   50, 149, 45, 13


  CONTROL ADD BUTTON,   hDlg, 120, " &Browse..",                   4,183,  50, 14
  CONTROL ADD BUTTON,   hDlg, %IDOK, "&Scan",                     58,183,  50, 14
  CONTROL ADD BUTTON,   hDlg, %IDCANCEL, "&Quit",                112,183,  50, 14

  CONTROL DISABLE hDlg, %IDOK

  tmpIncDir = GetIncludeDir                              'grab include path from registry
  IF LEN(tmpIncDir) THEN                                 'if we got anything
     IF INSTR(tmpIncDir, ";") THEN                       'if it contains multiple paths
        FOR I = 1 TO PARSECOUNT(tmpIncDir, ";")          'loop through string
           tmpStr = TRIM$(PARSE$(tmpIncDir, ";", I))     'parse out each path
           IF LEN(tmpStr) AND TRIM$(DIR$(tmpStr))<>"" THEN        'if we got a path and it exists
              REDIM PRESERVE sIncDir(iCnt)               'prepare array
              IF ASC(tmpStr, -1) = 92 THEN               'if a path with trailing backslash
                 sIncDir(iCnt) = tmpStr                  'store path in array element
              ELSE                                       'else
                  sIncDir(iCnt) = tmpStr + "\"           'make sure it has a trailing backslash
              END IF
              INCR iCnt                                  'increase temporary array counter
           END IF
        NEXT

     ELSE                                                'else, single path was given
        IF TRIM$(DIR$(tmpIncDir))<>"" THEN                        'if it exists
           IF ASC(tmpIncDir, -1) = 92 THEN               'if a path with trailing backslash
              sIncDir(0) = tmpIncDir                     'store path in first array element
           ELSE                                          'else
              sIncDir(0) = tmpIncDir + "\"               'make sure it has a trailing backslash
           END IF
        END IF
     END IF
  END IF

  SystemParametersInfo %SPI_GETWORKAREA, BYVAL 0, BYVAL VARPTR(rc), 0      'grab desktop cordinates
  DIALOG PIXELS hDlg, rc.nRight, rc.nBottom TO UNITS rc.nRight, rc.nBottom 'convert to dialog units
  DIALOG SET LOC hDlg, rc.nRight - 220, rc.nBottom - 220                   'place dialog bottom, right
  SetWindowPos hDlg, %HWND_TOPMOST, 0, 0, 0, 0, %SWP_NOMOVE OR %SWP_NOSIZE 'set dialog topmost
  DragAcceptFiles     hDlg, %True                                          'enable drag&drop

  REDIM exclude(24) 'exclude these string literals
  exclude(0)  = "WIN32API.INC"  : exclude(1)  = "COMDLG32.INC"
  exclude(2)  = "COMMCTRL.INC"  : exclude(3)  = "DDT.INC"
  exclude(4)  = "MDI32.INC"     : exclude(5)  = "COMBO32.INC"
  exclude(6)  = "LISTVIEW.INC"  : exclude(7)  = "TRVIEW32.INC"
  exclude(8)  = "RICHEDIT.INC"  : exclude(9)  = "EDIT32.INC"
  exclude(10) = "BUTTON32.INC"  : exclude(11) = "MMSYSTEM.INC"
  exclude(12) = "WSOCK32.INC"   : exclude(13) = "STATIC32.INC"
  exclude(14) = "DPMI.INC"      : exclude(15) = "LZEXPAND.INC"
  exclude(16) = "TOOLHLP.INC"   : exclude(17) = "VBAPI.INC"
  exclude(18) = "CTL3D.INC"     : exclude(19) = "VER.INC"
  exclude(20) = "WINAPI.INC"    : exclude(21) = "WINSOCK.INC"
  exclude(22) = "COMMDLG.INC"   : exclude(23) = "PROGRAM"
  exclude(24) = "WIN32API.INC"

  DIALOG SHOW MODAL hDlg CALL WinMainProc
END FUNCTION

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Main callback procedure
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
CALLBACK FUNCTION WinMainProc() AS LONG

  SELECT CASE CBMSG
     CASE %WM_INITDIALOG
         REDIM Files(1)  ' Reset Array
         REDIM infile(1)
         IF LEN(COMMAND$) THEN
             IF GetCommandFile(COMMAND$, Files()) THEN ' Retrieve the contents of the Command String
                LOCAL sTimer AS LONG
                sTimer = SETTIMER(CBHNDL, 1, 400, %NULL) ' wait for window to draw
             END IF
         ELSE
             CONTROL SET TEXT CBHNDL, 114, "Drag && Drop a main source file on dialog, " + $CRLF + _
                                           "or use Browse to select a file to Scan.."
         END IF

     CASE %WM_CTLCOLORSTATIC
        IF CBLPARAM = GetDlgItem(CBHNDL, 114) THEN
           SetBkColor CBWPARAM, GetSysColor(%COLOR_INFOBK)
           FUNCTION = GetSysColorBrush(%COLOR_INFOBK)
        END IF

     CASE %WM_TIMER
         KILLTIMER  CBHNDL, 1
         CALL DoInitProcess(CBHNDL, Files(0))

     CASE %WM_DROPFILES
         REDIM Files(1) ' Reset Array
         REDIM infile(1)
         IF GetDroppedFile(CBWPARAM, Files()) THEN       ' Retrieve the Dropped filenames
            CALL DoInitProcess(CBHNDL, Files(0))
         END IF

     CASE %WM_DESTROY
        CALL DragAcceptFiles(CBHNDL, 0)

     CASE %WM_COMMAND
        SELECT CASE CBCTL

           CASE %BTN_Unused
              CONTROL SET CHECK  CBHNDL,   %CheckBox_UnusedFxs              , 1
              CONTROL SET CHECK  CBHNDL,   %CheckBox_UnusedSubs             , 1
              CONTROL SET CHECK  CBHNDL,   %CheckBox_UnusedGlobals          , 1
              CONTROL SET CHECK  CBHNDL,   %CheckBox_UnusedLocals           , 1

           CASE %Btn_Reports

              CONTROL SET CHECK  CBHNDL,  %CheckBox_Includes               , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_TotRefCount            , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_SubRefCount            , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_GlobalVariableRpt      , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_ConstantsRpt           , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_StringLiterals         , 1

           CASE %Btn_SelectAll
              CONTROL SET CHECK  CBHNDL,  %IDC_CheckBox2                   , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_Includes               , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedFxs              , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedSubs             , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_DeclaredButNonExistant , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedGlobals          , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedLocals           , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_GlobalLocalMix         , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_DupeGlobal             , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_TotRefCount            , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_SubRefCount            , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_GlobalVariableRpt      , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_StringLiterals         , 1
              CONTROL SET CHECK  CBHNDL,  %CheckBox_ConstantsRpt           , 1

           CASE %Btn_UnSelectAll
              CONTROL SET CHECK  CBHNDL,  %IDC_CheckBox2                   , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_Includes               , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedFxs              , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedSubs             , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_DeclaredButNonExistant , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedGlobals          , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_UnusedLocals           , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_GlobalLocalMix         , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_DupeGlobal             , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_TotRefCount            , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_SubRefCount            , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_GlobalVariableRpt      , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_StringLiterals         , 0
              CONTROL SET CHECK  CBHNDL,  %CheckBox_ConstantsRpt           , 0

           CASE 120 'Browse
              LOCAL STYLE AS DWORD, fName AS STRING, Buffer AS STRING, PATH AS STRING

              STYLE  = %OFN_EXPLORER OR %OFN_FILEMUSTEXIST OR %OFN_HIDEREADONLY
              fName  = "*.BAS"
              Buffer = "PB Code files (*.BAS)|*.BAS|"
              PATH   = CURDIR$

              IF OpenFileDialog(CBHNDL, "", fName, PATH, Buffer, "BAS" , STYLE) THEN
                 REDIM Files(1)  ' Reset Array
                 REDIM infile(1)
                 Files(0) = fName
                 fName = MID$(fName, INSTR(-1, fName, "\") + 1)
                 CONTROL SET TEXT CBHNDL, 115, " Main file: " & UCASER(fName)
                 CONTROL ENABLE CBHNDL, %IDOK
                 CALL DoInitProcess(CBHNDL, Files(0)) '<- deactivate, if not to scan directly..
              END IF

           CASE %IDOK
              REDIM PRESERVE Files(1)
              CALL DoInitProcess(CBHNDL, Files(0)) 'scan file

           CASE %IDCANCEL        ' Quit
               Done = 1          ' jump out of any loops
               DIALOG END CBHNDL ' and QUIT

        END SELECT
  END SELECT
END FUNCTION

'************************************************************************
' Initiate and run entire process
'************************************************************************
SUB DoInitProcess(BYVAL hDlg AS LONG, BYVAL fName AS STRING)
  LOCAL ci AS LONG, mc AS LONG
  FOR ci = 1 TO 10 : DIALOG DOEVENTS : NEXT

  IF TRIM$(DIR$(fName))<>"" THEN 'make sure it exists
     ci = IsFileMain(fName)  'if a #COMPILE statement exists (main source file)

     SELECT CASE ci
        CASE -3          'if return is -3, file was empty
           ?  "Selected file is empty.",,"Error!"
           EXIT SUB

        CASE -2      'if return is -2, file could not be opened
           ?  "Selected file could not be opened!",,"Error!"
           EXIT SUB

        CASE >1      'if return is > 1, file was not a main source file
           ?  "Selected file does not contain a #COMPILE statement.",,"Error!"
           EXIT SUB
     END SELECT

  ELSE                       'else, it didn't even exist..
     MSGBOX "Could not open this file:" + $CRLF + fName + $CRLF + $CRLF + _
            "Please make sure it exists and try again.",,"Error!"
     EXIT SUB
  END IF

  CONTROL GET CHECK hDlg, %CheckBox_StringLiterals          TO getStrings 'Extract Strings
  CONTROL GET CHECK hDlg, %IDC_CheckBox2                    TO NotDecl    'Extract Strings

  CONTROL GET CHECK hDlg, %CheckBox_Includes                TO Do_Includes_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_UnusedFxs               TO Do_UnusedFxs_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_UnusedSubs              TO Do_UnusedSubs_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_DeclaredButNonExistant  TO Do_DeclaredButNonExistant_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_UnusedGlobals           TO Do_UnusedGlobals_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_UnusedLocals            TO Do_UnusedLocals_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_GlobalLocalMix          TO Do_GlobalLocalMix_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_DupeGlobal              TO Do_DupeGlobal_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_TotRefCount             TO Do_TotRefCount_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_SubRefCount             TO Do_SubRefCount_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_GlobalVariableRpt       TO Do_GlobalVariableRpt_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_StringLiterals          TO Do_StringLiterals_Rpt
  CONTROL GET CHECK hDlg, %CheckBox_ConstantsRpt            TO Do_Constants_Rpt

  CONTROL DISABLE hDlg, 120
  CONTROL DISABLE hDlg, %IDOK
  CONTROL DISABLE hDlg, %IDC_CheckBox2
  CONTROL DISABLE hDlg, %CheckBox_Includes
  CONTROL DISABLE hDlg, %CheckBox_UnusedFxs
  CONTROL DISABLE hDlg, %CheckBox_UnusedSubs
  CONTROL DISABLE hDlg, %CheckBox_DeclaredButNonExistant
  CONTROL DISABLE hDlg, %CheckBox_UnusedGlobals
  CONTROL DISABLE hDlg, %CheckBox_UnusedLocals
  CONTROL DISABLE hDlg, %CheckBox_GlobalLocalMix
  CONTROL DISABLE hDlg, %CheckBox_DupeGlobal
  CONTROL DISABLE hDlg, %CheckBox_TotRefCount
  CONTROL DISABLE hDlg, %CheckBox_SubRefCount
  CONTROL DISABLE hDlg, %CheckBox_GlobalVariableRpt
  CONTROL DISABLE hDlg, %CheckBox_StringLiterals
  CONTROL DISABLE hDlg, %CheckBox_ConstantsRpt

  FilePathStr = LEFT$(fName, INSTR(-1, fName, "\"))
  FileNameStr = MID$(fName, INSTR(-1, fName, "\") + 1)
  CONTROL SET TEXT hDlg, 115, " Main file: " & UCASER(FileNameStr)

  IF Files(0) = "" THEN Files(0) = fName
  CHDRIVE LEFT$(FilePathStr, 2)
  CHDIR FilePathStr

  CONTROL SET TEXT hDlg, 114, "Collecting include files"
  REDIM EqCnst(0)

  gCountCRLFs=1   'Turn the count on

  DoGetIncFiles fName

  iFuncts = 0 : REDIM Functs(0)
  igVars  = 0 : REDIM gVars(0)
  ilVars  = 0 : REDIM lVars(0)
  iVars   = 0 : REDIM Vars(0)
  igDbl   = 0 : REDIM gDbl(0)
  DeclCount = 0 : REDIM gDecl(0)
  sStrCount = 0 : REDIM sString(0)
  gTotLines = 0
  t = TIMER

  REDIM EqCnst(0)
  REDIM CComp(0)
  REDIM CondCompile2(0)
  REDIM EquateConst2(0)

  FOR mc = 0 TO 1
     IF mc=1 THEN gCountCRLFS=0 'Turn the count off

     REDIM CondCompile2(0) AS CondCompType
     REDIM EquateConst2(0) AS EquateCnsts

     FOR ci = 0 TO UBOUND(Files)
        SELECT CASE UCASE$(MID$(Files(ci), INSTR(-1, Files(ci), "\") + 1))       'ignore these
           CASE "WIN32API.INC", "COMDLG32.INC", "COMMCTRL.INC", "COMBO32.INC", _
                "DDT.INC", "MDI32.INC", "LISTVIEW.INC", "TRVIEW32.INC", "RICHEDIT.INC", _
                "EDIT32.INC", "BUTTON32.INC", "MMSYSTEM.INC", "WSOCK32.INC", _
                "STATIC32.INC", "DPMI.INC", "LZEXPAND.INC", "TOOLHLP.INC", "VBAPI.INC", _
                "CTL3D.INC", "VER.INC", "WINAPI.INC", "WINSOCK.INC", "COMMDLG.INC"
           CASE ELSE
              IF mc = 0 THEN
                 CONTROL SET TEXT hDlg, 114, "Scanning for Local vars, Subs and Functions in: " + _
                             MID$(Files(ci), INSTR(-1, Files(ci), "\") + 1)
              ELSE
                 CONTROL SET TEXT hDlg, 114, "Scanning for Global vars in: " + _
                             MID$(Files(ci), INSTR(-1, Files(ci), "\") + 1)
              END IF
              DoProcess Files(ci), ci, mc
        END SELECT
     NEXT
     IF mc = 0 THEN
        IF iFuncts   THEN REDIM PRESERVE Functs(iFuncts)
        IF igVars    THEN REDIM PRESERVE gVars(igVars)
        IF ilVars    THEN REDIM PRESERVE lVars(ilVars)
        IF igDbl     THEN REDIM PRESERVE gDbl(igDbl)
        IF DeclCount THEN REDIM PRESERVE gDecl(DeclCount)
        IF sStrCount THEN REDIM PRESERVE sString(sStrCount)
     END IF
  NEXT
  t = TIMER - t

  CONTROL ENABLE hDlg, 120
  CONTROL ENABLE hDlg, %IDOK
  CONTROL ENABLE hDlg, %IDC_CheckBox2
  CONTROL ENABLE hDlg, %CheckBox_Includes
  CONTROL ENABLE hDlg, %CheckBox_UnusedFxs
  CONTROL ENABLE hDlg, %CheckBox_UnusedSubs
  CONTROL ENABLE hDlg, %CheckBox_DeclaredButNonExistant
  CONTROL ENABLE hDlg, %CheckBox_UnusedGlobals
  CONTROL ENABLE hDlg, %CheckBox_UnusedLocals
  CONTROL ENABLE hDlg, %CheckBox_GlobalLocalMix
  CONTROL ENABLE hDlg, %CheckBox_DupeGlobal
  CONTROL ENABLE hDlg, %CheckBox_TotRefCount
  CONTROL ENABLE hDlg, %CheckBox_SubRefCount
  CONTROL ENABLE hDlg, %CheckBox_GlobalVariableRpt
  CONTROL ENABLE hDlg, %CheckBox_StringLiterals
  CONTROL ENABLE hDlg, %CheckBox_ConstantsRpt

  CONTROL SET TEXT hDlg, 114, "Done! Drag && Drop a main source file on dialog, " + $CRLF + _
                              "or use Browse to select a file to Scan.."
  CALL DoSaveResults

END SUB

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Get all included files into array
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

FUNCTION DoGetIncFiles(BYVAL TheFile AS STRING) AS LONG
  LOCAL ci AS LONG, ii AS LONG, sTemp2 AS STRING
  LOCAL A$, B$, C$
  LOCAL I, J, K, L, M, N, O, QQ, RR, SS, Found, retval AS LONG
  LOCAL IncludingIt AS LONG
  REDIM tmpFiles(0) AS STRING
  REDIM Arr$(0)

  I=ReadFile(TheFile,Arr$())     '----Bas file goes into Arr$()

  FOR I=1 TO UBOUND(Arr$)
      LineStr=Arr$(I)        'Starting point
      LineStr=TRIM$(LineStr)
      '----- handle comments started with '
      J=INSTR(1,LineStr,"'") 'Any Comments?
      IF J>0 THEN
         IF J=1 THEN ITERATE FOR         '1st char is comment marker
         LineStr=LEFT$(LineStr,J-1)      'eliminate comments
      END IF
      '------ handle comments started with REM
      J=INSTR(1,LineStr,"REM ")
      SELECT CASE J
         CASE 0    :                     'No comment
         CASE 1    : ITERATE FOR         '1st char is comment
         CASE ELSE : A$=MID$(LineStr,J-1,1)
                     IF A$=" " OR A$=":" THEN LineStr=LEFT$(LineStr,MAX(1,J-2)) 'eliminate comments
      END SELECT
      '--- Didn't work... below
      'Replace Any "  " With " " in LineStr  '#IF    %ABC
      DO
         J=INSTR(1,LineStr,"  ")
         IF J=0 THEN EXIT DO
         LineStr=STRDELETE$(LineStr,j,1)
      LOOP

      IF TRIM$(LineStr)="" THEN ITERATE FOR

      RetVal=ChkCondCompile(lineStr, CComp(), EqCnst())  'Returns 0 if we are not taking the code

      SELECT CASE RetVal
         CASE 0 : ITERATE FOR
         CASE ELSE 'flow thru
      END SELECT


      '------- start looking for triggers in source code
      SELECT CASE %TRUE
          CASE INSTR(1,LineStr,"#INCLUDE ")>0
              J=UBOUND(CComp)
              SELECT CASE %TRUE
                 CASE J<1
                    GOSUB GetInclude 'No Nests Then Go Get It
                 CASE J>0 AND CComp(J).IncludeIt=%TRUE :                  'Nested
                    GOSUB GetInclude
              END SELECT
          CASE INSTR(1,LineStr,"$INCLUDE ")    >0
              J=UBOUND(CComp)
              SELECT CASE %TRUE
                 CASE J<1
                    GOSUB GetInclude 'No Nests Then Go Get It
                 CASE J>0 AND CComp(J).IncludeIt=%TRUE :                  'Nested
                    GOSUB GetInclude
              END SELECT
          CASE INSTR(1,LineStr,"#IF %DEF(")    >0 : CALL CheckEquateIfDef(LineStr,    CComp(), EqCnst())
          CASE INSTR(1,LineStr,"#IF NOT %DEF(")>0 : CALL CheckEquateIfNotDef(LineStr, CComp(), EqCnst())
          CASE INSTR(1,LineStr,"#IF NOT %")    >0 : CALL CheckEquateNotIF(LineStr,    CComp(), EqCnst())
          CASE INSTR(1,LineStr,"#IF %")        >0 : CALL CheckEquateIF(LineStr,       CComp(), EqCnst())
          CASE INSTR(1,LineStr,"%")            >0
             IF INSTR(1,LineStr,"FDST(")=0 THEN  'Kludge
               CALL GetEquate(LineStr,EQCnst())
             END IF
      END SELECT
  NEXT

  EXIT FUNCTION



GetInclude:
   sWork = PARSE$(LineStr, CHR$(34), 2)     'get filename

   IF LEFT$(sWork, 2) = ".\" THEN  'resolve eventual relative paths
      sWork = FilePathStr + MID$(sWork, 2)
   ELSEIF LEFT$(sWork, 3) = "..\" THEN
      sWork = LEFT$(FilePathStr, INSTR(-2, FilePathStr, "\")) + MID$(sWork, 4)
   ELSEIF LEFT$(sWork, 4) = "...\" THEN
      sTemp2 = LEFT$(FilePathStr, INSTR(-2, FilePathStr, "\"))
      sWork = LEFT$(sTemp2, INSTR(-2, sTemp2, "\")) + MID$(sWork, 5)
   ELSEIF LEFT$(sWork, 5) = "....\" THEN
      sTemp2 = LEFT$(FilePathStr, INSTR(-2, FilePathStr, "\"))
      sTemp2 = LEFT$(sTemp2, INSTR(-2, sTemp2, "\"))
      sWork = LEFT$(sTemp2, INSTR(-2, sTemp2, "\")) + MID$(sWork, 6)
   ELSEIF LEFT$(sWork, 6) = ".....\" THEN
      sTemp2 = LEFT$(FilePathStr, INSTR(-2, FilePathStr, "\"))
      sTemp2 = LEFT$(sTemp2, INSTR(-2, sTemp2, "\"))
      sTemp2 = LEFT$(sTemp2, INSTR(-2, sTemp2, "\"))
      sWork = LEFT$(sTemp2, INSTR(-2, sTemp2, "\")) + MID$(sWork, 7)
   ELSEIF LEFT$(sWork, 7) = "......\" THEN
      sTemp2 = LEFT$(FilePathStr, INSTR(-2, FilePathStr, "\"))
      sTemp2 = LEFT$(sTemp2, INSTR(-2, sTemp2, "\"))
      sTemp2 = LEFT$(sTemp2, INSTR(-2, sTemp2, "\"))
      sTemp2 = LEFT$(sTemp2, INSTR(-2, sTemp2, "\"))
      sWork = LEFT$(sTemp2, INSTR(-2, sTemp2, "\")) + MID$(sWork, 8)
   END IF

   IF INSTR(-1, sWork, ".") = 0 THEN          'if no file extension is given,
      sWork += ".BAS"                         'compiler assumes .BAS file
   END IF

   'if no path is given, compiler will first look in include dir, so we better start there
   IF INSTR(sWork, "\") = 0 THEN                          'if no path given
      FOR ii = 0 TO UBOUND(sIncDir)                       'loop through the ones we have
         IF TRIM$(DIR$(sIncDir(ii) + sWork))<>"" THEN              'if file exists
            sWork = sIncDir(ii) + sWork                   'use it
         END IF
      NEXT
   END IF

   IF LEN(FilePathStr) AND TRIM$(DIR$(FilePathStr + sWork))<>"" THEN 'try with current file's path
      sWork = FilePathStr + sWork                      'if ok, use it
   END IF

   IF TRIM$(DIR$(sWork))<>"" THEN                          'safety check - if we can find what we got..
      sWork=UCASE$(sWork)                                  'store path + name in temporary array
      SELECT CASE MID$(Files(ci), INSTR(-1, swork, "\") + 1)
        CASE "WIN32API.INC", "COMDLG32.INC","COMMCTRL.INC","COMBO32.INC" , _
             "DDT.INC"     , "MDI32.INC"   ,"LISTVIEW.INC","TRVIEW32.INC", _
             "RICHEDIT.INC", "EDIT32.INC"  ,"BUTTON32.INC","MMSYSTEM.INC", _
             "WSOCK32.INC",  "STATIC32.INC","DPMI.INC"    ,"LZEXPAND.INC", _
             "TOOLHLP.INC",  "VBAPI.INC"   ,"CTL3D.INC"   ,"VER.INC"     , _
             "WINAPI.INC",   "WIN32API.Inc","WINSOCK.INC" ,"COMMDLG.INC" : 'Do nothing
        CASE ELSE                         :
            Found=0
            ARRAY SCAN Files(),=swork, TO Found '#include once ... laziness
            IF Found=0 THEN
               QQ=UBOUND(files)
               A$=files(QQ) : A$=REMOVE$(A$,ANY CHR$(0))
               IF TRIM$(A$)="" THEN
                  Files(QQ)  =swork
                  InFile(QQ)=MID$(TheFile, INSTR(-1, TheFile, "\") + 1)
               ELSE
                  INCR QQ
                  REDIM PRESERVE files(QQ)  : Files(QQ)  =swork
                  REDIM PRESERVE infile(QQ) : InFile(QQ)=MID$(TheFile, INSTR(-1, TheFile, "\") + 1)
               END IF
               CALL DoGetIncFiles(swork) 'recursive call to get eventual includes in includes
            END IF
       END SELECT
   END IF
RETURN

END FUNCTION


'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Trim away all leading/ending non-letters and digits from a string
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
FUNCTION AnsiTRIM(BYVAL TXT AS STRING) AS STRING
  LOCAL pos1 AS LONG, pos2 AS LONG

  FOR pos1 = 1 TO LEN(TXT)
     IF IsCharAlphaNumeric(ASC(TXT, pos1)) THEN EXIT FOR
  NEXT
  FOR pos2 = LEN(TXT) TO 1 STEP -1
     IF IsCharAlphaNumeric(ASC(TXT, pos2)) THEN EXIT FOR
  NEXT

  IF Pos2 > Pos1 THEN FUNCTION = MID$(TXT, Pos1, Pos2 - Pos1 + 1)

END FUNCTION

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Load text from file, extract lines and get all subs, functions and globals
' into arrays.
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
FUNCTION DoProcess(BYVAL TheFile AS STRING, BYVAL fNum AS LONG, WhatRun AS LONG) AS LONG

  IF TRIM$(DIR$(TheFile))="" THEN EXIT FUNCTION  'if file doesn't exist, exit

  LOCAL ci AS LONG, I AS LONG, p AS LONG, Letter AS BYTE PTR, Letter2 AS BYTE PTR
  LOCAL Ac AS LONG, K AS LONG, sFlag AS LONG, QuotePos AS LONG, QuotePos2 AS LONG, dbl AS LONG, dUscored AS LONG
  LOCAL exported AS LONG, x AS LONG, y AS LONG, uscoredGlobal AS LONG, endRout AS LONG, fUscored AS LONG
  LOCAL di AS LONG, lngPOS AS LONG, wordFlag AS LONG, StrFlag AS LONG, dFlag AS LONG, inPar AS LONG
  LOCAL locX AS LONG, locY AS LONG, locPos AS LONG, uscoredLocal AS LONG, iv AS LONG, isGLOBAL AS LONG
  LOCAL MainStr AS STRING, sBuf AS STRING, TXT AS STRING, Buf AS STRING, fsName AS STRING, strDump AS STRING
  LOCAL Retval, J, II AS LONG

  DIM   ArrTxt(0)       AS STRING
  LOCAL A$

  II=ReadFile(TheFile,ArrTxt())
  IF II<2 THEN EXIT FUNCTION

'--------------------------------------------------------------------
' scan MainStr and extract lines
'--------------------------------------------------------------------
  FOR II=1 TO UBOUND(ArrTxt)
      TXT=ArrTxt(II)
      GOSUB ExtractLine
  NEXT


EXIT FUNCTION

'---------------------------------------------------------
' Extract line from main text
'---------------------------------------------------------
ExtractLine:
  '--------------------------------------------------------------------
  ' blank out text within double quotes
  '--------------------------------------------------------------------
  QuotePos = INSTR(TXT, $DQ)                   'see if there is any
  IF QuotePos THEN
     DO                                        'loop while there is any left
        QuotePos2 = INSTR(QuotePos + 1, TXT, $DQ) 'look for matching pair
        IF QuotePos2 THEN
           IF WhatRun = 0 AND getStrings = 1 THEN 'if to extract string literals
              strDump = AnsiTRIM(MID$(TXT, QuotePos, QuotePos2 - QuotePos + 1))
              IF LEN(strDump) THEN
                 ARRAY SCAN exclude(), FROM 1 TO LEN(strDump), COLLATE UCASE, = strDump, TO Ac
                 IF Ac = 0 THEN
                    IF sStrCount MOD 20 = 0 THEN REDIM PRESERVE sString(sStrCount + 20)
                   'sString(sStrCount) = FORMAT$(fNum) + $TAB + USING$("####", I) + $TAB  + strDump
                    sString(sStrCount) = FORMAT$(fNum) + $TAB + USING$("####", II) + $TAB  + strDump
                    INCR sStrCount
                 END IF
              END IF
           END IF
           MID$(TXT, QuotePos, QuotePos2 - QuotePos + 1) = SPACE$(QuotePos2 - QuotePos + 1)
           QuotePos = INSTR(QuotePos2 + 1, TXT, $DQ)
           IF QuotePos = 0 THEN EXIT DO
        ELSE
           EXIT DO
        END IF
     LOOP
  END IF

  TXT = LTRIM$(EXTRACT$(TXT, "'"))              'cut off ev. uncommented part and trim away leading spaces
  IF ASC(TXT) = 82 AND LEFT$(TXT, 4) = "REM " THEN RETURN 'if whole line in uncommented
  IF INSTR(TXT, " REM ") THEN
     TXT = LEFT$(TXT, INSTR(TXT, "REM ")) 'same here, if REM was used
  END IF
  IF INSTR(TXT, " _") THEN
     TXT = LEFT$(TXT, INSTR(TXT, " _") + 2)      'if line wraps to next, ignore the rest of it
  ELSEIF INSTR(TXT, ",_ ") THEN
     TXT = LEFT$(TXT, INSTR(TXT, ",_ ")) + " _"  'adjust to parser
  ELSEIF RIGHT$(TXT, 2) = ",_" THEN
     TXT = LEFT$(TXT, LEN(TXT) - 2) + " _"       'adjust to parser
  END IF
  IF ASC(TXT, -1) = 32 THEN TXT = RTRIM$(TXT)       'trim off trailing spaces

  IF INSTR(TXT, ":") THEN                       'colon inside paranthesis must be converted
     inPar = 0
     FOR Letter2 = STRPTR(TXT) TO STRPTR(TXT) + LEN(TXT)
        SELECT CASE @Letter2
           CASE 40 : INCR inPar                 'left paranthesis (
           CASE 41 : DECR inPar                 'right paranthesis )
           CASE 58 : IF inPar > 0 THEN @Letter2 = 59 'if within paranthesis, convert colon to semicolon (whatever)
        END SELECT
     NEXT
  END IF


  RetVal=ChkCondCompile(TXT, CondCompile2(), EquateConst2())  'Returns 0 if we are not taking the code


  SELECT CASE RetVal
      CASE 0 : RETURN
      CASE ELSE 'flow thru
  END SELECT


  '------- start looking for triggers in source code
   SELECT CASE %TRUE
          CASE INSTR(1,TXT,"#IF %DEF(")    >0
             CALL CheckEquateIfDef(   TXT, CondCompile2(), EquateConst2())
             RETURN
          CASE INSTR(1,TXT,"#IF NOT %DEF(")>0
             CALL CheckEquateIfNotDef(TXT, CondCompile2(), EquateConst2())
             RETURN
          CASE INSTR(1,TXT,"#IF NOT %")    >0
             CALL CheckEquateNotIF(   TXT, CondCompile2(), EquateConst2())
             RETURN
          CASE INSTR(1,TXT,"#IF %")        >0
             CALL CheckEquateIF(      TXT, CondCompile2(), EquateConst2())
             RETURN
          'CASE INSTR(1,Txt,"%")            >0
          '   IF INSTR(1,Txt,"FDST(")=0 THEN  'Kludge
          '      CALL GetEquate(Txt,EQuateConst2())
          '
          '      RETURN
          '   END IF
   END SELECT

   J=UBOUND(CondCompile2)
   '
   SELECT CASE %TRUE
     CASE J<1  :                                    'No Nests Then Go Get It
     CASE J>0 AND CondCompile2(J).IncludeIt=%TRUE :  'Nested and OK
     CASE J>0 AND CondCompile2(J).IncludeIt=%FALSE   'Nested and Not OK
         RETURN
   END SELECT

   IF LEN(TXT) > 2 THEN                          'now, if line is enough long

     IF WhatRun = 0 THEN                        'and first run
        GOSUB ExtractSub                        'send it to sub/function check
        GOSUB ExtractGlobal                     'send it to global variable check
     ELSE
        IF LTRIM$(LEFT$(TXT, 8)) = "DECLARE " OR dUscored THEN
           dUscored = (ASC(TRIM$(TXT), -1) = 95)
           RETURN
        END IF
        GOSUB ChkVariables                      'second run, calculate globals
     END IF
  END IF

RETURN

'---------------------------------------------------------
' Get subs and functions, plus get/check local variables (DIM, LOCAL, STATIC)
'---------------------------------------------------------
ExtractSub:


  IF sFlag = 0 THEN
     Buf = UCASER(TXT)

     IF LEFT$(Buf, 8) = "DECLARE " THEN       'Declaration
        IF INSTR(Buf, " LIB ") THEN RETURN                'external routine - DLL, etc.
        TXT = LTRIM$(MID$(TXT, 9))
        Buf = TXT : dFlag = 1
        IF LEN(RTRIM$(TXT)) = 1 AND ASC(TXT) = 95 THEN RETURN
     END IF

     SELECT CASE %TRUE
        CASE LEFT$(Buf, 9) = "FUNCTION "                    'Function start
           sFlag = 2 : fsName = LTRIM$(MID$(TXT, 10)) : K = I
        CASE LEFT$(Buf, 4) = "SUB "                     'Sub start
           sFlag = 1 : fsName = LTRIM$(MID$(TXT, 5))  : K = I
        CASE LEFT$(Buf, 18) = "CALLBACK FUNCTION "      'Callback Function start
        sFlag = 3 : fsName = LTRIM$(MID$(TXT, 19)) : K = I
     END SELECT

     IF sFlag THEN
        IF INSTR(fsName, " EXPORT") THEN exported = 1
        Ac = INSTR(fsName, ANY " ('")
        IF Ac THEN fsName = TRIM$(LEFT$(fsName, Ac - 1), ANY " &%@!#$?")
     END IF
     IF LEN(fsName) = 1 AND ASC(fsName) = 95 THEN fUscored = 1

     IF dFlag AND fUscored = 0 THEN
        GOSUB AddDeclare : RETURN
     END IF

  ELSE
     IF fUscored THEN
        IF dFlag AND INSTR(Buf, " LIB ") THEN RETURN             'external routine, DLL
        IF fUscored = 1 THEN 'look for name
           ac = INSTR(LTRIM$(TXT), ANY " (")
           IF Ac THEN
              fsName = TRIM$(LEFT$(TXT, Ac - 1), ANY " &%@!#$?")
           ELSE
              fsName = TRIM$(TXT, ANY " &%@!#$?")
           END IF
        ELSE
           IF INSTR(TXT, "EXPORT") THEN exported = 1
        END IF
        IF ASC(TRIM$(TXT), -1) = 95 THEN
           fUscored = 2
        ELSE
           fUscored = 0
        END IF
     END IF

     IF dFlag AND fUscored = 0 THEN 'declaration
        GOSUB AddDeclare : RETURN
     END IF

     SELECT CASE sFlag
        CASE 1
           IF LEFT$(TXT, 7) = "END SUB" THEN
              endRout = sFlag
           ELSE
              GOSUB ExtractLocals
              GOSUB ChkVariables
              RETURN
           END IF
        CASE 2, 3
           IF LEFT$(TXT, 12) = "END FUNCTION" THEN
              endRout = sFlag
           ELSE
              GOSUB ExtractLocals
              GOSUB ChkVariables
              RETURN
           END IF
     END SELECT

     IF endRout THEN
        IF iFuncts MOD 40 = 0 THEN REDIM PRESERVE Functs(iFuncts + 40)
        fsName = RTRIM$(fsName)
        Functs(iFuncts).zName    = fsName
        fsName                   = UCASE$(fsName)
        Functs(iFuncts).uName    = fsName & CHR$(0)
        Functs(iFuncts).iType    = endRout
        Functs(iFuncts).LineNum  = II 'was K
        Functs(iFuncts).SubEnd   = I
        Functs(iFuncts).FileNum  = fNum
        Functs(iFuncts).Exported = exported
        INCR iFuncts
        sFlag = 0 : endRout = 0 : exported = 0

        IF iVars THEN
           REDIM PRESERVE lVars(ilVars + iVars)
           FOR iv = 0 TO iVars - 1
              lVars(ilVars).zName   = Vars(iv).zName
              lVars(ilVars).uName   = Vars(iv).uName
              lVars(ilVars).InFunct = Vars(iv).InFunct
              lVars(ilVars).iType   = Vars(iv).iType
              lVars(ilVars).LineNum = Vars(iv).LineNum
              lVars(ilVars).FileNum = Vars(iv).FileNum
              lVars(ilVars).IsUsed  = Vars(iv).IsUsed
              INCR ilVars
           NEXT
           iVars = 0 : REDIM Vars(0)
        END IF
     END IF
  END IF

RETURN

AddDeclare:
  IF DeclCount MOD 40 = 0 THEN REDIM PRESERVE gDecl(DeclCount + 40)
  fsName = RTRIM$(fsName)
  gDecl(DeclCount).zName    = fsName
  fsName=UCASE$(fsName)
  gDecl(DeclCount).uName    = fsName & CHR$(0)
  gDecl(DeclCount).iType    = sFlag
  gDecl(DeclCount).LineNum  = II 'was K
  gDecl(DeclCount).SubEnd   = I
  gDecl(DeclCount).FileNum  = fNum
  gDecl(DeclCount).Exported = exported
  INCR DeclCount
  sFlag = 0 : endRout = 0 : exported = 0 : dFlag = 0
RETURN

'---------------------------------------------------------
' Get Locals
'---------------------------------------------------------
ExtractLocals:
  IF INSTR(TXT, "LOCAL ") OR INSTR(TXT, "DIM ") OR _
     INSTR(TXT, "STATIC ") OR uscoredLocal THEN
     FOR locX = 1 TO PARSECOUNT(TXT, ":")
        sWork = TRIM$(PARSE$(TXT, ":", locX))
        IF LEFT$(sWork, 6) = "LOCAL " OR _
           LEFT$(sWork, 4) = "DIM " OR _
           LEFT$(sWork, 7) = "STATIC " OR _
           uscoredLocal THEN

            IF uscoredLocal = 0 THEN
               IF LEFT$(sWork, 6) = "LOCAL " THEN
                  isGLOBAL = 0 : sWork = MID$(sWork, 7)
               ELSEIF LEFT$(sWork, 4) = "DIM " THEN
                  isGLOBAL = 1 : sWork = MID$(sWork, 5)    'start out by assuming global status
               ELSEIF LEFT$(sWork, 7) = "STATIC " THEN
                  isGLOBAL = 0 : sWork = MID$(sWork, 8)
               END IF
            END IF
            FOR locY = 1 TO PARSECOUNT(sWork, ",")
                sBuf = TRIM$(PARSE$(sWork, ",", locY))

                IF isGLOBAL = 1 THEN 'check if DIM statement really was global
                   IF INSTR(sBuf, " GLOBAL") THEN    'this can only happen
                      isGLOBAL = 2                           'with "DIM xx AS GLOBAL.."
                   ELSEIF INSTR(sBuf, " LOCAL") OR _ 'local DIM..
                         INSTR(sBuf, " STATIC") THEN
                      isGLOBAL = 0
                   END IF
                END IF

                sBuf = EXTRACT$(sBuf, ANY " ()")  'Chop off AS LONG, etc, or if array - (
                sBuf = RTRIM$(sBuf, ANY " &%@!#$?")
                IF LEN(sBuf) = 1 AND ASC(sBuf) = 95 THEN ITERATE
                sBuf = sBuf + CHR$(0)

                IF isGLOBAL < 2 THEN
                   ARRAY SCAN Vars(), FROM 1 TO LEN(sBuf), COLLATE UCASE, = sBuf, TO locPos
                   IF locPos = 0 THEN
                      IF iVars MOD 40 = 0 THEN REDIM PRESERVE Vars(iVars + 40)
                      Vars(iVars).zName   = sBuf
                      Vars(iVars).uName   = sBuf
                      Vars(iVars).InFunct = fsName
                      Vars(iVars).FileNum = fNum
                      Vars(iVars).iType   = isGlobal
                      Vars(iVars).LineNum = II 'was I
                      INCR iVars
                   END IF

                ELSE
                   ARRAY SCAN gVars(), FROM 1 TO LEN(sBuf), COLLATE UCASE, = sBuf, TO lngPos
                   IF lngPos = 0 THEN 'if not already there, add it (GLOBAL+DIM/REDIM, DIM AS GLOBAL, etc.)
                      IF igVars MOD 40 = 0 THEN REDIM PRESERVE gVars(igVars + 40)
                      gVars(igVars).zName = sBuf
                      gVars(igVars).uName = sBuf
                      gVars(igVars).FileNum = fNum
                      gVars(igVars).LineNum = II 'was I
                      INCR igVars
                   END IF

                END IF
            NEXT

        END IF
     NEXT
     uscoredLocal = (RIGHT$(RTRIM$(TXT), 2)  = " _")
  END IF

RETURN

'---------------------------------------------------------
' Get Globals
'---------------------------------------------------------
ExtractGlobal:
  IF INSTR(TXT, "GLOBAL ") OR uscoredGlobal THEN
     FOR x = 1 TO PARSECOUNT(TXT, ":")
        sWork = TRIM$(PARSE$(TXT, ":", x))
        isGLOBAL = (LEFT$(sWork, 7) = "GLOBAL ")
        IF isGLOBAL = 0 THEN isGLOBAL = uscoredGlobal
        IF LEFT$(sWork, 7) = "GLOBAL " OR uscoredGlobal THEN
            IF uscoredGlobal = 0 THEN sWork = MID$(sWork, 8)
            FOR y = 1 TO PARSECOUNT(sWork, ",")
                sBuf = TRIM$(PARSE$(sWork, ",", y))
                sBuf = EXTRACT$(sBuf, ANY " ()")  'Chop off AS LONG etc.
                sBuf = RTRIM$(sBuf, ANY " &%@!#$?")
                IF LEN(sBuf) = 1 AND ASC(sBuf) = 95 THEN ITERATE
                sBuf = sBuf + CHR$(0)

                IF igVars THEN 'must check for ev. duplicate declarations
                   ARRAY SCAN gVars(), FROM 1 TO LEN(sBuf), COLLATE UCASE, = sBuf, TO dbl
                   IF dbl THEN
                      IF igDbl THEN
                         ARRAY SCAN gDbl(), FROM 1 TO LEN(sBuf), COLLATE UCASE, = sBuf, TO dbl
                         IF dbl THEN
                            INCR gDbl(dbl - 1).IsUsed
                            ITERATE FOR
                         END IF
                      END IF
                      REDIM PRESERVE gDbl(igDbl)
                      gDbl(igDbl).zName   = sBuf
                      gDbl(igDbl).uName   = sBuf
                      gDbl(igDbl).FileNum = fNum
                      gDbl(igDbl).LineNum = II 'was I
                      INCR igDbl
                      ITERATE FOR
                   END IF
                END IF

                IF igVars MOD 40 = 0 THEN REDIM PRESERVE gVars(igVars + 40)
                gVars(igVars).zName = sBuf
                gVars(igVars).uName = sBuf
                gVars(igVars).FileNum = fNum
                gVars(igVars).LineNum = II 'was I
                INCR igVars
            NEXT

        END IF
     NEXT
     IF isGlobal THEN uscoredGlobal = ( RIGHT$(RTRIM$(TXT), 2)  = " _" )
  END IF

RETURN

'---------------------------------------------------------
' Check variables
'---------------------------------------------------------
ChkVariables:
  wordFlag = 0 : StrFlag = 0
  Letter2 = STRPTR(TXT)
  FOR di = 1 TO LEN(TXT)
     SELECT CASE @Letter2
        'a-z, A-Z, 0-9, _, (Single Line Characters?), (Double line characters?)
        CASE 97 TO 122, 65 TO 90, 48 TO 57, 95, 192 TO 214, 216 TO 246, 248 TO 255
           IF wordFlag = 0 AND @Letter2 <> 95 THEN 'if valid char and no flag, word starts here (not with underscore)
              wordFlag = 1 : lngPos = di              'set wordflag and store position
           END IF

        CASE ELSE                       'we hit something else, like space, dot, etc..
           IF wordFlag = 1 THEN         'if flag, then a word is ready
              GOSUB ChkWord             'check what we got
              wordFlag = 0              'and reset wordflag
           END IF
     END SELECT
     INCR Letter2                       'next char
  NEXT

  IF wordFlag  = 1 THEN GOSUB ChkWord 'in case there were letters all the way to the end..
RETURN

ChkWord:
   lngPos = di - lngPos                             'calculate length
   sBuf = PEEK$(Letter2 - lngPos, lngPos) + CHR$(0) 'grab word


   'IF InStr(Txt,"TODAYLISTVIEW") >0 THEN
   '    ?  "WhatRun="+Str$(WhatRun)+$CRLF+_
   '       "Txt="+Txt+$CRLF+_
   '       "sBuf="+sBuf
   'End IF


   IF WhatRun = 0 THEN                         'check local variables
     ARRAY SCAN Vars(), FROM 1 TO LEN(sBuf), = sBuf, TO lngPos
     IF lngPos THEN INCR Vars(lngPos - 1).IsUsed

   ELSE                                        'check Subs(Functions and Global vars
     ARRAY SCAN Functs(), FROM 1 TO LEN(sBuf), = sBuf, TO lngPos
     IF lngPos THEN INCR Functs(lngPos - 1).IsUsed

     ARRAY SCAN gVars(), FROM 1 TO LEN(sBuf), = sBuf, TO lngPos
     IF lngPos THEN INCR gVars(lngPos - 1).IsUsed
  END IF

   'IF InStr(Txt,"TODAYLISTVIEW") >0 THEN
   '    ?  "WhatRun="+Str$(WhatRun)+$CRLF+_
   '       "Txt    ="+Txt+$CRLF+_
   '       "sBuf   ="+sBuf+$CRLF+_
   '       "Pos    ="+Str$(Pos)
   'End IF

RETURN

END FUNCTION

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Prepare and save a report of what we've found out!
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
SUB DoSaveResults
  LOCAL hFile AS LONG, lRes AS LONG, fDbl AS LONG, cTmp AS LONG, I AS LONG, _
        uline AS STRING, fName AS STRING, aStr AS STRING, aStr2 AS STRING

'------------------------------------------------------------------------------
' first look through locals array. if iType = 1, it may be a GLOBAL DIM
'------------------------------------------------------------------------------
  IF igVars AND ilVars THEN
     FOR I = ilVars - 1 TO 0 STEP -1 '<- must run this backwards through array!
        IF lVars(I).iType = 1 THEN
           aStr = lVars(I).uName + CHR$(0)
           ARRAY SCAN gVars(), FROM 1 TO LEN(aStr), = aStr, TO cTmp
           IF cTmp THEN               'if also GLOBAL, remove from local arrays
              ARRAY DELETE lVars(I)
              DECR ilVars
           END IF
        END IF
     NEXT
  END IF

  astr="" 'NNM 4/30/2010

  REDIM PRESERVE lVars(ilVars)

'------------------------------------------------------------------------------
' now prepare report..
'------------------------------------------------------------------------------
  DestFile = PARSE$(FileNameStr, ANY ".", 1)+"LOG.txt"
  OPEN FilePathStr + DestFile FOR OUTPUT AS hFile
  sWork = STRING$(80,"¤")
  uline = STRING$(80,"-")

  GOSUB ReportHeader
  IF Do_Includes_Rpt               THEN GOSUB ReportFiles       'List of Includes processed
  IF Do_UnusedFxs_Rpt              THEN GOSUB UnusedFunctions   'List of unused Functions
  IF Do_UnusedSubs_Rpt             THEN GOSUB UnusedSubs        'List of unused Subs
  IF Do_DeclaredButNonExistant_Rpt THEN GOSUB DecButNonExistant 'Declared but non Existant
 'IF NotDecl THEN
 '   GOSUB ExistingButNotDecl  'PB 9.00 allows functions without declaring Nathan Maddox
 'END IF
  IF Do_UnusedGlobals_Rpt          THEN GOSUB UnusedGlobals
  IF Do_UnusedLocals_Rpt           THEN GOSUB UnusedLocals
  IF Do_GlobalLocalMix_Rpt         THEN GOSUB GlobalLocalMix
  IF Do_DupeGlobal_Rpt             THEN GOSUB DupeGlobalNames
  IF Do_TotRefCount_Rpt            THEN GOSUB TotRefCount
  IF Do_SubRefCount_Rpt            THEN GOSUB SubRefCount
  IF Do_GlobalVariableRpt_Rpt      THEN GOSUB GlobalVariableRpt
  IF Do_StringLiterals_Rpt         THEN GOSUB StringLiterals
  IF Do_Constants_Rpt              THEN GOSUB ConstantsReport '--- for debugging purposes Nathan Maddox 9/29/09

  CLOSE hFile
  SLEEP 20
  'Launch Log file in default Viewer.
  ShellExecute 0, "open", FilePathStr + DestFile, BYVAL 0, BYVAL 0, %SW_SHOWNORMAL

  EXIT SUB

ConstantsReport:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  PRINT# hFile, sWork
  PRINT# hFile, " CONSTANTS NAME                               CONSTANT VALUE "
  PRINT# hFile, uline

  FOR I = 1 TO UBOUND(EquateConst2)
      A$=EquateConst2(I).EquateName + " "+FORMAT$(EquateConst2(i).EquateVal)
      PRINT# hFile, A$
  NEXT I

RETURN


ReportHeader:
'------------------------------------------------------------------------------
  PRINT# hFile, sWork
  PRINT# hFile, " PBcodec report: "  UCASER(FileNameStr) + " + include files. " & _
                "Generated " & DATE$ & ", " & TIME$
  PRINT# hFile, STR$(gTotLines) + " lines scanned in " + FORMAT$(t, "0.000") + _
                " seconds (" + FORMAT$(gTotLines / t * 60, "0") + " lines/minute)"
  PRINT# hFile, sWork
RETURN

ReportFiles:
'------------------------------------------------------------------------------
  IF UBOUND(Files) > -1 THEN
     PRINT# hFile, " MAIN + INCLUDE FILES"
     PRINT# hFile, uline
     inFile(0) = "Main source file"
     FOR I = 0 TO UBOUND(Files)
        PRINT# hFile, " " & LEFT$(Files(I) & aStr & SPACE$(58), 58) & "[" +inFile(I) + "]"
     NEXT I
  END IF
RETURN

UnUsedFunctions:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  PRINT# hFile, sWork
  PRINT# hFile, " UN-USED FUNCTIONS  (exported, or in incl. files, may be used by other programs)"
  PRINT# hFile, uline
  IF iFuncts THEN
     FOR I = 0 TO iFuncts - 1
         IF Functs(I).IsUsed = 1 AND Functs(I).iType > 1 THEN
            SELECT CASE Functs(I).zName
               CASE "PBMAIN", "WINMAIN", "LIBMAIN", "PBLIBMAIN", "DLLMAIN" 'ignore these
               CASE ELSE
                  fName = Files(Functs(I).FileNum)
                  aStr = " FUNCTION " : aStr2 = ""
                  IF Functs(I).iType = 3 THEN aStr = " CALLBACK "
                  IF Functs(I).Exported THEN aStr2 = " <EXPORT>"
                  PRINT# hFile, LEFT$(aStr & Functs(i).zName & aStr2 & SPACE$(52), 52) & "  [" & _
                         MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" STR$(Functs(I).LineNum)
            END SELECT
        END IF
     NEXT I
  END IF
RETURN

UnUsedSubs:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  PRINT# hFile, sWork
  PRINT# hFile, " UN-USED SUBS  (exported, or in incl. files, may be used by other programs)"
  PRINT# hFile, uline
  IF iFuncts THEN
     FOR I = 0 TO iFuncts - 1
        IF Functs(I).IsUsed = 1 AND Functs(I).iType = 1 THEN
            fName = Files(Functs(I).FileNum)
            aStr2 = ""
            IF Functs(I).Exported THEN aStr2 = " <EXPORT>"
            PRINT# hFile, LEFT$(" SUB " & Functs(i).zName & aStr2 & SPACE$(50), 50) & "    [" & _
                   MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" STR$(Functs(I).LineNum)
        END IF
     NEXT I
  END IF
RETURN

DecButNonExistant:
'------------------------------------------------------------------------------
  IF DeclCount THEN
     PRINT# hFile, ""
     PRINT# hFile, sWork
     PRINT# hFile, " DECLARED, BUT NON-EXISTING SUB/FUNCTION(S)"
     PRINT# hFile, uline

     FOR I = 0 TO DeclCount - 1
        IF iFuncts > 0 THEN
           aStr = gDecl(I).uName + CHR$(0)
           ARRAY SCAN Functs(), FROM 1 TO LEN(aStr), = aStr, TO fDbl
        END IF
        IF fDbl = 0 THEN
           fName = Files(gDecl(I).FileNum)
           aStr2 = ""
           IF gDecl(I).iType = 1 THEN
              aStr = " SUB "
           ELSEIF gDecl(I).iType = 2 THEN
              aStr = " FUNCTION "
           ELSEIF gDecl(I).iType = 3 THEN
              aStr = " CALLBACK "
           END IF
           IF gDecl(I).Exported  THEN aStr2 = " <EXPORT>"
           PRINT# hFile, LEFT$(aStr & gDecl(I).zName & aStr2 & SPACE$(50), 50) & "    [" & _
                  MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" STR$(gDecl(I).LineNum)
        END IF
     NEXT I
  END IF
RETURN

ExistingButNotDecl:
'------------------------------------------------------------------------------
  IF iFuncts THEN
     PRINT# hFile, ""
     PRINT# hFile, sWork
     PRINT# hFile, " EXISTING, BUT NON-DECLARED SUB/FUNCTION(S)"
     PRINT# hFile, uline

     FOR I = 0 TO iFuncts - 1
        IF DeclCount THEN
           aStr = Functs(I).uName + CHR$(0)
           ARRAY SCAN gDecl(), FROM 1 TO LEN(aStr), = aStr, TO fDbl
        END IF
        IF fDbl = 0 THEN
           SELECT CASE Functs(I).zName
              CASE "PBMAIN", "WINMAIN", "LIBMAIN", "PBLIBMAIN", "DLLMAIN" 'ignore these
              CASE ELSE
                 fName = Files(Functs(I).FileNum)
                 aStr2 = ""
                 IF Functs(I).iType = 1 THEN
                    aStr = " SUB "
                 ELSEIF Functs(I).iType = 2 THEN
                    aStr = " FUNCTION "
                 ELSEIF Functs(I).iType = 3 THEN
                    aStr = " CALLBACK "
                 END IF
                 IF Functs(I).Exported  THEN aStr2 = " <EXPORT>"
                 PRINT# hFile, USING$("####", Functs(I).IsUsed - 1) & _
                        LEFT$(aStr & Functs(I).zName & aStr2 & SPACE$(45), 45) & "    [" & _
                        MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" STR$(Functs(I).LineNum)
              END SELECT
           END IF
        NEXT
  END IF
RETURN

UnusedGlobals:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  PRINT# hFile, sWork
  PRINT# hFile, " UN-USED GLOBAL VARIABLES"
  PRINT# hFile, uline
  IF igVars THEN
     FOR I = 0 TO igVars - 1
        IF gVars(I).IsUsed = 1 THEN
           fName = Files(gVars(I).FileNum)
           PRINT# hFile, " " & LEFT$(gVars(i).zName & SPACE$(47), 47) & "    [" &  _
                  MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(gVars(I).LineNum)
        END IF
     NEXT I
  END IF
RETURN

UnusedLocals:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  PRINT# hFile, sWork
  PRINT# hFile, " UN-USED LOCAL VARIABLES"
  PRINT# hFile, uline
  IF ilVars THEN
     FOR I = 0 TO ilVars - 1
        IF lVars(I).IsUsed = 1 THEN
           fName = Files(lVars(I).FileNum)
           PRINT# hFile, " " & LEFT$(lVars(i).zName & SPACE$(47), 47) & "    [" &  _
                  MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(lVars(I).LineNum)
        END IF
     NEXT I
  END IF
RETURN

GlobalLocalMix:
'------------------------------------------------------------------------------
  IF igVars AND ilVars THEN
     FOR I = 0 TO igVars - 1
        aStr = gVars(I).uName & CHR$(0)
        ARRAY SCAN lVars(), FROM 1 TO LEN(aStr), = aStr, TO cTmp
        IF cTmp THEN EXIT FOR
     NEXT
     IF cTmp THEN
        PRINT# hFile, ""
        PRINT# hFile, sWork
        PRINT# hFile, " GLOBAL/LOCAL MIX - WARNING!"
        PRINT# hFile, " Following global variable name(s) exist in both global and local"
        PRINT# hFile, " form. While the compiler allows this, special care must be taken"
        PRINT# hFile, " to avoid hard-to-find errors. Please check them out carefully."
        PRINT# hFile, uline

        FOR I = 0 TO igVars - 1
           aStr = gVars(I).uName & CHR$(0)
           ARRAY SCAN lVars(), FROM 1 TO LEN(aStr), = aStr, TO lRes
           IF lRes THEN
              cTmp = 0 : fDbl = 0
              fName = Files(gVars(I).FileNum)
              PRINT# hFile, " " & LEFT$(gVars(I).zName & SPACE$(47), 47) & "    [" &  _
                            MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(gVars(I).LineNum)
              DO
                 cTmp = cTmp + lRes
                 fName = Files(lVars(cTmp - 1).FileNum)
                 PRINT# hFile, "   local in " &  _
                            MID$(fName, INSTR(-1, fName, "\") + 1) & " :" & STR$(lVars(cTmp - 1).LineNum)
                 ARRAY SCAN lVars(cTmp), FROM 1 TO LEN(aStr), = aStr, TO lRes
              LOOP WHILE lRes
           END IF
        NEXT
     END IF
  END IF
RETURN

DupeGlobalNames:
'------------------------------------------------------------------------------
  IF igDbl THEN
     PRINT# hFile, ""
     PRINT# hFile, sWork
     PRINT# hFile, " DUPLICATE GLOBAL NAMES - WARNING!"
     PRINT# hFile, " Following global name(s) exist as both array and varíable."
     PRINT# hFile, " While the compiler allows this, special care must be taken"
     PRINT# hFile, " avoid hard-to-find errors. Please check them out carefully."
     PRINT# hFile, uline
     FOR I = 0 TO igDbl - 1
        fName = Files(gDbl(I).FileNum)
        PRINT# hFile, " " & LEFT$(gDbl(I).zName & SPACE$(47), 47) & "    [" &  _
                      MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(gDbl(I).LineNum)
     NEXT
  END IF
RETURN

TotRefCount:
'------------------------------------------------------------------------------
  'code added by Wayne Diamond, slightly altered by Borje Hagsten
  PRINT# hFile, ""
  PRINT# hFile, sWork
  PRINT# hFile, " TOTAL REFERENCE COUNT - (Count, Name, [declared in File] : at Line number)"
  PRINT# hFile, " Lists how many times the following has been called/used (zero = un-used)"
  PRINT# hFile, uline
'------------------------------------------------------------------------------
  IF iFuncts > 0 THEN
     PRINT# hFile, " FUNCTIONS:"
     FOR I = 0 TO iFuncts - 1
        IF Functs(I).iType > 1 THEN
           SELECT CASE Functs(I).zName
              CASE "PBMAIN", "WINMAIN", "LIBMAIN", "PBLIBMAIN", "DLLMAIN" 'ignore these
              CASE ELSE
                 fName = Files(Functs(I).FileNum)
                 aStr = ""
                 IF Functs(I).Exported THEN aStr = " <EXPORT>"
                 PRINT# hFile, USING$("####", Functs(I).IsUsed - 1) & "  " & _
                        LEFT$(Functs(I).zName & aStr & SPACE$(43), 43) & "    [" & _
                        MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(Functs(I).LineNum)
           END SELECT
        END IF
     NEXT I
  END IF
RETURN

SubRefCount:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  IF iFuncts > 0 THEN
     PRINT# hFile, " SUBS:"
     FOR I = 0 TO iFuncts - 1
        IF Functs(I).iType = 1 THEN
           fName = Files(Functs(I).FileNum)
           aStr = ""
           IF Functs(I).Exported THEN aStr = " <EXPORT>"
           PRINT# hFile, USING$("####", Functs(I).IsUsed - 1) & "  " & _
                  LEFT$(Functs(I).zName & aStr & SPACE$(43), 43) & "    [" & _
                  MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(Functs(I).LineNum)
        END IF
      NEXT I
  END IF
RETURN

GlobalVariableRpt:
'------------------------------------------------------------------------------
  PRINT# hFile, ""
  IF igVars > 0 THEN
     PRINT# hFile, " GLOBAL VARIABLES:"
     FOR I = 0 TO igVars - 1
        fName = Files(gVars(I).FileNum)
        PRINT# hFile, USING$("####", gVars(I).IsUsed - 1) & "  " & _
                      LEFT$(gVars(I).zName & SPACE$(43), 43) & "    [" & _
                      MID$(fName, INSTR(-1, fName, "\") + 1) & "] :" & STR$(gVars(I).LineNum)
     NEXT I
  END IF
  'end of Wayne Diamond code
RETURN

StringLiterals:
  IF sStrCount THEN
     PRINT# hFile, ""
     PRINT# hFile, sWork
     PRINT# hFile, " STRING LITERALS"
     fName = ""

     FOR I = 0 TO sStrCount - 1
        aStr = Files(VAL(PARSE$(sString(I), $TAB, 1)))
        aStr = MID$(aStr, INSTR(-1, aStr, "\") + 1)
        IF aStr <> fName THEN
           fName = aStr
           PRINT# hFile, ""
           IF I THEN PRINT# hFile, uline
           PRINT# hFile, " Line  Text     [" + fName + "]"
           PRINT# hFile, uline
        END IF
        PRINT# hFile,  PARSE$(sString(I), $TAB, 2) + "  " + _
                       PARSE$(sString(I), $TAB, 3)
     NEXT
  END IF
'------------------------------------------------------------------------------
RETURN


END SUB

'************************************************************************
' GetCommandFile - loads a received Path&File name into global array
'************************************************************************
FUNCTION GetCommandFile(BYVAL CmdStr AS STRING, Fi() AS STRING) AS LONG
    LOCAL tmpName AS STRING, pStr AS STRING

     CmdStr = TRIM$(CmdStr)                   'trim away ev. leading/ending spaces
     IF LEFT$(CmdStr, 1) = CHR$(34) THEN      'if in double-quotes
       CmdStr = MID$(CmdStr, 2)               'remove first quote
       pStr = CHR$(34)                        'and use DQ as delimiter for PARSE$
    ELSE
       pStr = " "                             'else use space as delimiter
    END IF

    tmpName = TRIM$(PARSE$(CmdStr, pStr, 1))
    IF LEN(tmpName) = 0 THEN EXIT FUNCTION

    IF (GETATTR(tmpName) AND 16) = 0 THEN     'make sure it isn't a folder
       Fi(0) = tmpName
    ELSE
       EXIT FUNCTION
    END IF

    FUNCTION = 1                             'return number of collected files
END FUNCTION

'************************************************************************
' GetDroppedFile - Function Loads File/Folder names into the global arrays
'************************************************************************
FUNCTION GetDroppedFile( BYVAL hfInfo AS LONG, Fi() AS STRING) AS LONG
  LOCAL COUNT AS LONG, ln AS LONG, tmp AS STRING, fName AS ASCIIZ * %MAX_PATH

  COUNT = DragQueryFile(hfInfo, &HFFFFFFFF&, BYVAL %NULL, 0) 'get number of dropped files

  IF COUNT THEN                                          'If we got something
     ln = DragQueryFile(hfInfo, 0, fName, %MAX_PATH)     'put FileName into fString And get len
     IF ln THEN
        tmp = TRIM$(LEFT$(fName, ln))
        IF LEN(tmp) AND (GETATTR(tmp) AND 16) = 0 THEN   'make sure it's a file, not a folder
           Fi(0) = tmp
           FUNCTION = 1
        END IF
     END IF
  END IF

  CALL DragFinish(hfInfo)
END FUNCTION

'************************************************************************
' Get PB/DLL 6 compiler's include dir (winapi folder)
'************************************************************************
FUNCTION GetIncludeDir AS STRING
  LOCAL lRet   AS LONG, hKey AS LONG
  LOCAL Buffer AS ASCIIZ * %MAX_PATH, SubKey AS STRING

  Buffer = "Software\PowerBASIC\PB/Win\7.00"
  SubKey = "Filename"
  IF RegOpenKeyEx(%HKEY_LOCAL_MACHINE, Buffer, 0, _
                  %KEY_QUERY_VALUE, hKey) = %ERROR_SUCCESS THEN

     lRet = RegQueryValueEx(hKey, BYVAL STRPTR(SubKey), _
            BYVAL 0&, BYVAL 0&, Buffer, SIZEOF(Buffer))

     IF LEN(Buffer) THEN FUNCTION = TRIM$(Buffer)
     IF hKey THEN RegCloseKey hKey

     IF LEN(TRIM$(Buffer)) THEN
        Buffer = TRIM$(Buffer)
        Buffer = LEFT$(Buffer, INSTR(-1, Buffer, ANY "\/"))           ' Compiler path
        SubKey = LEFT$(Buffer, INSTR(-1, Buffer, "\Bin\")) + "WinAPI" ' WinAPI path
        Buffer = IniGetString("Compiler", "Include0", SubKey, Buffer + "PBWin.ini")
        IF LEN(TRIM$(Buffer)) THEN
           Buffer = TRIM$(Buffer)
           IF RIGHT$(Buffer, 1) <> "\" THEN
              IF RIGHT$(Buffer, 1) <> "/" THEN Buffer = Buffer + "\"
           END IF
           FUNCTION = TRIM$(Buffer)
           EXIT FUNCTION
        END IF
     END IF
  END IF

  Buffer = "Software\PowerBasic\PB/WIN\9.00\Compiler"
  SubKey = "Include"
  IF RegOpenKeyEx(%HKEY_CURRENT_USER, Buffer, 0, _
                  %KEY_QUERY_VALUE, hKey) = %ERROR_SUCCESS THEN

     lRet = RegQueryValueEx(hKey, BYVAL STRPTR(SubKey), _
            BYVAL 0&, BYVAL 0&, Buffer, SIZEOF(Buffer))

     IF LEN(Buffer) THEN FUNCTION = TRIM$(Buffer)
'     MSGBOX Buffer
     FUNCTION = Buffer
     IF hKey THEN RegCloseKey hKey

  ELSE
     Buffer = "Software\PowerBasic\PB/WIN\9.00\Compiler"
     IF RegOpenKeyEx(%HKEY_CURRENT_USER, Buffer, 0, _
                     %KEY_QUERY_VALUE, hKey) = %ERROR_SUCCESS THEN

        lRet = RegQueryValueEx(hKey, BYVAL STRPTR(SubKey), _
               BYVAL 0&, BYVAL 0&, Buffer, SIZEOF(Buffer))

        IF LEN(Buffer) THEN FUNCTION = TRIM$(Buffer)
        IF hKey THEN RegCloseKey hKey
     END IF
  END IF
END FUNCTION

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Get string from ini file
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
FUNCTION IniGetString(BYVAL sSection AS STRING, BYVAL sKey AS STRING, _
                      BYVAL sDefault AS STRING, BYVAL sFile AS STRING) AS STRING
  LOCAL RetVal AS LONG, zResult AS ASCIIZ * %MAX_PATH

  RetVal = GetPrivateProfileString(BYVAL STRPTR(sSection), _
                                   BYVAL STRPTR(sKey), _
                                   BYVAL STRPTR(sDefault), _
                                   zResult, SIZEOF(zResult), BYVAL STRPTR(sFile))
  IF RetVal THEN FUNCTION = TRIM$(LEFT$(zResult, RetVal))
END FUNCTION

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' Check to see if the file has a #COMPILE metastatement
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
FUNCTION IsFileMain(BYVAL fName AS STRING) AS LONG
  LOCAL hFile AS LONG, TXT AS STRING

  hFile = FREEFILE                           'get a free file handle
  OPEN fName FOR INPUT AS hFile LEN = 16383  'open file

  IF ERR THEN                                'if it failed
     RESET : ERRCLEAR                        'reset, clear error
     FUNCTION = -2 : EXIT FUNCTION           'return -2 to indicate failure and exit
  END IF

  IF LOF(hFile) = 0 THEN                     'if zero length file
     CLOSE hFile                             'close it
     FUNCTION = -3 : EXIT FUNCTION           'return -3 to indicate empty file and exit
  END IF

  DO WHILE EOF(hFile) = 0                    'loop through file
     LINE INPUT# hFile, TXT                  'line by line
     TXT=TRIM$(TXT)                          'NNM 9/22/09
     TXT=REMOVE$(TXT, ANY $TAB)              'NNM 9/22/09
     TXT=UCASE$(TXT)
     IF LEN(TXT) > 8 THEN                    'if enough long
        IF (ASC(TXT) = 35 OR ASC(TXT) = 36) AND MID$(TXT, 2, 8) = "COMPILE " THEN
           FUNCTION=1
           EXIT DO
        END IF

        IF LEFT$(TXT, 9) = "FUNCTION " OR _  'jump out once we hit a Sub or Function
                LEFT$(TXT, 4) = "SUB " OR _
                   LEFT$(TXT, 9) = "CALLBACK " OR _
                      LEFT$(TXT, 7) = "STATIC " THEN

           FUNCTION = LOF(hFile) 'return length
           EXIT DO
        END IF
     END IF
  LOOP
  CLOSE hFile

END FUNCTION

'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
' UCASER function, returns UCASE string without altering original
'¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
FUNCTION UCASER(BYVAL st AS STRING) AS STRING
  #REGISTER NONE
  LOCAL p AS STRING PTR
  p = STRPTR(st)

  ! mov eax, p              ; move pointer to string into eax
  ! mov ecx, [eax-4]        ; move length of string into ecx (counter)
  ! cmp ecx, 0              ; if length is 0, no string length
  ! je exitUCASER           ; then exit

  beginUCASER:
     ! mov dl, [eax]        ; move current char into dl
     ! cmp dl, 97           ; compare against value 97 (a)
     ! jb nextUCASER        ; if dl < 97  then get next character
     ! cmp dl, 123          ; compare against value 123
     ! jb makeUCASER        ; if dl < 123 it is in 97-122 range, make Uppercase and get next
     ! cmp dl, 224          ; compare against value 224 (à) - extended ANSI
     ! jb nextUCASER        ; if dl < 224 it is in 123-224 range, do nothing to it
     ! cmp dl, 247          ; compare against value 247
     ! jb makeUCASER        ; if dl < 247 it is in 224-247 range, make Uppercase and get next
     ! je nextUCASER        ; if dl = 247, do nothing
     ! cmp dl, 255          ; compare against value 255
     ! jb makeUCASER        ; if dl < 255 it is in 248-255 range, make Uppercase and get next
     ! jmp nextUCASER       ; else, on to next character

  makeUCASER:
     ! sub dl, 32           ; make lowercase by adding 32 to dl's value
     ! mov [eax], dl        ; write changed char back into eax and fall through to nextUCASER

  nextUCASER:
     ! inc eax               ; get next character
     ! dec ecx               ; decrease ecx (length) counter
     ! jnz beginUCASER       ; iterate if not zero (end of string)
     FUNCTION = st

  exitUCASER:
END FUNCTION
