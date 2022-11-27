#COMPILE EXE
#DIM ALL

#INCLUDE "rmchart.inc"
#INCLUDE "win32api.inc"
#INCLUDE "comdlg32.inc"
#INCLUDE ONCE "PB_FileHandlingRoutines.inc"
#INCLUDE ONCE "PB_RMCHART_extensions.inc"

%ID_RMC1   = %WM_USER + 1024
%ID_CLOSE  = %ID_RMC1 + 1
%ID_EXPORT = %ID_CLOSE + 1
%ID_PRINT  = %ID_EXPORT + 1
%DLGSTYLE  = %DS_CENTER OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_THICKFRAME
'
%IDC_lvDataGrid = %ID_PRINT + 1  ' handle for list view
'
ENUM lv
  LEFT = 0
  RIGHT
  Center
END ENUM
'
DECLARE FUNCTION ShowDialogRMC(BYVAL LONG,BYVAL LONG,BYVAL LONG) AS LONG
DECLARE CALLBACK FUNCTION ShowDialogRMCCallback
DECLARE SUB DoTheChart(BYVAL LONG)
DECLARE SUB ExportTheChart(BYVAL LONG, BYVAL LONG)
'
GLOBAL myTime AS IPOWERTIME      ' set up a global time
'
%ID_Timer1 = 100                 ' handle for timer
'
GLOBAL a_dblIncidents() AS DOUBLE ' arrays for hourly
GLOBAL a_dblRequests() AS DOUBLE  ' incidents & requests
'
GLOBAL a_dblIncidentData() AS DOUBLE ' array for incident Pie chart
GLOBAL a_dblRequestData() AS DOUBLE ' array for request Pie chart
'
FUNCTION PBMAIN()
  ' set the time variable
  LET myTime = CLASS "PowerTime"
  myTime.Now
  '
  RANDOMIZE TIMER  ' seed for random numbers
  '
  DIM a_dblIncidents(12) AS DOUBLE
  DIM a_dblRequests(12)  AS DOUBLE
  '
  ShowDialogRMC 0, 653, 468
END FUNCTION

FUNCTION ShowDialogRMC(BYVAL hParent AS LONG, BYVAL nDlgWidth AS LONG, BYVAL nDlgHeight AS LONG) AS LONG
    LOCAL hDlg      AS LONG
    LOCAL nWidth    AS LONG
    LOCAL nHeight   AS LONG

    nWidth  = MAX(170,nDlgWidth)
    nHeight = MAX(30,nDlgHeight)
    DIALOG NEW hParent,"RMC Test",10,10,nWidth,nHeight, %DLGSTYLE,, TO hDlg
    CONTROL ADD BUTTON, hDlg, %ID_EXPORT,"&Save Image",(nWidth/2) - 85,nHeight-20,50,15
    CONTROL ADD BUTTON, hDlg, %ID_PRINT,"&Print",(nWidth/2) - 25,nHeight-20,50,15
    CONTROL ADD BUTTON, hDlg, %ID_CLOSE, "&Close",(nWidth/2) + 35,nHeight-20,50,15
    CONTROL SET FOCUS hDlg, %ID_CLOSE

    DoTheChart hDlg
    '
    LOCAL aWatermark AS ASCIIZ * 24
    LOCAL lngColour,lngLucentValue AS LONG
    LOCAL lngAlignment,lngFontSize AS LONG
    '
    aWatermark = "GSFsoftware" & $CRLF & "demo"
    lngColour = %ColorBlack ' Color for the watermark
    lngLucentValue = 10     ' Lucent factor between
                            ' 1(=not visible) and 255(=opaque)
    lngAlignment = %RMC_TEXTCENTER ' alignment of the watermark
    lngFontSize = 0         ' Fontsize; if 0: maximum size is used
    ' set a watermark
    RMC_SetWatermark(aWatermark,lngColour, _
                     lngLucentValue,lngAlignment, _
                     lngFontSize)
    '
    ' set a background image
    RMC_SetCtrlStyle(%ID_RMC1,%RMC_CTRLSTYLEIMAGE)
    RMC_SetCtrlBGImage(%ID_RMC1,"seasky.jpg")
    '
    RMC_Draw %ID_RMC1
    '
    DIALOG SHOW MODAL hDlg CALL ShowDialogRMCCallback
END FUNCTION


