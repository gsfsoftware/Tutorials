#COMPILE DLL
#DIM ALL

#INCLUDE ONCE "Win32API.inc"

GLOBAL ghInstance AS DWORD

' define the globals
GLOBAL hDlg AS LONG
GLOBAL lngDialogWidth AS LONG   ' used to store the size of the dialog itself
GLOBAL lngDialogHeight AS LONG  ' height of the dialog
GLOBAL hFont AS DWORD           ' handle for the font
'
%PBCritical =    12000
%PBInformation = 12001
%PBQuestion =    12002
%PBExclamation = 12003
'
#RESOURCE ICON 12000 "Critical.ico"
#RESOURCE ICON 12001 "Information.ico"
#RESOURCE ICON 12002 "Question.ico"
#RESOURCE ICON 12003 "Exclamation.ico"







'-------------------------------------------------------------------------------
' Main DLL entry point called by Windows...
'
FUNCTION LIBMAIN (BYVAL hInstance   AS LONG, _
                  BYVAL fwdReason   AS LONG, _
                  BYVAL lpvReserved AS LONG) AS LONG

    SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH
        'Indicates that the DLL is being loaded by another process (a DLL
        'or EXE is loading the DLL).  DLLs can use this opportunity to
        'initialize any instance or global data, such as arrays.

        ghInstance = hInstance
        FONT NEW "Verdana" ,12, 0, 0, 0, 0 TO hFont
        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.
        FONT END hFont
        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_ATTACH
        'Indicates that the DLL is being loaded by a new thread in the
        'calling application.  DLLs can use this opportunity to
        'initialize any thread local storage (TLS).

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_DETACH
        'Indicates that the thread is exiting cleanly.  If the DLL has
        'allocated any thread local storage, it should be released.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    END SELECT

END FUNCTION
'

FUNCTION PBMsgbox _
         ALIAS "PBMsgbox" (hApp AS LONG, _
                           strTitle AS STRING, _
                           strMessage AS STRING, _
                           strButtons AS STRING, _
                           lngIcon AS LONG, _
                           lngDefaultButton AS LONG) EXPORT AS STRING
