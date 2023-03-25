' Chat_GPT.inc
'***************************************************
'* Original code by: Ing. Roberto Pérez Villalobos *
'***************************************************
'

   '______________ Most important features to work __________
   '1) The ChatGPT URL for completions
   'URLcompletions = "https://api.openai.com/v1/completions"

   '2) To generate the API Key, create a account and go to
   'https://platform.openai.com/account/api-keys
'   ApiKey = "WRITE YOUR API KEY HERE"

   '3) ID of the model to use. You can use the List models API
   'to see all of your available models, or see our Model overview
   'for descriptions of them.
   'string Required
   'Model = "text-davinci-003"

   '4) The prompt(s) to generate completions for, encoded as a
   'string, array of strings, array of tokens, or array of token arrays.
   'Note that <|endoftext|> is the document separator that the
   'model sees during training, so if a prompt is not specified the
   'model will generate as if from the beginning of a new document.
   'string or array Optional Defaults to <|endoftext|>
   'Prompt = "What is PowerBasic?"      '"What is the meaning of life?"
   'Prompt = "What are the chances of establishing a base on the Moon in the next 10 years?"
   'Prompt = "How much money is spent on AI research per year for last five years?"

   '5) The maximum number of tokens to generate in the completion.
   'The token count of your prompt plus max_tokens cannot exceed
   'the model's context length.
   'Most models have a context length of 2048 tokens (except for
   'the newest models, which support 4096).
   'integer Optional Defaults to 16
   'MaxTokens = 500

   '6) What sampling temperature to use, between 0 and 2. Higher
   'values like 0.8 will make the output more random, while lower
   'values like 0.2 will make it more focused and deterministic.
   'We generally recommend altering this or top_p but not both.
   'number Optional Defaults to 1
   'Temperature = 1      '0.2
   'An alternative to sampling with temperature, called nucleus
   'sampling, where the model considers the results of the tokens
   'with top_p probability mass. So 0.1 means only the tokens
   'comprising the top 10% probability mass are considered.
   'We generally recommend altering this or temperature but
   'not both.
   'number Optional Defaults to 1
   'top_p = 1      '0.1

   '____________ Optional features _______________-
   'How many completions to generate for each prompt.
   'Note: Because this parameter generates many completions,
   'it can quickly consume your token quota. Use carefully and ensure
   'that you have reasonable settings for max_tokens and stop.
   'integer Optional Defaults to 1
   'n = 1

   'The suffix that comes after a completion of inserted text.
   'string Optional Defaults to null
   'suffix = "null"

   'Whether to stream back partial progress. If set, tokens
   'will be sent as data-only server-sent events as they become
   'available, with the stream terminated by a data: [DONE] message.
   'boolean Optional Defaults to false
   'stream ="false"

   'Include the log probabilities on the logprobs most likely
   'tokens, as well the chosen tokens. For example, if logprobs is 5,
   'the API will return a list of the 5 most likely tokens.
   'The API will always return the logprob of the sampled token, so there
   'may be up to logprobs+1 elements in the response.
   'The maximum value for logprobs is 5. If you need more than
   'this, please contact us through our Help center and describe your use case.
   'integer Optional Defaults to null
   'logprobs = "null"

   'Echo back the prompt in addition to the completion
   'boolean Optional Defaults to false
   'echo = "false"

   'Up to 4 sequences where the API will stop generating further
   'tokens. The returned text will not contain the stop sequence.
   'string or array Optional Defaults to null
   'stop = "null"

   'Number between -2.0 and 2.0. Positive values penalize new
   'tokens based on whether they appear in the text so far, increasing
   'the model's likelihood to talk about new topics.
   'number Optional Defaults to 0
   'presence_penalty=0

   'Number between -2.0 and 2.0. Positive values penalize new
   'tokens based on their existing frequency in the text so far,
   'decreasing the model's likelihood to repeat the same line verbatim.
   'number Optional Defaults to 0
   'frequency_penalty =0

   'Generates best_of completions server-side and returns the "best"
   '(the one with the highest log probability per token). Results
   'cannot be streamed.
   'When used with n, best_of controls the number of candidate
   'completions and n specifies how many to return – best_of must
   'be greater than n.
   'Note: Because this parameter generates many completions, it can
   'quickly consume your token quota. Use carefully and ensure
   'that you have reasonable settings for max_tokens and stop.
   ' integer Optional Defaults to 1
   'best_of = 1

   'Modify the likelihood of specified tokens appearing in the completion.
   'Accepts a json object that maps tokens (specified by their token ID in
   'the GPT tokenizer) to an associated bias value from -100 to 100.
   'You can use this tokenizer tool (which works for both GPT-2 and GPT-3)
   'to convert text to token IDs. Mathematically, the bias is added
   'to the logits generated by the model prior to sampling. The exact
   'effect will vary per model, but values between -1 and 1 should decrease
   'or increase likelihood of selection; values like -100 or 100
   'should result in a ban or exclusive selection of the relevant token.
   'As an example, you can pass {"50256": -100} to prevent the
   '<|endoftext|> token from being generated.
   'map Optional Defaults to null
   'logit_bias ="{""50256"": -100}" 'to prevent the <|endoftext|>
   'token from being generated.

   'A unique identifier representing your end-user, which can help OpenAI
   'to monitor and detect abuse. Learn more.
   'string Optional
   'user ="USER NAME"