SUB ShowInfo(TINFO AS tRMC_INFO)
    ' Is called from the Callback ShowDialogRMCCallback() every time you click with Ctrl+Left mousebutton onto the chart
    LOCAL sInfo AS STRING
    LOCAL sTest AS STRING

    sInfo = sInfo + "Info about the mousepointer:"+$CRLF
    sInfo = sInfo + "------------------------------"+$CRLF
    sInfo = sInfo + "X position: "+$TAB+STR$(TINFO.nXPos)+$CRLF _
                  + "Y position: "+$TAB+STR$(TINFO.nYPos)
    IF TINFO.nRegionIndex > 0 THEN
        sInfo = sInfo + $CRLF + $CRLF + "Info about the region:"+$CRLF
        sInfo = sInfo + "------------------------------"+$CRLF
        sInfo = sInfo + "Regionindex:"+$TAB+STR$(TINFO.nRegionIndex)+$CRLF _
                      + "Left position:" +$TAB+STR$(TINFO.nRLeft)+$CRLF _
                      + "Top position:"+$TAB+STR$(TINFO.nRTop)+$CRLF _
                      + "Right position:"+$TAB+STR$(TINFO.nRRight)+$CRLF _
                      + "Bottom position:"+$TAB+STR$(TINFO.nRBottom)
    END IF
    IF TINFO.nDataIndex < 0 THEN ' Special case: this is a CustomObject
      sInfo = sInfo + $CRLF + $CRLF + "Info about the CustomObject:"+$CRLF
      sInfo = sInfo + "------------------------------"+$CRLF
      sInfo = sInfo + "Index:"+$TAB+$TAB+STR$(ABS(TINFO.nDataIndex))+$CRLF _
                    + "Type:" +$TAB+$TAB+CHOOSE$(TINFO.nChartType,"Text","Line","Box","Circle","Polyline","Image","Symbol","Polygon")+$CRLF _
                    + "Left position:" +$TAB+STR$(TINFO.nSLeft)+$CRLF _
                    + "Top position:"+$TAB+STR$(TINFO.nSTop)+$CRLF _
                    + "Right position:"+$TAB+STR$(TINFO.nSRight)+$CRLF _
                    + "Bottom position:"+$TAB+STR$(TINFO.nSBottom)
    END IF
    IF TINFO.nGLeft + TINFO.nGRight > 0 THEN
        sInfo = sInfo + $CRLF + $CRLF + "Info about the grid:"+$CRLF
        sInfo = sInfo + "------------------------------"+$CRLF
        sInfo = sInfo + "Left position:" +$TAB+STR$(TINFO.nGLeft)+$CRLF _
                      + "Top position:"+$TAB+STR$(TINFO.nGTop)+$CRLF _
                      + "Right position:"+$TAB+STR$(TINFO.nGRight)+$CRLF _
                      + "Bottom position:"+$TAB+STR$(TINFO.nGBottom)+$CRLF
        IF TINFO.nGCol > 0 THEN
            SELECT CASE TINFO.nChartType
                CASE %RMC_BARSINGLE TO %RMC_HIGHLOW
                    sInfo = sInfo + "Column:" +$TAB+$TAB+STR$(TINFO.nGCol)+$CRLF _
                                  + "Row:" +$TAB+$TAB+STR$(TINFO.nGRow)
                CASE %RMC_XYCHART
                    sInfo = sInfo + "Sector-index of 1. axes pair:" +$TAB+STR$(TINFO.nGCol)
                    IF TINFO.nGRow > 0 THEN
                        sInfo = sInfo + $CRLF+"Sector-index of 2. axes pair:" +$TAB+STR$(TINFO.nGRow)
                    END IF
            END SELECT
        END IF
    END IF
    IF TINFO.nSeriesIndex > 0 THEN
        sInfo = sInfo + $CRLF + $CRLF + "Info about the series:"+$CRLF
        sInfo = sInfo + "------------------------------"+$CRLF
        sInfo = sInfo + "Seriesindex:" +$TAB+STR$(TINFO.nSeriesIndex)+$CRLF
        sInfo = sInfo + "Dataindex:" +$TAB+STR$(TINFO.nDataIndex)+$CRLF
        IF TINFO.nChartType = %RMC_GRIDLESS THEN
        ELSE
            sInfo = sInfo + "Left position:" +$TAB+STR$(TINFO.nSLeft)+$CRLF _
                          + "Top position:"+$TAB+STR$(TINFO.nSTop)+$CRLF _
                          + "Right position:"+$TAB+STR$(TINFO.nSRight)+$CRLF _
                          + "Bottom position:"+$TAB+STR$(TINFO.nSBottom)+$CRLF
            IF TINFO.nChartType = %RMC_HIGHLOW THEN
                sInfo = sInfo + "Y-pos. Open point:" +$TAB+STR$(TINFO.nSTop2)+$CRLF _
                              + "Y-pos. Close point:"+$TAB+STR$(TINFO.nSBottom2)+$CRLF
            END IF
        END IF
        SELECT CASE TINFO.nChartType
            CASE %RMC_BARSINGLE,%RMC_BARGROUP,%RMC_LINE,%RMC_AREA,%RMC_VOLUMEBAR,%RMC_AREA_STACKED
                sInfo = sInfo + "Data value:" +$TAB+FORMAT$(TINFO.nData1,"0.00")+$CRLF
            CASE %RMC_FLOATINGBAR,%RMC_FLOATINGBARGROUP
                sInfo = sInfo + "Starting data:" +$TAB+FORMAT$(TINFO.nData1,"0.00")+$CRLF
                sInfo = sInfo + "Length data:" +$TAB+FORMAT$(TINFO.nData2,"0.00")+$CRLF
            CASE %RMC_BARSTACKED,%RMC_BARSTACKED100,%RMC_LINE_INDEXED,%RMC_AREA_INDEXED,%RMC_GRIDLESS,%RMC_AREA_STACKED100
                sInfo = sInfo + "Absolut data value:" +$TAB+FORMAT$(TINFO.nData1,"0.00")+$CRLF
                sInfo = sInfo + "Percent data value:" +$TAB+FORMAT$(TINFO.nData2,"0.00")+$CRLF
            CASE %RMC_XYCHART
                sInfo = sInfo + "X-data value:" +$TAB+FORMAT$(TINFO.nData1,"0.00")+$CRLF
                sInfo = sInfo + "Y-data value:" +$TAB+FORMAT$(TINFO.nData2,"0.00")+$CRLF
            CASE %RMC_HIGHLOW
                sInfo = sInfo + "Open data:" +$TAB+FORMAT$(TINFO.nData1,"0.00")+$CRLF
                sInfo = sInfo + "High data:" +$TAB+FORMAT$(TINFO.nData2,"0.00")+$CRLF
                sInfo = sInfo + "Low data:" +$TAB+FORMAT$(TINFO.nData3,"0.00")+$CRLF
                sInfo = sInfo + "Close data:" +$TAB+FORMAT$(TINFO.nData4,"0.00")+$CRLF
        END SELECT
    END IF
    IF TINFO.nGLeft + TINFO.nGRight > 0 THEN
        sInfo = sInfo + $CRLF + $CRLF + "Data value, which is correspondent"+$CRLF _
                                      +  "to this X/Y location:"+$CRLF
        sInfo = sInfo + "------------------------------"+$CRLF
        IF TINFO.nChartType = %RMC_XYCHART THEN
            sInfo = sInfo + "X-data value of 1. axes pair: " +$TAB+FORMAT$(TINFO.nVirtData1,"0.00")+$CRLF
            sInfo = sInfo + "Y-data value of 1. axes pair: " +$TAB+FORMAT$(TINFO.nVirtData2,"0.00")+$CRLF
            IF TINFO.nVirtData3 <> 0 AND TINFO.nVirtData4 <> 0 THEN
                sInfo = sInfo + "X-data value of 2. axes pair: " +$TAB+FORMAT$(TINFO.nVirtData3,"0.00")+$CRLF
                sInfo = sInfo + "Y-data value of 2. axes pair: " +$TAB+FORMAT$(TINFO.nVirtData4,"0.00")+$CRLF
            END IF
        ELSE
            sInfo = sInfo + "Data value of the 1. data-axis:" +$TAB+FORMAT$(TINFO.nVirtData1,"0.00")+$CRLF
            IF TINFO.nVirtData2 <> 0 THEN
                sInfo = sInfo + "Data value of the 2. data-axis:" +$TAB+FORMAT$(TINFO.nVirtData2,"0.00")+$CRLF
            END IF
        END IF
    END IF
    MSGBOX sInfo,,"RMChart"