' this is a PB version of the message box giving better control over the buttons shown
'
' hApp = handle to the owner form calling the routine
' strTitle = "String Caption to the message box"
' strMessage = "Text message of the message box"
' strButtons = "&Ok|&Yes|&Maybe"
' Pipe (|) delimited string containing the text to caption the buttons
' intDefaultButton = The button number of the default button
' e.g. 1 = first button; 2 = second button ; 0= no default button
' This function will return the name, as a string,
' of the button clicked on {excluding any & character}
  LOCAL lngResult AS LONG             ' variable for the result of the dialog selection
  LOCAL lngStyle AS LONG              ' Options for display of button
  LOCAL strButtonName AS STRING       ' the caption of the button
  LOCAL lngStarterHandle AS LONG      ' the unique handle for the button
  LOCAL lngButtonCounter AS LONG      ' the button counter
  LOCAL lngParsecount AS LONG         ' the total number of buttons requested
  LOCAL lngBeginX AS LONG             ' incremented start position for next button
  LOCAL lngStartX AS LONG             ' coordinates for button positions
  LOCAL lngStartY AS LONG
  LOCAL lngButtonHeight AS LONG       ' the height and width of the buttons
  LOCAL lngButtonWidth AS LONG
  LOCAL strImage AS ASCIIZ *50        ' the string to hold the image identifier in the resource file
  LOCAL lngTextWidth AS LONG          ' used to store the width and height
  LOCAL lngTextHeight AS LONG         ' of the label containing the users text
  LOCAL lngButtonSeparation AS LONG   ' distance between buttons
  LOCAL lngMaxChrsPerLine AS LONG     ' Maximum number of estimated characters per line
  LOCAL lngMaxChrsPerTitle AS LONG    ' Maximum number of estimated characters per title/caption line
  LOCAL lngMinDialogWidth AS LONG     ' the minimum width of a dialog (i.e three buttons worth)
  '
  IF TRIM$(strButtons) = "" THEN
  ' no buttons exit immediately
    FUNCTION = ""
    EXIT FUNCTION
  END IF
  '
  IF TRIM$(strTitle)="" THEN strTitle="No Title"
  IF TRIM$(strMessage)="" THEN strMessage="No Message"
  '
  ' first set the icon to be used
  SELECT CASE lngIcon
    CASE 1
    ' exclamation
      strImage="#" & FORMAT$(%PBExclamation)
    CASE 2
    ' stop
      strImage="#" & FORMAT$(%PBCritical)
    CASE 3
    ' information
      strImage="#" & FORMAT$(%PBInformation)
    CASE 4
    ' question
      strImage="#" & FORMAT$(%PBQuestion)
    CASE ELSE
    ' default to information
      strImage= "#" & FORMAT$(%PBInformation)
  END SELECT
  '
  ' now handle the buttons
  lngParseCount=PARSECOUNT(strButtons,ANY "|")  ' work out how many buttons there are
  IF lngDefaultButton > lngParseCount OR lngDefaultButton < 0 THEN
  ' handle silly values given from calling app
     FUNCTION="":EXIT FUNCTION
  END IF
  '
  lngStartX= 30:  lngStartY= 35  ' set the starting coordinates of the buttons
  lngButtonHeight = 20 :lngButtonWidth = 60     ' set the size of the buttons
  lngDialogHeight = 80      ' set the initial dialog size
  lngButtonSeparation = 5   ' set the initial button separation
  lngMaxChrsPerLine = 33    ' set the initial estimated max characters per line
  lngMaxChrsPerTitle = 28   ' set the initial estimated max characters per title/caption
  '
  ' set the width
  lngMinDialogWidth = (lngParseCount * lngButtonWidth)+ _
                      (lngParseCount * lngButtonSeparation)+25
  ' set the initial label height
  lngTextHeight = 4+(10 * ROUND((LEN(strMessage)\lngMaxChrsPerLine),0))
  '
  ' now check if there are any embedded CRLF's in the code and expand the text box accordingly
  lngTextHeight = lngTextHeight + _
                 (10 * PARSECOUNT(strMessage,ANY CHR$(13)))
                 '
  ' now determine the size of the form (based on the number of buttons)
  IF lngParseCount>3 THEN
  ' calc the resize of the dialog if there are more than three buttons
    lngDialogWidth=(lngParseCount * lngButtonWidth)+ (lngParseCount * 5)+25
    ' leave button separation as 5
  ELSE
  ' set size to be equivalent to three buttons  (i.e. mimimum width )
    lngDialogWidth=lngMinDialogWidth
    CALL ReCentreButtons(lngParseCount,lngStartX,lngButtonSeparation, lngButtonWidth)
    '
  END IF
  '
  ' now check if the title of the message box is too wide to be displayed
  ' if so then expand the dialogs width to handle it - within reason
  '
  IF LEN(strTitle)\lngMaxChrsPerLine +1> (lngDialogWidth\lngMinDialogWidth) THEN
  ' expand the dialog to fit the text
    lngDialogWidth = lngDialogWidth + ((LEN(strTitle)-lngMaxChrsPerTitle)*3)
    ' now recenter the buttons on the dialog
    CALL ReCentreButtons(lngParseCount,lngStartX,lngButtonSeparation, lngButtonWidth)
  END IF
  '
  ' build the dialog  - sized to fit in the buttons
  '
  DialogStart:
  lngStarterHandle=1000     ' initialise the starter handle number
  lngBeginX = lngStartX     ' initialise the first button start position
  lngButtonCounter=1        ' start at the first button
  '
  DIALOG NEW hApp,strTitle,,,lngDialogWidth,lngDialogHeight,_
        %DS_SYSMODAL OR _
        %DS_MODALFRAME OR %WS_CAPTION OR _
        %DS_CENTERMOUSE OR %DS_CENTER, _
        %WS_EX_TOPMOST OR %WS_EX_TOOLWINDOW TO hDlg
        '
  ' now add the text label containing the users text
  CONTROL ADD LABEL, hDlg,2000,strMessage,30,5, _
              lngDialogWidth-40,lngTextHeight,%SS_NOPREFIX
              '
  ' now work out its height to determine the buton starting position
  CONTROL GET SIZE hDlg, 2000 TO lngTextWidth, lngTextHeight                '
  '
  ' now reset the starting Y position of the buttons
  lngStartY = lngTextHeight +5
  '
  ' and resize the dialog to accomodate this
  lngDialogHeight=lngStartY + lngButtonHeight + 10
  '
  ' now add the icon
  CONTROL ADD IMAGE, hDlg,2010, strImage,5,5,30,30
  '
  DO    ' loop round the list of buttons till none left
    strButtonName = PARSE$(strButtons, ANY "|",lngButtonCounter)
    'pick up the buttons name
    INCR lngStarterHandle
    ' advance the command button handle {used to identify the button}
    '
    ' now add the button at calculated position
    IF lngButtonCounter=lngDefaultButton THEN
    ' is this the default button?
      lngStyle = %BS_DEFAULT + %WS_TABSTOP   ' if so make it default and give it a tabstop
    ELSE
    ' all other buttons
      lngStyle = %WS_TABSTOP   ' just a tabstop
    END IF
    '
    CONTROL ADD BUTTON, hDlg,lngStarterHandle,strButtonName, _
                        lngBeginX,lngStartY, _
                        lngButtonWidth,lngButtonHeight,lngStyle
                        ' add the button
   INCR lngButtonCounter ' advance the button completed counter
   '
   ' recalculate the next buttons position
    lngBeginX = lngBeginX + _
                lngButtonWidth + _
                lngButtonSeparation
  ' loop if there is another button
  LOOP UNTIL lngButtonCounter > lngParseCount
  '
  CALL CentreWindow(hDlg)   ' centre the dialog on the screen
  '
  ' resize the dialog based on the contents
  DIALOG SET SIZE hDlg, lngDialogWidth +10, lngDialogHeight+15
  '
  IF lngDefaultButton>0 THEN
  ' set the focus to the default button
    CONTROL SET FOCUS hDlg,(1000 + lngDefaultButton)
    ' and give it a black border
    CONTROL SEND hDlg, (1000 + lngDefaultButton), _
                 %BM_SETSTYLE, %BS_DEFPUSHBUTTON, %TRUE
  END IF
  '
  CONTROL SET FONT hDlg, 2000, hFont
  DIALOG SHOW MODAL hDlg,CALL PBMsgboxHandler TO lngResult
  '
  IF lngDefaultButton=0 AND lngResult=1 THEN
  ' There is no set default and return has been pressed
    GOTO DialogStart   ' display the dialog again
  END IF
  '
  IF lngResult>1000 THEN
  ' result is a handle (as the started at 1000)
  ' so take off the Starter handle number to determine the button
    lngResult= lngResult-1000
  ELSE
    lngResult = lngDefaultButton
    ' otherwise it is set to the default button
  END IF
  '
  strButtonName=REMOVE$(TRIM$(PARSE$(strButtons, _
                ANY "|",lngResult)),"&")
  '
  FUNCTION = strButtonName ' pass back the button name
  '
