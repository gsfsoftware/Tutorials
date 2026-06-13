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

FUNCTION PBMAIN()
   ShowDialogRMC 0, 420, 314
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
    SELECT CASE CBMSG
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
    tChart.nWidth       = 600
    tChart.nHeight      = 450
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
    tRegion.nWidth      = -5
    tRegion.nHeight     = -5
    tRegion.sFooter     = "Created on Friday"
    tRegion.nShowBorder = %FALSE
    nRetVal = RMC_AddRegionI(%ID_RMC1, tRegion)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add caption to region 1 *******************
    tCaption.sText  =     "Our first chart"
    tCaption.nBackColor = %ColorDefault
    tCaption.nTextColor = %ColorDefault
    tCaption.nFontSize  = 18
    tCaption.nIsBold    = %TRUE
    nRetVal = RMC_AddCaptionI(%ID_RMC1, 1, tCaption)
    IF nRetVal < 0 THEN GOTO IsError
    '************** Add legend to region 1 *******************************
    tLegend.nLegendAlign    = %RMC_LEGEND_BOTTOM
    tLegend.nLegendBackColor= %ColorWhiteSmoke
    tLegend.nLegendStyle    = %RMC_LEGENDRECT
    tLegend.nLegendTextColor= %ColorDefault
    tLegend.nLegendFontSize = 10
    tLegend.nLegendIsBold   = %TRUE
    szTemp = "Test 1*Test 2*Test 3*Test 4"
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
    '****** Read color values ******
    REDIM aColor(3)
    aColor(0) = %ColorDefault
    aColor(1) = %ColorDefault
    aColor(2) = %ColorDefault
    aColor(3) = %ColorGold
    '****** Read data values ******
    REDIM aData(3)
    aData(0) = 3 : aData(1) = 4 : aData(2) = 6 : aData(3) = 9
    nRetVal = RMC_AddGridlessSeriesI(%ID_RMC1,1, aData(0), 4,aColor(0),4, tGridlessSeries)
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