END SUB

CALLBACK FUNCTION ShowDialogRMCCallback
    LOCAL hDC&, nResult&, x&, y&
    LOCAL TINFO AS tRMC_INFO POINTER
    LOCAL tRect AS RECT
    STATIC z&,nC&,nCtlW&,nCtlH&
    '
    STATIC idEvent AS LONG ' timer event
    STATIC lngHour AS LONG ' current hour
    '
    LOCAL lngRegion AS LONG  ' region of chart
    LOCAL lngSlice AS LONG   ' pie slice number
    LOCAL lngValue AS LONG   ' data in the pie slice
    '
    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
        ' <- sent right before the dialog is displayed.
        ' Create WM_TIMER events with the SetTimer API
        ' at 3000 ms (3sec) intervals
          idEvent = SetTimer(CB.HNDL, %ID_TIMER1, _
                           3000, BYVAL %NULL)
          lngHour = 7  ' set initially at 7am
          '
        CASE %WM_TIMER
          ' Posted by the created timer
          IF CB.WPARAM = %ID_TIMER1 THEN
          ' Make sure it's corrent timer id
          ' regenerate the data files
            funRegenerateData(lngHour)
            '
            IF lngHour = 20 THEN
            ' end of day , stop the timer
              KillTimer(CB.HNDL,%ID_TIMER1)
            END IF
            '
          END IF
        '
        CASE %WM_SIZE
            INCR nC
            IF nC < 3 THEN
                nCtlW = LOWRD(CBLPARAM) : nCtlH = HIWRD(CBLPARAM)
                EXIT FUNCTION
            END IF
           ' uncomment the next line for resizing the control:
            RMC_SetCtrlSize %ID_RMC1, LOWRD(CBLPARAM)-nCtlW,HIWRD(CBLPARAM)-nCtlH,1 ' set control's size relative to the former size
            nCtlW = LOWRD(CBLPARAM) : nCtlH = HIWRD(CBLPARAM)  ' set former Width and former Height for the next resize
        CASE %WM_RBUTTONDOWN
            MSGBOX "X-Pos in the dialog:"+STR$(LOWRD(CBLPARAM))+$CRLF+"Y-Pos in the dialog:"+STR$(HIWRD(CBLPARAM))
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %ID_EXPORT
                    ExportTheChart CBHNDL, %ID_RMC1
                CASE %ID_PRINT
                    nResult = PrinterDialog(CBHNDL,%PD_RETURNDC,hDC,1,1,1,1,1)
                    IF ISTRUE(nResult) THEN
                        DIALOG REDRAW CBHNDL
                        RMC_Draw2Printer %ID_RMC1, hDC
                   END IF
                CASE %ID_CLOSE
                    DIALOG END CBHNDL
                CASE %ID_RMC1                     ' message from RMChart
                    SELECT CASE CBCTLMSG
                        CASE %RMC_LBUTTONDOWN
                            z = 1                 ' flag for left mousebutton pressed
                        CASE %RMC_LBUTTONUP
                            z = 0                 ' reset the flag
                        CASE %RMC_CTRLLBUTTONDOWN
                            TINFO = CB.LPARAM      ' lParam holds a pointer to a tRMC_INFO structure
                            'ShowInfo @TINFO       ' Show the content of this structure
                            '
                            ' handle click on region
                            lngRegion = @TINFO.nRegionIndex
                            lngSlice  = @TINFO.nDataIndex
                            lngValue  = @TINFO.nData1
                            '
                            SELECT CASE lngRegion
                              CASE 1
                              ' region 1
                                ShowListView CB.HNDL,lngSlice,lngValue
                            END SELECT
                            '
                        CASE %RMC_MOUSEMOVE
                            TINFO = CBLPARAM      ' lParam holds a pointer to a tRMC_INFO structure
                            IF z THEN             ' if left mousebutton is pressed
                            ' uncomment the next line for moving the control with left mouse button:
                            '   RMC_SetCtrlpos %ID_RMC1,@TINFO.nXMove,@TINFO.nYMove,1 ' move the control
                            END IF
                    END SELECT
            END SELECT
    END SELECT