END FUNCTION
'
SUB ReCentreButtons(lngParseCount AS LONG, _
                    lngStartX AS LONG, _
                    lngButtonSeparation AS LONG, _
                    lngButtonWidth AS LONG)
' recentre the buttons on the newly sized dialog
' this function doesn't actually do the recentering
' but works out the coordinates required
  SELECT CASE lngParseCount
    CASE 1
    ' single button - so centre button on the dialog
       lngStartx=(lngDialogWidth\2)-(lngButtonWidth\2)
    CASE 2
    ' two buttons - so centre buttons on the dialog
       lngStartX=(lngDialogWidth\4)-(lngButtonWidth\2)
       lngButtonSeparation = (lngDialogWidth\2)-lngButtonWidth
  END SELECT
END SUB
'
SUB CentreWindow(BYVAL hWnd AS LONG)
' centre the window or dialog given its handle
  LOCAL WndRect AS RECT
  LOCAL x       AS LONG
  LOCAL y       AS LONG
  ' get the size of the window or dialog in
  ' WndRect structure
  GetWindowRect hWnd, WndRect
  ' work out the screen size , the window size
  ' and where it should be positioned
  x = (GetSystemMetrics(%SM_CXSCREEN)- _
      (WndRect.nRight-WndRect.nLeft))\2
      '
  y = (GetSystemMetrics(%SM_CYSCREEN)- _
      (WndRect.nBottom-WndRect.nTop + _
       GetSystemMetrics(%SM_CYCAPTION)))\2

  ' move the window or dialog into position
  SetWindowPos hWnd, %NULL, x, y, 0, 0, _
      %SWP_NOSIZE OR %SWP_NOZORDER
  '
END SUB
'
CALLBACK FUNCTION PBMsgboxHandler()
' handle any events that happen inside the message box
  LOCAL lngMsg AS LONG
  SELECT CASE CB.MSG
     '
     CASE %WM_COMMAND
     ' handle the commands
       IF CBCTLMSG = %BN_CLICKED THEN
       ' if button has been clicked on
       ' then end the dialog
       ' pick up the control number you allocated to this button
         lngMsg = CB.CTL
       ' close the dialog with the number of the button clicked on
         DIALOG END CBHNDL, lngMsg
       END IF
      '
     CASE ELSE
     ' handle anything else
       FUNCTION = 0
  END SELECT
'
END FUNCTION
