#COMPILE EXE
#DIM ALL
'
#INCLUDE "win32api.inc"

GLOBAL g_astrVocab() AS STRING   ' vocabulary: g_astrVocab(id) =
'                                  the word for that token id
GLOBAL g_adblBi() AS DOUBLE      ' bigram count matrix: g_adblBi(a,b) =
'                                  times token b followed token a
GLOBAL g_lngV AS LONG            ' vocabulary size (number of unique tokens)
'
FUNCTION PBMAIN() AS LONG
  LOCAL strTrainingText AS STRING    ' the training text
  LOCAL strWord AS STRING        ' current word being tokenized
  LOCAL lngNum AS LONG           ' number of words in the training text
  LOCAL lngTokenIndex AS LONG    ' general loop counter
  '                                (query token index in attention)
  LOCAL lngWordTokenID AS LONG   ' token id of the current word
  '
  ' prepare the console
  CON.CAPTION$= "LLM techniques demo"
  CON.COLOR 10,-1                ' make the text green
  '
  CON.SCREEN = 30,80             ' set console size
  CON.VIRTUAL = 60,80            ' allow virtual console size
  CON.LOC = 40,40                ' set location
  RANDOMIZE TIMER                ' set random seed to value of timer
  strTrainingText = "the cat sat on the mat the dog sat on the rug"
  strTrainingText = "the cat sat on the mat the dog sat on the rug " & _
                    "the baby sat on the rug"
  strTrainingText = "the cat sat on the mat the dog sat on the rug " & _
                    "the baby sat on the rug the table sat on the rug"
  strTrainingText = "the cat sat on the mat the dog sat on the rug " & _
                    "the baby sat on the rug the table sat on the rug " & _
                    "the mouse sat on the table"
  '
  lngNum = PARSECOUNT(strTrainingText, " ")
  REDIM g_astrVocab(lngNum)     ' size vocabulary array
  '                               (at most lngNum unique words)
  DIM a_lngIds(lngNum) AS LONG  ' strTrainingText as a sequence of token ids
  '
  ' ===== 1. Tokenization =====
  CON.PRINT "== 1. TOKENISATION =="
  FOR lngTokenIndex = 1 TO lngNum
    strWord = PARSE$(strTrainingText, " ", lngTokenIndex)
    lngWordTokenID = funTokenId(strWord)
    IF lngWordTokenID = 0 THEN
      INCR g_lngV
      g_astrVocab(g_lngV) = strWord
      lngWordTokenID = g_lngV
    END IF
    a_lngIds(lngTokenIndex) = lngWordTokenID
    CON.PRINT "'"; strWord; "' -> "; lngWordTokenID
  NEXT
  CON.PRINT "Vocabulary size:"; g_lngV
  WAITKEY$
  '
  ' ===== 2. "Training": count next-token pairs =====
  CON.PRINT : CON.PRINT "== 2. Training"
  ' size the bigram matrix now that the vocabulary is known
  REDIM g_adblBi(g_lngV, g_lngV)
  FOR lngTokenIndex = 1 TO lngNum - 1
  ' for each word
    INCR g_adblBi(a_lngIds(lngTokenIndex), a_lngIds(lngTokenIndex + 1))
  NEXT lngTokenIndex
  '
  CON.PRINT "Training completed"
  WAITKEY$
  '
  ' ===== 3. Temperature =====
  CON.PRINT : CON.PRINT "== 3. TEMPERATURE: P(next | 'the') =="
  DIM a_dblProb(g_lngV) AS DOUBLE   ' next-token probabilities for display
  DIM a_dblTemps(3) AS DOUBLE       ' the three temperatures to compare
  LOCAL lngVocabTokenIndex AS LONG  ' general loop counter - vocab index
  LOCAL lngTempTokenIndex AS LONG   ' general loop counter - temp index
  ' set the temps
  a_dblTemps(1) = 0.3
  a_dblTemps(2) = 1
  a_dblTemps(3) = 3
  '
  FOR lngTempTokenIndex = 1 TO 3
    subNextProbs(funTokenId("the"), a_dblTemps(lngTempTokenIndex), _
                 a_dblProb())
    CON.PRINT "T="; FORMAT$(a_dblTemps(lngTempTokenIndex), "0.0"); "  ";
    FOR lngVocabTokenIndex = 1 TO g_lngV
      CON.PRINT g_astrVocab(lngVocabTokenIndex); "="; _
          FORMAT$(a_dblProb(lngVocabTokenIndex), "0.00"); " ";
    NEXT lngVocabTokenIndex
    CON.PRINT
  NEXT lngTempTokenIndex
  WAITKEY$
  '
  ' ===== 4. Decoding strategies =====
  CON.PRINT : CON.PRINT "== 4. DECODING =="
  subGenerate(funTokenId("the"), 8, 0#, 0, "Greedy      ")
  subGenerate(funTokenId("the"), 8, 1#, 0, "Sample T=1  ")
  subGenerate(funTokenId("the"), 8, 1#, 2, "Top-k (k=2) ")
  subGenerate(funTokenId("the"), 8, 3#, 0, "Sample T=3  ")
  WAITKEY$
  '
  ' ===== 5. Embeddings & cosine similarity =====
  CON.PRINT : CON.PRINT "== 5. EMBEDDING SIMILARITY =="
  CON.PRINT "cos(cat, dog) = "; FORMAT$(funCosine(funTokenId("cat"), _
                            funTokenId("dog")), "0.000")
  CON.PRINT "cos(cat, mat) = "; FORMAT$(funCosine(funTokenId("cat"), _
                            funTokenId("mat")), "0.000")
  CON.PRINT "cos(mat, rug) = "; FORMAT$(funCosine(funTokenId("mat"), _
                            funTokenId("rug")), "0.000")
  '
  CON.PRINT "cos(cat, baby) = "; FORMAT$(funCosine(funTokenId("cat"), _
                            funTokenId("baby")), "0.000")
  CON.PRINT "cos(cat, table) = "; FORMAT$(funCosine(funTokenId("cat"), _
                            funTokenId("table")), "0.000")
  CON.PRINT "cos(cat, mouse) = "; FORMAT$(funCosine(funTokenId("cat"), _
                            funTokenId("mouse")), "0.000")
  CON.PRINT "cos(rug, table) = "; FORMAT$(funCosine(funTokenId("rug"), _
                            funTokenId("table")), "0.000")
  CON.PRINT:CON.PRINT
  WAITKEY$
  '
  ' ===== 6. Self-attention over "the cat sat" =====
  CON.PRINT : CON.PRINT "== 6. SELF-ATTENTION (Q=K=V=embeddings) =="
  LOCAL lngDim AS LONG        ' embedding dimension (2 * vocabulary size)
  lngDim = 2 * g_lngV
  DIM a_dblRaSc(3) AS DOUBLE  ' raw attention scores for one query against the 3 keys
  DIM a_dblAw(3) AS DOUBLE    ' attention weights (softmax of the scores)
  '
  LOCAL dblAccDot AS DOUBLE       ' accumulator for a dot product
  LOCAL lngTempInd AS LONG        ' loop counter (temperature index / embedding dimension)
  '
  CON.PRINT "Rows = query token, columns = the / cat / sat"
  FOR lngTokenIndex = 1 TO 3
    FOR lngVocabTokenIndex = 1 TO 3
      dblAccDot = 0
      FOR lngTempInd = 1 TO lngDim
        dblAccDot = dblAccDot + _
                    funEmb(a_lngIds(lngTokenIndex), lngTempInd) * _
                    funEmb(a_lngIds(lngVocabTokenIndex), lngTempInd)
      NEXT lngTempInd
      a_dblRaSc(lngVocabTokenIndex) = dblAccDot / SQR(lngDim) ' scaled dot product QK^T / sqrt(d)
    NEXT
    '
    subSoftmax(a_dblRaSc(), a_dblAw(), 3, 1#)          ' attention weights
    CON.PRINT g_astrVocab(a_lngIds(lngTokenIndex)); TAB(8);
    '
    FOR lngVocabTokenIndex = 1 TO 3
      CON.PRINT FORMAT$(a_dblAw(lngVocabTokenIndex), "0.00"); "  ";
    NEXT lngVocabTokenIndex
    CON.PRINT
    '
  NEXT lngTokenIndex
  '
  CON.PRINT:CON.PRINT
  CON.PRINT "press any key to exit"
  WAITKEY$
  '
END FUNCTION
'
FUNCTION funTokenId(strWord AS STRING) AS LONG
  ' Param strWord: the word to look up in the vocabulary
  LOCAL lngI AS LONG           ' loop counter over vocabulary entries
  FOR lngI = 1 TO g_lngV
    IF g_astrVocab(lngI) = strWord THEN
      FUNCTION = lngI
      EXIT FUNCTION
    END IF
  NEXT
  FUNCTION = 0
END FUNCTION

SUB subNextProbs(lngTokID AS LONG, _
                 dblTemps AS DOUBLE, _
                 a_dblProb() AS DOUBLE)
  ' Params: lngTokID = current token id, temp = temperature, p() = output probabilities
  LOCAL lngCounter AS LONG        ' loop counter over candidate next tokens
  DIM a_dblLogits(g_lngV) AS DOUBLE    ' raw scores (smoothed log-counts) for each candidate token
  FOR lngCounter = 1 TO g_lngV
  ' smoothed log-count = logit
    a_dblLogits(lngCounter) = LOG(g_adblBi(lngTokID, lngCounter) + 0.05)
  NEXT lngCounter
  '
  subSoftmax(a_dblLogits(), a_dblProb(), g_lngV, dblTemps)
  '
END SUB
'
SUB subSoftmax(a_dblLogits() AS DOUBLE, _
            a_dblProb() AS DOUBLE, _
            g_lngV AS LONG, _
            dblTemps AS DOUBLE)
  ' Params: dblLogits() = input logits,
  '         a_dblProb() = output probabilities,
  '         g_lngV = number of elements,
  '         dblTemps = temperature (low = sharp, high = flat)
  LOCAL lngI AS LONG        ' loop counter
  LOCAL dblMx AS DOUBLE     ' largest logit, subtracted for numerical stability
  LOCAL dblSum AS DOUBLE    ' running sum of exponentials (normalising constant)
  dblMx = a_dblLogits(1)
  '
  FOR lngI = 2 TO g_lngV
    IF a_dblLogits(lngI) > dblMx THEN
      dblMx = a_dblLogits(lngI)
    END IF
  NEXT lngI
  '
  FOR lngI = 1 TO g_lngV
    a_dblProb(lngI) = EXP((a_dblLogits(lngI) - dblMx) / dblTemps)
    dblSum = dblSum + a_dblProb(lngI)
  NEXT lngI
  '
  FOR lngI = 1 TO g_lngV
    a_dblProb(lngI) = a_dblProb(lngI) / dblSum
  NEXT lngI
  '
END SUB
'
SUB subGenerate(lngStart AS LONG, _
                lngSteps AS LONG, _
                dblTemp AS DOUBLE, _
                lngK AS LONG, _
                strLabel AS STRING)
  ' Params: lngStart = first token id,
  '         lngSteps = tokens to generate,
  '         dblTtemp = temperature (<=0 means greedy),
  '         lngK = top-k cutoff (0 = off),
  '         strLabel = label printed before the generated text
  LOCAL lngStep AS LONG      ' generation step counter
  LOCAL lngLoop AS LONG      ' loop counter over candidate tokens
  LOCAL lngTokenID AS LONG   ' current token id (the "context")
  LOCAL lngTokenPick AS LONG ' token id chosen for the next position
  LOCAL dblR AS DOUBLE       ' random number in [0,1) used for sampling
  LOCAL lngCumProb AS DOUBLE ' cumulative probability while scanning the distribution
  LOCAL strOutput AS STRING  ' generated text accumulated so far
  DIM a_dblProbDist(g_lngV) AS DOUBLE  ' next-token probability distribution
  '
  lngTokenID = lngStart
  strOutput = g_astrVocab(lngTokenID)
  FOR lngStep = 1 TO lngSteps
    IF dblTemp <= 0 THEN
      subNextProbs(lngTokenID, 1#, a_dblProbDist())
      lngTokenPick = 1
      FOR lngLoop = 2 TO g_lngV
        IF a_dblProbDist(lngLoop) > a_dblProbDist(lngTokenPick) THEN
          lngTokenPick = lngLoop
        END IF
      NEXT lngLoop
      '
    ELSE
      subNextProbs(lngTokenID, dblTemp, a_dblProbDist())
      IF lngK > 0 THEN
        subTopK(a_dblProbDist(), lngK)
      END IF
      dblR = RND
      lngCumProb = 0
      lngTokenPick = g_lngV
      FOR lngLoop = 1 TO g_lngV
        lngCumProb = lngCumProb + a_dblProbDist(lngLoop)
        IF dblR <= lngCumProb THEN
          lngTokenPick = lngLoop
          EXIT FOR
        END IF
      NEXT lngLoop
    END IF
    strOutput = strOutput & " " & g_astrVocab(lngTokenPick)
    lngTokenID = lngTokenPick
  NEXT lngStep
  CON.PRINT strLabel ": "; strOutput
  '
END SUB
'
SUB subTopK(a_dblProbDist() AS DOUBLE, _
            lngK AS LONG)
  ' Params: a_dblProbDist() = probabilities (modified in place),
  ' lngK = how many tokens to keep
  LOCAL lngI AS LONG        ' loop counter over tokens
  LOCAL lngPass AS LONG     ' which of the lngK selection rounds we are on
  LOCAL lngBest AS LONG     ' index of the highest-probability token not yet kept
  LOCAL dblSum AS DOUBLE    ' sum of surviving probabilities, used to renormalise
  DIM a_lngKeep(g_lngV) AS LONG ' flag per token: 1 = selected in the top lngK, 0 = discard
  '
  FOR lngPass = 1 TO lngK
    lngBest = 0
    FOR lngI = 1 TO g_lngV
      IF a_lngKeep(lngI) = 0 THEN
        IF lngBest = 0 THEN
          lngBest = lngI
        ELSEIF a_dblProbDist(lngI) > a_dblProbDist(lngBest) THEN
          lngBest = lngI
        END IF
      END IF
    NEXT lngI
    a_lngKeep(lngBest) = 1
  NEXT lngPass
  '
  FOR lngI = 1 TO g_lngV
    IF a_lngKeep(lngI) = 0 THEN a_dblProbDist(lngI) = 0
    dblSum = dblSum + a_dblProbDist(lngI)
  NEXT lngI
  '
  FOR lngI = 1 TO g_lngV
    a_dblProbDist(lngI) = a_dblProbDist(lngI) / dblSum
  NEXT lngI
  '
END SUB
'
FUNCTION funCosine(lngTokenA AS LONG, _
                   lngTokenB AS LONG) AS DOUBLE
  ' Params: a, b = the two token ids to compare
  LOCAL lngDim AS LONG           ' loop counter over embedding dimensions
  LOCAL dblDotProd AS DOUBLE     ' dot product of the two embeddings
  LOCAL dblSQLenA AS DOUBLE      ' squared length of embedding a
  LOCAL dblSQLenB AS DOUBLE      ' squared length of embedding b
  '
  FOR lngDim = 1 TO 2 * g_lngV
    dblDotProd  = dblDotProd  + _
                  funEmb(lngTokenA, lngDim) * _
                  funEmb(lngTokenB, lngDim)
                  '
    dblSQLenA = dblSQLenA + funEmb(lngTokenA, lngDim) ^ 2
    dblSQLenB = dblSQLenB + funEmb(lngTokenB, lngDim) ^ 2
  NEXT lngDim
  '
  IF dblSQLenA = 0 OR dblSQLenB = 0 THEN
    FUNCTION = 0
  ELSE
    FUNCTION = dblDotProd / (SQR(dblSQLenA) * SQR(dblSQLenB))
  END IF
  '
END FUNCTION
'
' ---- 5. Embedding = [what follows me | what precedes me] ----
FUNCTION funEmb(lngTokenID AS LONG, _
                lngDim AS LONG) AS DOUBLE
  ' Params: lngTokenID = token id,
  '         dblDim = embedding dimension (1..2*g_lngV)
  IF lngDim <= g_lngV THEN
    FUNCTION = g_adblBi(lngTokenID, lngDim)
  ELSE
    FUNCTION = g_adblBi(lngDim - g_lngV, lngTokenID)
  END IF
  '
END FUNCTION