END FUNCTION


' *************** This is the chart creating part of the source ***************
SUB DoTheChart(BYVAL hParentDlg AS LONG)
    LOCAL i AS LONG
    LOCAL nC AS LONG
    LOCAL nDataCount AS LONG
    LOCAL nRetVal AS LONG
    LOCAL sTemp AS STRING
    LOCAL szTemp AS ASCIIZ * 2000
    REDIM aData(0) AS DOUBLE
    REDIM aData2(0) AS DOUBLE
    REDIM aPPC(0) AS LONG
    REDIM aColor(0) AS LONG
    LOCAL tChart AS tRMC_CHART
    LOCAL tRegion AS tRMC_REGION
    LOCAL tCaption AS tRMC_CAPTION
    LOCAL tLegend AS tRMC_LEGEND
    LOCAL tGrid AS tRMC_GRID
    LOCAL tDataAxis AS tRMC_DATAAXIS
    LOCAL tLabelAxis AS tRMC_LABELAXIS
    LOCAL tBarSeries AS tRMC_BARSERIES
    LOCAL tLineSeries AS tRMC_LINESERIES
    LOCAL tGridlessSeries AS tRMC_GRIDLESSSERIES
    LOCAL tXYAxis AS tRMC_XYAXIS
    LOCAL tXYSeries AS tRMC_XYSERIES


    '************** Create the chart **********************
    tChart.nLeft        = 10
    tChart.nTop         = 10
    tChart.nWidth       = 920
    tChart.nHeight      = 700
    tChart.nBackColor   = %ColorDefault
    tChart.nCtrlStyle   = %RMC_CTRLSTYLEFLATSHADOW
    tChart.sBgImage     = ""
    tChart.sFontName    = "Tahoma"
    tChart.nToolTipWidth= 0
    tChart.nBitmapBKColor= %ColorDefault
    nRetVal = RMC_CreateChartI(hParentDlg, %ID_RMC1, tChart)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Region 1 *****************************
    tRegion.nLeft       = 5
    tRegion.nTop        = 5
    tRegion.nWidth      = 440
    tRegion.nHeight     = 420
    tRegion.sFooter     = "Created " & myTime.DateStringLong
    tRegion.nShowBorder = %FALSE
    nRetVal = RMC_AddRegionI(%ID_RMC1, tRegion)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add caption to region 1 *******************
    tCaption.sText  =     "Incidents per Division"
    tCaption.nBackColor = %ColorDefault
    tCaption.nTextColor = %ColorDefault
    tCaption.nFontSize  = 15
    tCaption.nIsBold    = %TRUE
    nRetVal = RMC_AddCaptionI(%ID_RMC1, 1, tCaption)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add legend to region 1 *******************************
    tLegend.nLegendAlign    = %RMC_LEGEND_BOTTOM
    tLegend.nLegendBackColor= %ColorGhostWhite
    tLegend.nLegendStyle    = %RMC_LEGENDRECT
    tLegend.nLegendTextColor= %ColorDefault
    tLegend.nLegendFontSize = 8
    tLegend.nLegendIsBold   = %FALSE
    'szTemp = "Marketing*Logistics*Facilities*Human Resources"
    szTemp = funGetDivisionNames("Incidents.csv")
    '
    nRetVal = RMC_AddLegendI(%ID_RMC1, 1, szTemp, tLegend)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Series 1 to region 1 *******************************
    tGridlessSeries.nStyle              = %RMC_PIE_3D_GRADIENT
    tGridlessSeries.nPieAlignment       = %RMC_FULL
    tGridlessSeries.nExplodemode        = -2
    tGridlessSeries.nIsLucent           = %TRUE
    tGridlessSeries.nValueLabelOn       = %RMC_VLABEL_TWIN
    tGridlessSeries.nHatchMode          = %RMC_HATCHBRUSH_OFF
    tGridlessSeries.nStartAngle         = 0
    '****** Read data values ******
    'REDIM aData(3)
    'aData(0) = 10 : aData(1) = 12 : aData(2) = 15 : aData(3) = 5
    ' populate the array with the data to be used in chart
    funGetDivisionValues("Incidents.csv",a_dblIncidentData())
    '
    nRetVal = RMC_AddGridlessSeriesI(%ID_RMC1,1, a_dblIncidentData(0), _
                                     UBOUND(a_dblIncidentData), _
                                     0,0, tGridlessSeries)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Region 2 *****************************
    tRegion.nLeft       = 450
    tRegion.nTop        = 5
    tRegion.nWidth      = 440
    tRegion.nHeight     = 420
    tRegion.sFooter     = "Created " & myTime.DateStringLong
    tRegion.nShowBorder = %FALSE
    nRetVal = RMC_AddRegionI(%ID_RMC1, tRegion)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add caption to region 2 *******************
    tCaption.sText  =     "Requests per Division"
    tCaption.nBackColor = %ColorDefault
    tCaption.nTextColor = %ColorDefault
    tCaption.nFontSize  = 15
    tCaption.nIsBold    = %TRUE
    nRetVal = RMC_AddCaptionI(%ID_RMC1, 2, tCaption)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add legend to region 2 *******************************
    tLegend.nLegendAlign    = %RMC_LEGEND_BOTTOM
    tLegend.nLegendBackColor= %ColorGhostWhite
    tLegend.nLegendStyle    = %RMC_LEGENDRECT
    tLegend.nLegendTextColor= %ColorDefault
    tLegend.nLegendFontSize = 8
    tLegend.nLegendIsBold   = %FALSE
    'szTemp = "Marketing*Logistics*Facilities*Human Resources"
    szTemp = funGetDivisionNames("Requests.csv")
    '
    nRetVal = RMC_AddLegendI(%ID_RMC1, 2, szTemp, tLegend)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Series 1 to region 2 *******************************
    tGridlessSeries.nStyle              = %RMC_PIE_3D_GRADIENT
    tGridlessSeries.nPieAlignment       = %RMC_FULL
    tGridlessSeries.nExplodemode        = -2
    tGridlessSeries.nIsLucent           = %TRUE
    tGridlessSeries.nValueLabelOn       = %RMC_VLABEL_TWIN
    tGridlessSeries.nHatchMode          = %RMC_HATCHBRUSH_OFF
    tGridlessSeries.nStartAngle         = 0
    '****** Read color values ******
    'Redim aColor(3)
    'aColor(0) = %ColorRed
    'aColor(1) = %ColorSienna
    'aColor(2) = %ColorDarkOrchid
    'aColor(3) = %ColorPlum
    '****** Read data values ******
    'REDIM aData(3)
    'aData(0) = 15 : aData(1) = 4 : aData(2) = 23 : aData(3) = 10
    funGetDivisionValues("Requests.csv",aData())
    'funGetRandomColours(aColor(),ubound(aData()),%ColorPlum)
    funGetFixedColours(aColor(),UBOUND(aData()), _
                       EXE.PATH$ & "SomeColours.txt")
    '
    nRetVal = RMC_AddGridlessSeriesI(%ID_RMC1,2, aData(0), UBOUND(aData), _
                                     aColor(0),UBOUND(aColor), tGridlessSeries)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Region 3 *****************************
    tRegion.nLeft       = 5
    tRegion.nTop        = 445
    tRegion.nWidth      = -5
    tRegion.nHeight     = -5
    tRegion.sFooter     = ""
    tRegion.nShowBorder = %FALSE
    nRetVal = RMC_AddRegionI(%ID_RMC1, tRegion)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add caption to region 3 *******************
    tCaption.sText  =     "Incidents and Requests per hour"
    tCaption.nBackColor = %ColorDefault
    tCaption.nTextColor = %ColorDefault
    tCaption.nFontSize  = 10
    tCaption.nIsBold    = %TRUE
    nRetVal = RMC_AddCaptionI(%ID_RMC1, 3, tCaption)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add grid to region 3 *****************************
    tGrid.nGridBackColor = %ColorDefault
    tGrid.nAsGradient    = %TRUE
    tGrid.nBicolor       = %RMC_BICOLOR_BOTH
    tGrid.nLeft          = 0
    tGrid.nTop           = 0
    tGrid.nWidth         = 0
    tGrid.nHeight        = 0
    nRetVal = RMC_AddGridI(%ID_RMC1, 3, tGrid)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add data axis to region 3 *****************************
    tDataAxis.nAlignment      = %RMC_DATAAXISLEFT
    tDataAxis.nMinValue       = 0
    tDataAxis.nMaxValue       = 0
    tDataAxis.nTickCount      = 11
    tDataAxis.nFontsize       = 8
    tDataAxis.nTextColor      = %ColorDefault
    tDataAxis.nLineColor      = %ColorDefault
    tDataAxis.nLineStyle      = %RMC_LINESTYLESOLID
    tDataAxis.nDecimalDigits  = 0
    tDataAxis.sUnit           = ""
    tDataAxis.sText           = ""
    nRetVal = RMC_AddDataAxisI(%ID_RMC1, 3, tDataAxis)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add label axis to region 3 *****************************
    tLabelAxis.nCount         = 1
    tLabelAxis.nTickCount     = 13
    tLabelAxis.nAlignment     = %RMC_LABELAXISBOTTOM
    tLabelAxis.nFontsize      = 8
    tLabelAxis.nTextColor     = %ColorDefault
    tLabelAxis.nTextAlignment = %RMC_TEXTCENTER
    tLabelAxis.nLineColor     = %ColorDefault
    tLabelAxis.nLineStyle     = %RMC_LINESTYLESOLID
    tLabelAxis.sText          = ""
    szTemp = "8am*9am*10am*11am*12 noon*1pm*2pm*3pm*4pm*5pm*6pm*7pm*8pm"
    nRetVal = RMC_AddLabelAxisI(%ID_RMC1, 3, szTemp, tLabelAxis)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add legend to region 3 *******************************
    tLegend.nLegendAlign    = %RMC_LEGEND_BOTTOM
    tLegend.nLegendBackColor= %ColorGhostWhite
    tLegend.nLegendStyle    = %RMC_LEGENDRECT
    tLegend.nLegendTextColor= %ColorDefault
    tLegend.nLegendFontSize = 8
    tLegend.nLegendIsBold   = %FALSE
    szTemp = "Incidents*Requests"
    nRetVal = RMC_AddLegendI(%ID_RMC1, 3, szTemp, tLegend)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Series 1 to region 3 *******************************
    tLineSeries.nType             = %RMC_LINE
    tLineSeries.nStyle            = %RMC_LINE_CABLE_SHADOW
   ' tLineSeries.nLineStyle        = %RMC_LSTYLE_LINE
    tLineSeries.nLineStyle        = %RMC_LSTYLE_SPLINE
    tLineSeries.nIsLucent         = %FALSE
    tLineSeries.nColor            = %ColorDarkBlue
    tLineSeries.nSeriesSymbol     = %RMC_SYMBOL_BULLET
    tLineSeries.nWhichDataAxis    = 1
    tLineSeries.nValueLabelOn     = %RMC_VLABEL_NONE
    tLineSeries.nHatchMode        = %RMC_HATCHBRUSH_OFF
    '****** Read data values ******
    REDIM aData(12)
    'aData(0) = 1 : aData(1) = 4 : aData(2) = 3 : aData(3) = 5 : aData(4) = 6
    'aData(5) = 10 : aData(6) = 1 : aData(7) = 1 : aData(8) = 2 : aData(9) = 3
    'aData(10) = 7 : aData(11) = 4 : aData(12) = 1

    nRetVal = RMC_AddLineSeriesI(%ID_RMC1, 3, aData(0), 13,0,0, tLineSeries)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Series 2 to region 3 *******************************
    tLineSeries.nType             = %RMC_LINE
    tLineSeries.nStyle            = %RMC_LINE_CABLE
    tLineSeries.nLineStyle        = %RMC_LSTYLE_LINE
    tLineSeries.nIsLucent         = %FALSE
    tLineSeries.nColor            = %ColorCrimson
    tLineSeries.nSeriesSymbol     = %RMC_SYMBOL_BULLET
    tLineSeries.nWhichDataAxis    = 1
    tLineSeries.nValueLabelOn     = %RMC_VLABEL_NONE
    tLineSeries.nHatchMode        = %RMC_HATCHBRUSH_OFF
    '****** Read data values ******
    REDIM aData(12)
    'aData(0) = 5 : aData(1) = 7 : aData(2) = 2 : aData(3) = 6 : aData(4) = 8
    'aData(5) = 10 : aData(6) = 12 : aData(7) = 12 : aData(8) = 7 : aData(9) = 7
    'aData(10) = 8 : aData(11) = 6 : aData(12) = 5
    nRetVal = RMC_AddLineSeriesI(%ID_RMC1, 3, aData(0), 13,0,0, tLineSeries)
    IF nRetVal < 0 THEN GOTO IsError
    '
     '************** Add CustomObjects *******************************
    DIM aXPos(0) AS LONG   ' Set up the arrays for the polygons
    DIM aYPos(0) AS LONG
    szTemp = "Some text"
    nRetVal = RMC_COText(%ID_RMC1, 1, szTemp,  90,  180,  200,  0, %RMC_BOX_3D_SHADOW, %ColorYellow, %ColorDefault,  100, %RMC_LINE_HORIZONTAL, %ColorDefault, "24BC")
    IF nRetVal < 0 THEN GOTO IsError
    nRetVal = RMC_COImage(%ID_RMC1, 2, "dashboard.jpg",  350,  300,  100,  0)
    IF nRetVal < 0 THEN GOTO IsError
    REDIM aXPos(2)
    aXPos(0) = 10 : aXPos(1) = 40 : aXPos(2) = 60
    REDIM aYPos(2)
    aYPos(0) = 20 : aYPos(1) = 120 : aYPos(2) = 50
    nRetVal = RMC_COPolygon(%ID_RMC1, 3, aXPos(0), aYPos(0), 3, %ColorYellowGreen, %ColorDefault, %TRUE,  0)
    IF nRetVal < 0 THEN GOTO IsError
    nRetVal = RMC_COSymbol(%ID_RMC1, 5,  500,  500, %RMC_SYMBOL_BULLET, %ColorDefault)
    IF nRetVal < 0 THEN GOTO IsError
    nRetVal = RMC_COCircle(%ID_RMC1, 6,  400,  300,  50, %RMC_CIRCLE_BULLET, %ColorDefault, %ColorDefault,  50)
    IF nRetVal < 0 THEN GOTO IsError
    '
    nRetVal = RMC_SetWatermark($RMC_USERWM,%RMC_USERWMCOLOR,%RMC_USERWMLUCENT,%RMC_USERWMALIGN,%RMC_USERFONTSIZE)
    nRetVal = RMC_Draw(%ID_RMC1)
    IF nRetVal < 0 THEN GOTO IsError
    EXIT SUB

    IsError:
