' Blockchain Transactions - BlockChainTransactions.inc
'
' include file hashing libraries
#INCLUDE "Base32Str.inc"
#INCLUDE "PBCrypto128.inc"
#INCLUDE "PB_FileHash.inc"
'
' define the block
TYPE uBlock
  BlockNumber AS STRING * 10
  TimeStamp AS STRING * 25        ' e.g. 17/01/2023 10:00:11.000
  TransactionData AS STRING * 255
  PreviousHash AS STRING * 32
  Buffer AS STRING * 1
  Hash AS STRING * 32
END TYPE
'
GLOBAL BlockChain AS IPOWERCOLLECTION
'
FUNCTION funInitialiseBlockChain() AS LONG
' create the Genesis Block
  LOCAL udtBlock AS uBlock
  ' set up Genesis Block
  PREFIX "udtBlock."
    BlockNumber = "0"
    TimeStamp = "08/02/2023 10:00:00.000"
    TransactionData = "Genesis Block"
    PreviousHash = "NLSSTOJSêIIBDDFL2êVZMIT32ZIJXKKG"
  END PREFIX
  '
  udtBlock.Hash = funReturnHashForBlock(udtBlock)
  '
  ' add to the collection
  ' set up a wide unicode string for the unique key
  ' in the collection
  LOCAL wKey AS WSTRING
  ' add the record
  wKey = udtBlock.Hash
  '
  BlockChain.ADD(wKey,udtBlock AS STRING)
  '
  IF OBJRESULT = %S_OK THEN
  ' operation has been successful
    funLog("Genesis key stored")
    FUNCTION = %TRUE
  ELSE
    funLog("Initial Genesis block cannot be stored")
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funLoadBlockChainFromFile(strFileFrom AS STRING) AS LONG
' load the collection from disk
  LOCAL lngFile AS LONG
  LOCAL strBlockChain AS STRING
  LOCAL udtBlock AS uBlock
  ' set up the wide unicode string for the unique key
  LOCAL wKey AS WSTRING
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileFrom FOR INPUT AS #lngFile
    WHILE NOT EOF(#lngFile)
      LINE INPUT #lngFile,strBlockChain
      TYPE SET udtBlock = strBlockChain
      '
       ' add record to the collection
      wKey = udtBlock.Hash
      BlockChain.ADD(wKey, udtBlock AS STRING)
      '
      IF OBJRESULT = %S_OK THEN
      ' operation worked
      '  funlog(wKey & " stored")
      ELSE
      ' possible duplicate key?
      '  funlog(wKey & " already stored or errored")
      END IF
      '
    WEND
    '
    FUNCTION = %TRUE
    '
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funReturnHashForBlock(udtBlock AS uBlock) AS STRING
' return the hash of a block
  FUNCTION = funGetStringSHA(udtBlock.BlockNumber & "|" & _
                             udtBlock.TimeStamp & "|" & _
                             udtBlock.TransactionData & "|" & _
                             udtBlock.PreviousHash)
'
END FUNCTION
'
FUNCTION funSaveBlockChainToFile(strFile AS STRING) AS LONG
' save the current block chain to File
  LOCAL lngFile AS LONG
  LOCAL vData AS VARIANT
  LOCAL udtBlock AS uBlock
  '
  lngFile = FREEFILE
  TRY
    OPEN strFile FOR OUTPUT AS #lngFile
    FOR EACH vData IN BlockChain
    ' for each record in the blockchain
    ' populate the UDT
      TYPE SET udtBlock = VARIANT$(BYTE,vData)
      ' and save to disk
      PRINT #lngFile,udtBlock
    NEXT
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE#lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funAddToBlockchain(strMessage AS STRING, _
                            strTimeStamp AS STRING) AS LONG) AS LONG
' add the transaction to blockchain
  LOCAL udtBlock AS uBlock        ' UDT for Block
  LOCAL strLastBlock AS STRING    ' last block number
  LOCAL strPreviousHash AS STRING ' previous hash value
  ' variant to hold data coming out of the collection
  LOCAL vData AS VARIANT
  '
  ' first get details of last transaction
  BlockChain.Last
  vData = BlockChain.Previous
  '
  IF OBJRESULT = %S_OK THEN
  ' populate the UDT with the data from vData variant variable
    TYPE SET udtBlock = VARIANT$(BYTE,vData)
    '
    ' get the hash of previous block
    strPreviousHash = udtBlock.Hash
    '
    ' get the block number of previous block
    strLastBlock = udtBlock.BlockNumber
    '
    ' now prepare new block
    PREFIX "udtBlock."
      BlockNumber = FORMAT$(VAL(strLastBlock) + 1)
      TimeStamp = strTimeStamp
      TransactionData = strMessage
      PreviousHash = strPreviousHash
    END PREFIX
    '
    udtBlock.Hash = funReturnHashForBlock(udtBlock)
    '
    ' now add this block to the BlockChain collection
    ' set up a wide unicode string for the unique key
    ' in the collection
    LOCAL wKey AS WSTRING
    '
    ' add the record
    wKey = udtBlock.Hash
    '
    BlockChain.ADD(wKey,udtBlock AS STRING)
    IF OBJRESULT = %S_OK THEN
    ' operation has been successful
      funLog("New key stored")
      FUNCTION = %TRUE
    ELSE
      funLog("New block cannot be stored")
      FUNCTION = %FALSE
    END IF
    '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetTimeStamp() AS STRING
' return the timestamp for now
  LOCAL ipNow AS IPOWERTIME
  LET ipNow = CLASS "PowerTime"
  '
  ipNow.Now  ' pick up current date time
  '
  ' The time is formatted as hh:mm:ss.mmm in 24-hour notation
  FUNCTION = ipNow.DateString & " " & ipNow.TimeStringFull
  '
END FUNCTION
