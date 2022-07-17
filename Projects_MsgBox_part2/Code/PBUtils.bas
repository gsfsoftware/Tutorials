#COMPILE DLL
#DIM ALL
#DEBUG ERROR ON

#INCLUDE ONCE "Win32API.inc"
#INCLUDE ONCE "..\Libraries\PB_Windows_Controls.inc"
'
GLOBAL ghInstance AS DWORD
GLOBAL ghLib AS DWORD        ' global for RichText library
'
#RESOURCE ICON, PBCritical,"icon1.ico"
#RESOURCE ICON, PBInformation,"icon2.ico"
#RESOURCE ICON, PBQuestion,"icon3.ico"
#RESOURCE ICON, PBExclamation,"icon4.ico"
'
' define the globals
GLOBAL hDlg AS LONG
GLOBAL lngDialogWidth AS LONG        ' used to store the size of the dialog itself
GLOBAL lngDialogHeight AS LONG
GLOBAL strInputText AS STRING
'
ENUM Icons SINGULAR
  PBCritical = 1
  PBInformation
  PBQuestion
  PBExclamation
END ENUM
'
%IDC_Richedit1 = 2001
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

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.

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
FUNCTION PBMsgbox ALIAS "PBMsgbox" (hApp AS LONG, _
                         strTitle AS STRING, _
                         strMessage AS STRING, _
                         strButtons AS STRING, _
                         lngIcon AS LONG, _
                         lngDefaultButton AS LONG, _
                         OPTIONAL strURL AS STRING) EXPORT AS STRING