END SUB
' *************** End of the chart creating part of the source ***************



SUB ExportTheChart(BYVAL hDlg AS LONG, BYVAL nCtrlID AS LONG)
    LOCAL sFilter AS STRING
    LOCAL nFlags AS LONG
    LOCAL sFileName AS STRING
    LOCAL szFName AS ASCIIZ * 1000
    LOCAL nResult AS LONG

    nFlags = %OFN_FILEMUSTEXIST OR %OFN_PATHMUSTEXIST

    sFilter = "Graphic Files (*.jpg*.png*.emf)" & CHR$(0) & "*.png;*.jpg;*.jpeg;*.emf;*.emf+;" & CHR$(0) & _
              "ALL Files (*.*)" & CHR$(0) & _
              "*.*" & CHR$(0) & CHR$(0)
    nResult = SAVEFILEDIALOG (hDlg,"Export Chart",sFileName,"", sFilter, "png",nFlags)
    IF nResult <> 0 THEN
        szFName = sFileName
        RMC_Draw2File nCtrlID, szFName
    END IF
END SUB
'
FUNCTION funRegenerateData(lngHour AS LONG) AS LONG
' regenerate the data for this hour
  ' increment the hour ?
  LOCAL lngArraySlot AS LONG
  SELECT CASE lngHour
    CASE 7 TO 20
    ' within working day
      INCR lngHour   ' advance the hour
      '
      ' add to arrays
      lngArraySlot = lngHour-8
      ' generate some new random data
      a_dblIncidents(lngArraySlot) = RND(0,10)
      a_dblRequests(lngArraySlot) = RND(0,15)
      '
      ' Set the new data values
      RMC_SetSeriesData %ID_RMC1,3,1, _
                        a_dblIncidents(0),UBOUND(a_dblIncidents)+1
      RMC_SetSeriesData %ID_RMC1,3,2, _
                        a_dblRequests(0),UBOUND(a_dblRequests)+1
                        '
      ' now do a pie chart
      LOCAL lngSlice AS LONG
      '
      ' add random data to the pie chart
      FOR lngSlice = 0 TO UBOUND(a_dblIncidentData)
        a_dblIncidentData(lngSlice)+= RND(0,5)
      NEXT lngSlice
      '
      RMC_SetSeriesData %ID_RMC1,1,1, _
                      a_dblIncidentData(0),UBOUND(a_dblIncidentData)+1
                        '

      ' now redraw the chart control to display these values
      RMC_Draw %ID_RMC1
      '
  END SELECT
  '
