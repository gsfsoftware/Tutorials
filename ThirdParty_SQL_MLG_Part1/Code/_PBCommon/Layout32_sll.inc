'                        Acknowledgements
' Jeffrey Richter:
' For his original implementation of a layout algorithm which positions
' controls in a window based on a set of rules.

' Notice: Portions Copyright © 1995 Jeffrey Richter

' Action to perform
%STRETCH = 0        ' Metric should be stretched
%MOVE    = 1        ' Control should be moved
%VCENTER = 2        ' Vertically center control/group
%HCENTER = 3        ' Horizontally center control/group

' Part to act on or relative to
%LEFT    = 0        ' Left side of control
%TOP     = 1        ' Top side of control
%RIGHT   = 2        ' Right side of control
%BOTTOM  = 3        ' Bottom side of control
%WIDTH   = 4        ' Width of control
%HEIGHT  = 5        ' Height of control
%CONTROL = 6        ' Group(one control)
%WIDGET  = %CONTROL ' Widget and Control are synonymous
%GROUP   = 7        ' Group(two controls acting as limits for a range of controls)

' Scale mode
%SCALEMODE_NONE     = -1
%SCALEMODE_DPI      = 0
%SCALEMODE_FONT     = 1
%SCALEMODE_DIALOG   = 2

' Special value indicating that the window
' being acted relative to is the form
%FORM      = &H7FFFFFFE&

' Special value indicating that the maximum
' size of a window is umlimited
%NOLIMIT            = 0