' this is a PB version of the message box giving better control over the buttons shown
'
' hApp = handle to the owner form calling the routine
' strTitle = "String Caption to the message box"
' strMessage = "Text message of the message box"
' strButtons = "&Ok|&Yes|&Maybe"   Pipe (|) delimited string containing the text to caption the buttons
' lngIcon = the Icon number to use e.g. %PBCritical
' lngDefaultButton = The button number of the default button e.g. 1 = first button; 2 = second button ; 0= no default button
' optional URL string
' This function will return the name, as a string, of the button clicked on {excluding any & character}
'
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
  LOCAL strLocalURL AS STRING         ' local copy of the URL passed
  '
  IF ISFALSE ISMISSING(strURL) THEN
  ' pick up the passed URL
    strLocalURL = strURL
  END IF
  '
  IF TRIM$(strButtons)="" THEN FUNCTION="":EXIT FUNCTION  ' exit if no button names are given
  IF TRIM$(strTitle)="" THEN strTitle="No Title"
  IF TRIM$(strMessage)="" THEN strMessage="No Message"
  '
  ' now handle the buttons
  lngParseCount=PARSECOUNT(strButtons,ANY "|")
  ' work out how many buttons there are
  IF lngDefaultButton > lngParseCount OR lngDefaultButton < 0 THEN
  ' handle odd values supplied
     FUNCTION="":EXIT FUNCTION
  END IF
  '
  lngStartX= 10:  lngStartY= 30
  ' set the starting coordinates of the buttons
  lngButtonHeight = 14 :lngButtonWidth = 60
  ' set the size of the buttons
  lngDialogHeight = 50    ' set the initial dialog size
  lngButtonSeparation = 5   ' set the initial button separation
  lngMaxChrsPerLine = 33    ' set the initial estimated max characters per line
  lngMaxChrsPerTitle = 28   ' set the initial estimated max characters per title/caption
  lngMinDialogWidth = (3 * lngButtonWidth) + _
                      (3 * lngButtonSeparation)+15
  ' set the 3 button width
  '
  ' set the initial label height
  lngTextHeight = 4+(10 * ROUND( _
                (LEN(strMessage)\lngMaxChrsPerLine),0)) +10
  '
  ' now check if there are any embedded CRLF's in the code and expand the text box accordingly
  lngTextHeight = lngTextHeight + (10 * PARSECOUNT(strMessage,ANY $LF))
  '
  ' now determine the size of the form (based on the number of buttons)
  IF lngParseCount>3 THEN
  ' calc the resize of the dialog if there are more than three buttons
    lngDialogWidth=(lngParseCount * lngButtonWidth) + _
                   (lngParseCount * lngButtonSeparation)+15
    '
  ELSE
  ' set size to be equivalent to three buttons  (i.e. mimimum width )
    lngDialogWidth=lngMinDialogWidth
    CALL subReCentreButtons(lngParseCount, _
         lngStartX,lngButtonSeparation, _
         lngButtonWidth)
    '
  END IF
  '
  IF LEN(strTitle)\lngMaxChrsPerLine +1 > (lngDialogWidth\lngMinDialogWidth) THEN
  ' expand the dialog to fit the text
    lngDialogWidth = lngDialogWidth + ((LEN(strTitle)-lngMaxChrsPerTitle)*3)
    ' now recenter the buttons on the dialog
    CALL subReCentreButtons(lngParseCount, _
                            lngStartX, _
                            lngButtonSeparation, _
                            lngButtonWidth)
  END IF
  '
  ' build the dialog  - sized to fit in the buttons
  ' %WS_SYSMENU can be added at design time
  ' (to the style& settings) to give a X control box on the dialog
  ' - but this should be removed prior to release - as it would
  ' give user a way of exiting the dialog
  ' without clicking on a button.

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
                     lngDialogWidth-40,lngTextHeight, _
                     %SS_NOPREFIX
  ' now work out its height to determine the buton starting position
  CONTROL GET SIZE hDlg, 2000 TO lngTextWidth, lngTextHeight
  '
  ' now reset the starting Y position of the buttons
  lngStartY = lngTextHeight
  '
  ' and resize the dialog to accomodate this
  lngDialogHeight=lngStartY + lngButtonHeight + 5
  '
  ' now add the icon
  ' first set the icon to be used
  SELECT CASE lngIcon
    CASE %PBCritical
    ' exclamation
      CONTROL ADD IMAGE, hDlg,2010, "PBCritical",5,5,30,30
    CASE %PBInformation
    ' stop
      CONTROL ADD IMAGE, hDlg,2010, "PBInformation",5,5,30,30
    CASE %PBQuestion
    ' information
      CONTROL ADD IMAGE, hDlg,2010, "PBQuestion",5,5,30,30
    CASE %PBExclamation
    ' question
      CONTROL ADD IMAGE, hDlg,2010, "PBExclamation",5,5,30,30
    CASE ELSE
    ' default to information
      CONTROL ADD IMAGE, hDlg,2010, "PBInformation",5,5,30,30
  END SELECT
  '
  IF strLocalURL <> "" THEN
  ' a url has been passed
    ghLib = LoadLibrary("riched20.dll") :InitCommonControls
    IF ghLib > 0 THEN
      CONTROL ADD "RichEdit20A" , hDlg, %IDC_Richedit1,"",10,_
          lngStartY,lngDialogWidth-10,30, _
          %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR _
          %ES_MULTILINE OR %ES_READONLY OR %ES_WANTRETURN, %WS_EX_LEFT OR _
          %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
          '
      CONTROL SEND hDlg,%IDC_Richedit1, %EM_SETBKGNDCOLOR, 0, _
                         RGB(239,239,239)
      ' auto detect the URL
      CONTROL SEND hDlg,%IDC_Richedit1, %EM_AutoUrlDetect, %TRUE,0
      ' get read to handle events
      CONTROL SEND hDlg,%IDC_Richedit1, %EM_SETEventMask,0,%ENM_LINK
      '
      CONTROL SET TEXT hDlg,%IDC_Richedit1,strLocalURL
      '
      ' move button start position down a bit
      lngStartY = lngStartY + 30
      lngDialogHeight = lngDialogHeight + 35
    END IF
  END IF
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
      lngStyle = %BS_DEFAULT + %WS_TABSTOP
      ' if so make it default and give it a tabstop
    ELSE
    ' all other buttons
      lngStyle = %WS_TABSTOP   ' just a tabstop
    END IF
    '
    CONTROL ADD BUTTON, hDlg,lngStarterHandle, _
                        strButtonName,lngBeginX, _
                        lngStartY, _
                        lngButtonWidth, _
                        lngButtonHeight,lngStyle
                        ' add the button
    INCR lngButtonCounter
    ' advance the button completed counter
    lngBeginX=lngBeginX + lngButtonWidth + lngButtonSeparation
    ' recalculate the next buttons position
  LOOP UNTIL lngButtonCounter > lngParseCount
  ' loop if there is another button
  '
  CALL CentreWindow(hDlg)   ' centre the dialog on the screen
  '
  ' resize the dialog based on the contents
  DIALOG SET SIZE hDlg, lngDialogWidth, lngDialogHeight+15
  '
  IF lngDefaultButton>0 THEN
  ' set the focus to the default button
    CONTROL SET FOCUS hDlg,(1000 + lngDefaultButton)
    ' and give it a black border
    CONTROL SEND hDlg, (1000 + lngDefaultButton), _
                 %BM_SETSTYLE, _
                 %BS_DEFPUSHBUTTON, %TRUE
  END IF
  '
  DIALOG SHOW MODAL hDlg,CALL PBMsgboxHandler TO lngResult
  '
  IF lngDefaultButton=0 AND lngResult=1 THEN
  ' There is no set default and return has been pressed
    GOTO DialogStart   ' display the dialog again
  END IF
  '
  IF lngResult>1000 THEN
  ' result is a handle (as they started at 1000)
  ' so take off the Starter handle number to determine the button
    lngResult= lngResult-1000
  ELSE
    lngResult = lngDefaultButton
    ' otherwise it is set to the default button
  END IF
  '
  strButtonName=PBRemoveString(TRIM$(PARSE$(strButtons, ANY "|",lngResult)),"&")
  '
  FUNCTION = strButtonName      ' pass back the button name clicked on
  '