END FUNCTION
'
FUNCTION ShowListview(BYVAL hParent AS LONG, _
                      lngSlice AS LONG, _
                      lngValue AS LONG) AS LONG
' display a list view drill down
  LOCAL hDlg    AS LONG
  LOCAL lngRslt AS LONG
  '
  DIALOG NEW hParent, "Drill down to data", 267, 169, 450, 190, %WS_POPUP OR _
        %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
        %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
        '
 CONTROL ADD LISTVIEW,  hDlg, %IDC_lvDataGrid, "", 19, 20, 320, 140, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %WS_TABSTOP OR %LVS_REPORT _
        OR %LVS_SHOWSELALWAYS, %WS_EX_LEFT
        '
 LISTVIEW SET STYLEXX hDlg, %IDC_lvDataGrid, _
                         %LVS_EX_GRIDLINES OR %LVS_EX_FULLROWSELECT
                         '
  LISTVIEW INSERT COLUMN hDlg, %IDC_lvDataGrid, 1, "Division", _
                        105,%lv.Center
  LISTVIEW INSERT COLUMN hDlg, %IDC_lvDataGrid, 2, "Dept", _
                        105,%lv.Center
  LISTVIEW INSERT COLUMN hDlg, %IDC_lvDataGrid, 3, "Ref", _
                        105,%lv.Center
                        '
  ' populate the drill down array
 LOCAL strDivisions AS STRING
 strDivisions = funGetDivisionNames("Incidents.csv")
 '
 ' get the actual division
 LOCAL strDivision AS STRING
 strDivision = PARSE$(strDivisions,"*",lngSlice)
 '
 funPopulateListView(hDlg,%idc_lvDataGrid,strDivision,lngValue)
 '
 '
 DIALOG SHOW MODAL hDlg, CALL ShowListviewProc TO lngRslt
 '
 FUNCTION = lngRslt
 '