'
FUNCTION funRunChatGPTQuery(wstrPrompt AS WSTRING, _
                            wstrURLcompletions AS WSTRING, _
                            wstrModel AS WSTRING, _
                            wstrApiKey AS WSTRING, _
                            dwMaxTokens AS DWORD, _
                            strOutput AS STRING) AS LONG
' run the query against ChatGPT
  LOCAL strInput AS STRING
  LOCAL strTemp AS STRING
  LOCAL oXml AS IServerXMLHTTPRequest2
  SET oXml = NEWCOM "MsXml2.ServerXMLHTTP"
  '
  IF ISTRUE(ISOBJECT(oXml)) THEN
  ' Open conection
    oXml.Open( "POST", wstrURLcompletions, %FALSE)
    '
    ' Send headers
    oXml.setRequestHeader "Content-Type", "application/json"
    oXml.setRequestHeader "Authorization", "Bearer " & wstrApiKey
    '
    ' Send prompt to ChatGPT
    oXml.Send( "{""prompt"": """ & wstrPrompt & """, ""model"": """ & _
              wstrModel & """,""max_tokens"":" & STR$(dwMaxTokens) & " }")
    '
    ' "Waiting on response..."
    DO WHILE oXml.ReadyState <> 4
      SLEEP 1000
      DIALOG DOEVENTS 0
    LOOP
    '
    ' pick up the response
    strInput = oXml.ResponseText
    '
    ' just return the key text
    strTemp = PARSE$(strInput,"[{" & $DQ & "text" & $DQ & _
                  ":" & $DQ & "\n\n",2)
    strOutput = PARSE$(strTemp,$DQ & ",",1)
    '
    ' alternative method if you want full details of response
    'strOutput = funParseJSON(strInput)
    ' save query to disk
    funSaveQuery(wstrPrompt,funParseJSON(strInput))
    '
    FUNCTION = %TRUE
  ELSE
    strOutput = "Unable to query ChatGPT"
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funSaveQuery(wstrPrompt AS WSTRING, _
                      strResult AS STRING) AS LONG
' save the prompt and query result
  LOCAL lngFile AS LONG
  '
  REPLACE "\n" WITH $CRLF IN strResult
  '
  lngFile = FREEFILE
  OPEN "QueryAudit.txt" FOR APPEND AS #lngFile
  PRINT #lngFile, wstrPrompt & $CRLF
  PRINT #lngFile, strResult & "******" & $CRLF
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION funParseJSON(strResult AS STRING) AS STRING
' parse the JSON result
'
  LOCAL strSection AS STRING
  LOCAL lngSection AS LONG
  LOCAL strInput AS STRING
  LOCAL lngInsideBracket AS LONG
  LOCAL lngInsideQuote AS LONG
  LOCAL strCharacter AS STRING
  LOCAL lngR AS LONG
  '
  strInput = strResult
  '
  LOCAL sbOutput AS ISTRINGBUILDERA
  sbOutput = CLASS "StringBuilderA"
  '
  sbOutput.clear
  sbOutput.capacity = 5000
  '
  REPLACE "{" WITH "{" & $CRLF IN strInput
  REPLACE "}" WITH $CRLF & "}" IN strInput
  '
  FOR lngSection = 1 TO PARSECOUNT(strInput, $CRLF)
    strSection = PARSE$(strInput,$CRLF, lngSection)
    '
    SELECT CASE strSection
      CASE "[{", "}]"
        sbOutput.ADD strSection & $CRLF
        ITERATE FOR
    END SELECT
    '
    lngInsideBracket = %FALSE
    lngInsideQuote = %FALSE
    '
    FOR lngR = 1 TO LEN(strSection)
    ' look through the section one character at a time
      strCharacter = MID$(strSection,lngR,1)
      SELECT CASE strCharacter
        CASE $DQ
          IF ISTRUE lngInsideQuote THEN
            lngInsideQuote = %FALSE
          ELSE
            lngInsideQuote = %TRUE
          END IF
          '
          sbOutput.ADD strCharacter
        CASE "["
          lngInsideBracket = %TRUE
          sbOutput.ADD strCharacter
        CASE "]"
          lngInsideBracket = %FALSE
          sbOutput.ADD strCharacter
          '
        CASE ","
          IF ISTRUE lngInsideBracket OR ISTRUE lngInsideQuote THEN
            sbOutput.ADD strCharacter
          ELSE
            sbOutput.ADD strCharacter & $CRLF
          END IF
        CASE ELSE
          sbOutput.ADD strCharacter
          '
      END SELECT
    '
    NEXT lngR
    '
    sbOutput.ADD $CRLF
    '
  NEXT lngSection
  '
  FUNCTION = sbOutput.STRING
  '
END FUNCTION