END FUNCTION
'
CALLBACK FUNCTION PBMsgboxHandler()
' handle any events that happen inside the message box
  LOCAL lngMsg AS LONG
  LOCAL lpNmhDRPrt AS NMHDR PTR
  '
  SELECT CASE CB.MSG
     '
     CASE %WM_DESTROY
     ' form is being unloaded
       IF ghLib <> 0 THEN
        ' FreeLibrary ghLib
       END IF
     '
     CASE %WM_NOTIFY
      ' process notifications
        lpNmhDRPrt = CB.LPARAM ' get a pointer to the NMHDR structure
        IF @lpNmhDRPrt.idfrom = %IDC_RichEdit1 THEN
          SELECT CASE @lpNmhDRPrt.code
            CASE %EN_Link
              FUNCTION = funRichEd_HyperLink_HandleURL _
                                   (CB.HNDL,CB.LPARAM,%IDC_RichEdit1)
              EXIT FUNCTION
          END SELECT
        END IF
        '
     CASE %WM_COMMAND
     ' handle the commands
       IF CB.CTLMSG = %BN_CLICKED THEN   ' if button has been clicked on
       ' then end the dialog
         lngMsg = CB.CTL               ' pick up the control number you allocated to this button
         '                             ' or pass back 1 if just return was pressed
         DIALOG END CB.HNDL, lngMsg    ' close the dialog with the number of the button clicked on
       END IF
      '
     CASE ELSE
     ' handle anything else
       FUNCTION = 0
  END SELECT
'
END FUNCTION
'
SUB subReCentreButtons(lngParseCount AS LONG,lngStartX AS LONG, _
                       lngButtonSeparation AS LONG, _
                       lngButtonWidth AS LONG)
' recentre the buttons on the newly sized dialog
' this function doesn't actually do the recentering but works out the coordinates required
  SELECT CASE lngParseCount
    CASE 1
    ' single button - so centre button on the dialog
       lngStartx=(lngDialogWidth\2)-(lngButtonWidth\2)
    CASE 2
    ' two buttons - so centre buttons on the dialog
       lngStartX=(lngDialogWidth\4)-(lngButtonWidth\2)
       lngButtonSeparation = (lngDialogWidth\2)-lngButtonWidth
  END SELECT
  '
END SUB
'
FUNCTION PBRemoveString ALIAS "PBRemoveString" (strString AS STRING, _
                        strCharacter AS STRING) EXPORT AS STRING
' take a string in and remove all occurances of a character from it
  FUNCTION = REMOVE$(strString,strCharacter)
END FUNCTION
'
SUB CentreWindow(BYVAL hWnd AS LONG)
' centre the window or dialog given its handle
  LOCAL WndRect AS RECT
  LOCAL x       AS LONG
  LOCAL y       AS LONG

  GetWindowRect hWnd, WndRect   ' get the size of the window or dialog in WndRect structure
  ' work out the screen size , the window size and where it should be positioned
  x = (GetSystemMetrics(%SM_CXSCREEN)-(WndRect.nRight-WndRect.nLeft))\2
  y = (GetSystemMetrics(%SM_CYSCREEN)-(WndRect.nBottom-WndRect.nTop+GetSystemMetrics(%SM_CYCAPTION)))\2

  SetWindowPos hWnd, %NULL, x, y, 0, 0, %SWP_NOSIZE OR %SWP_NOZORDER    ' move the window or dialog into position
  '
END SUB