END FUNCTION
'
CALLBACK FUNCTION ShowListviewProc()
  LOCAL lplvcd AS nmlvCustomDraw PTR
  LOCAL LVData AS NM_ListView
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    '
    CASE %WM_NCACTIVATE
       STATIC hWndSaveFocus AS DWORD
       IF ISFALSE CB.WPARAM THEN
       ' Save control focus
         hWndSaveFocus = GetFocus()
       ELSEIF hWndSaveFocus THEN
       ' Restore control focus
         SetFocus(hWndSaveFocus)
         hWndSaveFocus = 0
       END IF
       '
    CASE %WM_NOTIFY
      SELECT CASE CB.NMID
      ' code to allow listview to have coloured alternate lines
        CASE %idc_lvDataGrid
          SELECT CASE CB.NMCODE
            CASE %NM_CUSTOMDRAW
              lplvcd = CB.LPARAM
              '
              SELECT CASE @lplvcd.nmcd.dwDrawStage
                CASE %CDDS_PrePaint, %CDDS_ItemPrepaint
                  FUNCTION = %CDRF_NotifyItemDraw
                  '
                CASE %CDDS_ItemPrepaint OR %CDDS_subItem
                ' paint the row?
                  IF ISTRUE funColouredRow(@lpLvCd.nmcd.dwItemSpec) THEN
                  ' set the colours
                    @lpLvCD.clrTextBK = %RGB_PALEGREEN
                    @lpLvCD.clrText = %BLACK
                  ELSE
                    @lpLvCD.clrTextBK = %WHITE
                    @lpLvCD.clrText = %BLACK
                  END IF
              END SELECT
          END SELECT
      END SELECT
  END SELECT
  '
END FUNCTION
'
FUNCTION funColouredRow(lngRow AS LONG) AS LONG
' determine if this row needs coloured or not
  IF lngRow MOD 2 = 0 THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funPopulateListView(hDlg AS DWORD, _
                             lngListView AS LONG, _
                             strDivision AS STRING, _
                             lngRows AS LONG) AS LONG
' populate the list view
  LOCAL lngR AS LONG
  FOR lngR = 1 TO lngRows
    ' add the new row and populate the first column
    LISTVIEW INSERT ITEM hDlg, lngListView, lngR, 0,strDivision
    ' add data to the remaining columns
    LISTVIEW SET TEXT hDlg, lngListView, lngR, 2,"dept details"
    LISTVIEW SET TEXT hDlg, lngListView, lngR, 3,"Ref_" & FORMAT$(lngR)
    '
    NEXT lngR
'
END FUNCTION
