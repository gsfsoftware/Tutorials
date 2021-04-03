#COMPILE EXE
#DIM ALL

#INCLUDE "rmchart.inc"
#INCLUDE "win32api.inc"
#INCLUDE "comdlg32.inc"

%ID_RMC1   = %WM_USER + 1024
%ID_CLOSE  = %ID_RMC1 + 1
%ID_EXPORT = %ID_CLOSE + 1
%ID_PRINT  = %ID_EXPORT + 1
%DLGSTYLE  = %DS_CENTER OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_THICKFRAME

DECLARE FUNCTION ShowDialogRMC(BYVAL LONG,BYVAL LONG,BYVAL LONG) AS LONG
DECLARE CALLBACK FUNCTION ShowDialogRMCCallback
DECLARE SUB DoTheChart(BYVAL LONG)
DECLARE SUB ExportTheChart(BYVAL LONG, BYVAL LONG)
'
GLOBAL aData() AS DOUBLE
GLOBAL aData2() AS DOUBLE
'
FUNCTION PBMAIN()
  RANDOMIZE TIMER
  ShowDialogRMC 0, 820, 314
END FUNCTION

FUNCTION ShowDialogRMC(BYVAL hParent AS LONG, BYVAL nDlgWidth AS LONG, BYVAL nDlgHeight AS LONG) AS LONG
    LOCAL hDlg      AS LONG
    LOCAL nWidth    AS LONG
    LOCAL nHeight   AS LONG

    nWidth  = MAX(170,nDlgWidth)
    nHeight = MAX(30,nDlgHeight)
    DIALOG NEW hParent,"RMC Test",10,10,nWidth,nHeight, %DLGSTYLE,, TO hDlg
    CONTROL ADD BUTTON, hDlg, %ID_EXPORT,"&Save bitmap",(nWidth/2) - 85,nHeight-20,50,15
    CONTROL ADD BUTTON, hDlg, %ID_PRINT,"&Print",(nWidth/2) - 25,nHeight-20,50,15
    CONTROL ADD BUTTON, hDlg, %ID_CLOSE, "&Close",(nWidth/2) + 35,nHeight-20,50,15
    CONTROL SET FOCUS hDlg, %ID_CLOSE

    DoTheChart hDlg

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
    STATIC lngHourCount AS LONG
    STATIC hTimer AS QUAD
    '
    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
        ' time set to trigger every second
          hTimer = SetTimer(CB.HNDL, 1&, 1000&, BYVAL %NULL)
        '
        CASE %WM_TIMER
        ' advance the hour counter
          INCR lngHourCount
          IF lngHourCount < 24 THEN
            funReDrawChart(CB.HNDL,lngHourCount)
          ELSE
            KillTimer CB.HNDL,hTimer
          END IF
        '
        CASE %WM_SIZE
            INCR nC
            IF nC < 3 THEN
                nCtlW = LOWRD(CBLPARAM) : nCtlH = HIWRD(CBLPARAM)
                EXIT FUNCTION
            END IF
           ' uncomment the next line for resizing the control:
           ' RMC_SetCtrlSize %ID_RMC1, LOWRD(CBLPARAM)-nCtlW,HIWRD(CBLPARAM)-nCtlH,1 ' set control's size relative to the former size
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
                            TINFO = CBLPARAM      ' lParam holds a pointer to a tRMC_INFO structure
                            ShowInfo @TINFO       ' Show the content of this structure
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
    tChart.nWidth       = 1200
    tChart.nHeight      = 450
    tChart.nBackColor   = %ColorWhite
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
    tRegion.nWidth      = 800
    tRegion.nHeight     = -5
    tRegion.sFooter     = "Created " & DATE$ & " " & TIME$
    tRegion.nShowBorder = %FALSE
    nRetVal = RMC_AddRegionI(%ID_RMC1, tRegion)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add caption to region 1 *******************
    tCaption.sText  =     "Views per Hour"
    tCaption.nBackColor = %ColorDefault
    tCaption.nTextColor = %ColorDefault
    tCaption.nFontSize  = 16
    tCaption.nIsBold    = %TRUE
    nRetVal = RMC_AddCaptionI(%ID_RMC1, 1, tCaption)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add grid to region 1 *****************************
    tGrid.nGridBackColor = %ColorDefault
    tGrid.nAsGradient    = %TRUE
    tGrid.nBicolor       = %RMC_BICOLOR_NONE
    tGrid.nLeft          = 0
    tGrid.nTop           = 0
    tGrid.nWidth         = 0
    tGrid.nHeight        = 0
    nRetVal = RMC_AddGridI(%ID_RMC1, 1, tGrid)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add data axis to region 1 *****************************
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
    nRetVal = RMC_AddDataAxisI(%ID_RMC1, 1, tDataAxis)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add label axis to region 1 *****************************
    tLabelAxis.nCount         = 1
    tLabelAxis.nTickCount     = 24
    tLabelAxis.nAlignment     = %RMC_LABELAXISBOTTOM
    tLabelAxis.nFontsize      = 8
    tLabelAxis.nTextColor     = %ColorDefault
    tLabelAxis.nTextAlignment = %RMC_TEXTCENTER
    tLabelAxis.nLineColor     = %ColorDefault
    tLabelAxis.nLineStyle     = %RMC_LINESTYLESOLID
    tLabelAxis.sText          = "Hour of day"
    szTemp = "00*01*02*03*04*05*06*07*08*09*10*11*12*13*14*15*16*17*18*19*20*21*22*23"
    nRetVal = RMC_AddLabelAxisI(%ID_RMC1, 1, szTemp, tLabelAxis)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Series 1 to region 1 *******************************
    tLineSeries.nType             = %RMC_LINE
    tLineSeries.nStyle            = %RMC_LINE_FLAT
    tLineSeries.nLineStyle        = %RMC_LSTYLE_SPLINE
    tLineSeries.nIsLucent         = %FALSE
    tLineSeries.nColor            = %ColorRed
    tLineSeries.nSeriesSymbol     = %RMC_SYMBOL_BULLET
    tLineSeries.nWhichDataAxis    = 1
    tLineSeries.nValueLabelOn     = %RMC_VLABEL_DEFAULT
    tLineSeries.nHatchMode        = %RMC_HATCHBRUSH_OFF
    '****** Read data values ******
    REDIM aData(23)
    aData(0) = 34 : aData(1) = 0 : aData(2) = 0 : aData(3) = 0 : aData(4) = 0
    aData(5) = 0 : aData(6) = 0 : aData(7) = 0 : aData(8) = 0 : aData(9) = 0
    aData(10) = 0 : aData(11) = 0 : aData(12) = 0 : aData(13) = 0 : aData(14) = 0
    aData(15) = 0 : aData(16) = 0 : aData(17) = 0 : aData(18) = 0 : aData(19) = 0
    aData(20) = 0 : aData(21) = 0 : aData(22) = 0 : aData(23) = 0
    nRetVal = RMC_AddLineSeriesI(%ID_RMC1, 1, aData(0), 24,0,0, tLineSeries)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Region 2 *****************************
    tRegion.nLeft       = 810
    tRegion.nTop        = 5
    tRegion.nWidth      = -5
    tRegion.nHeight     = -5
    tRegion.sFooter     = ""
    tRegion.nShowBorder = %FALSE
    nRetVal = RMC_AddRegionI(%ID_RMC1, tRegion)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add caption to region 2 *******************
    tCaption.sText  =     "Channels"
    tCaption.nBackColor = %ColorDefault
    tCaption.nTextColor = %ColorDefault
    tCaption.nFontSize  = 16
    tCaption.nIsBold    = %TRUE
    nRetVal = RMC_AddCaptionI(%ID_RMC1, 2, tCaption)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add legend to region 2 *******************************
    tLegend.nLegendAlign    = %RMC_LEGEND_BOTTOM
    tLegend.nLegendBackColor= %ColorWhite
    tLegend.nLegendStyle    = %RMC_LEGENDRECT
    tLegend.nLegendTextColor= %ColorDefault
    tLegend.nLegendFontSize = 8
    tLegend.nLegendIsBold   = %FALSE
    szTemp = "Software*Hardware*Training"
    nRetVal = RMC_AddLegendI(%ID_RMC1, 2, szTemp, tLegend)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add Series 1 to region 2 *******************************
    tGridlessSeries.nStyle              = %RMC_PIE_3D_GRADIENT
    tGridlessSeries.nPieAlignment       = %RMC_FULL
    tGridlessSeries.nExplodemode        = 0
    tGridlessSeries.nIsLucent           = %TRUE
    tGridlessSeries.nValueLabelOn       = %RMC_VLABEL_TWIN
    tGridlessSeries.nHatchMode          = %RMC_HATCHBRUSH_OFF
    tGridlessSeries.nStartAngle         = 0
    '****** Read data values ******
    REDIM aData2(2)
    aData2(0) = 15 : aData2(1) = 10 : aData2(2) = 9
    nRetVal = RMC_AddGridlessSeriesI(%ID_RMC1,2, aData2(0), 3,0,0, tGridlessSeries)
    IF nRetVal < 0 THEN GOTO IsError

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
FUNCTION funReDrawChart(hDlg AS DWORD, _
                        lngHourCount AS LONG) AS LONG
' update the chart with the updated data values
  LOCAL lngSlice AS LONG
  LOCAL lngIncrement AS LONG
  LOCAL zFooter AS ASCIIZ * 255
  '
  zFooter = DATE$ & " " & TIME$
  '
  ' handle the region 1 data
  lngIncrement = RND(-5,5)
  aData(lngHourCount) = aData(lngHourCount - 1) + lngIncrement
  RMC_SetSeriesData %ID_RMC1,1,1,aData(0),UBOUND(aData)+1
  RMC_SetRegionfooter %ID_RMC1,1 zFooter
  '
  ' handle the pie chart - region 2
  lngSlice = RND(0,2)
  aData2(lngSlice) = aData2(lngSlice) + lngIncrement
  RMC_SetSeriesData %ID_RMC1,2,1,aData2(0),UBOUND(aData2)+1
  '
  RMC_Draw %ID_RMC1
'
END FUNCTION
