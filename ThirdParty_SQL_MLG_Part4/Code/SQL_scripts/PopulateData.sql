
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Application] ON 
GO
INSERT [dbo].[CDEF_tbl_Application] ([idxCDEFApplication], [Application]) VALUES (1, N'CDEF_Config.exe')
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Application] OFF
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Colours] ON 
GO
INSERT [dbo].[CDEF_tbl_Colours] ([idxCDEFColours], [ColourValue], [ColourText]) VALUES (1, 0, N'Black')
GO
INSERT [dbo].[CDEF_tbl_Colours] ([idxCDEFColours], [ColourValue], [ColourText]) VALUES (2, 1, N'Red')
GO
INSERT [dbo].[CDEF_tbl_Colours] ([idxCDEFColours], [ColourValue], [ColourText]) VALUES (3, 2, N'Blue')
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Colours] OFF
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Justify] ON 
GO
INSERT [dbo].[CDEF_tbl_Justify] ([idxCDEF_Justify], [JustifyValue], [JustifyText]) VALUES (1, -1, N'Left')
GO
INSERT [dbo].[CDEF_tbl_Justify] ([idxCDEF_Justify], [JustifyValue], [JustifyText]) VALUES (2, 0, N'Centre')
GO
INSERT [dbo].[CDEF_tbl_Justify] ([idxCDEF_Justify], [JustifyValue], [JustifyText]) VALUES (3, 1, N'Right')
GO
INSERT [dbo].[CDEF_tbl_Justify] ([idxCDEF_Justify], [JustifyValue], [JustifyText]) VALUES (4, 9, N'Wordwrap')
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Justify] OFF
GO

SET IDENTITY_INSERT [dbo].[CDEF_tbl_Forms] ON 
GO
INSERT [dbo].[CDEF_tbl_Forms] ([idxCDEFform], [Formname], [ApplicationID]) VALUES (1, N'CDEF Config View', 1)
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Forms] OFF
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Grids] ON 
GO
INSERT [dbo].[CDEF_tbl_Grids] ([idxCDEFgrid], [Gridname], [FormID], [ApplicationID]) VALUES (1, N'ConfigView', 1, 1)
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Grids] OFF
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_TabRef] ON 
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (1, 1, 1, 1, 1, 1, 1, N'ID', 1, N'idxCDEFTabRef', 1, 0, 0, 0, 0, 60, 0, 0, 0, NULL, 1, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (2, 1, 1, 1, 1, 1, 2, N'Tab Position', 2, N'TabPos', 0, 0, 0, 0, 0, 90, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (3, 1, 1, 1, 1, 1, 3, N'Grid Position', 3, N'GridPos', 0, 0, 0, 0, 0, 100, 0, 0, 0, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (4, 1, 1, 1, 1, 1, 4, N'Column Name', 4, N'ColumnName', 0, -1, 0, 0, 0, 200, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (5, 1, 1, 1, 1, 1, 5, N'Result Name', 5, N'ResultName', 0, -1, 0, 0, 0, 200, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (6, 1, 1, 1, 1, 1, 6, N'Column Width', 6, N'Columnwidth', 0, 0, 0, 0, 0, 100, 0, 0, 0, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (7, 1, 1, 1, 1, 1, 7, N'Column Hide', 7, N'ColumnHide', 0, 0, 1, 0, 0, 100, 0, 0, 0, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (8, 1, 1, 1, 1, 1, 8, N'Column Colour', 8, N'ColumnColour', 0, 0, 0, 0, 0, 110, 0, 0, 1, N'EXEC dbo.CDEF_sprGetColours', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (9, 1, 1, 1, 1, 1, 9, N'Column Primary', 9, N'ColumnPrimary', 0, 0, 1, 0, 0, 110, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (10, 1, 1, 1, 1, 1, 10, N'Column Lock', 10, N'ColumnLock', 0, 0, 1, 0, 0, 100, 0, 0, 0, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (11, 1, 1, 1, 1, 1, 11, N'Column Justify', 11, N'JustifyText', 0, -1, 0, 0, 0, 110, 0, 0, 1, N'EXEC dbo.CDEF_sprGetJustifications', 0, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (12, 1, 1, 1, 1, 1, 12, N'Column Checkbox', 12, N'ColumnCheckbox', 0, 0, 1, 0, 0, 130, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (13, 1, 1, 1, 1, 1, 14, N'Column UserButton', 13, N'ColumnUserButtonID', 0, 0, 1, 0, 0, 130, 0, 0, 0, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (14, 1, 1, 1, 1, 1, 13, N'Column CheckBox CounterLimit', 14, N'ColumnCheckBoxCounterLimit', 0, 0, 0, 0, 0, 210, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (15, 1, 1, 1, 1, 1, 15, N'Column Dropdown', 15, N'ColumnDropDown', 0, 0, 1, 0, 0, 150, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (16, 1, 1, 1, 1, 1, 16, N'Column Dropdown SPR', 16, N'ColumnDropdownSPR', 0, -1, 0, 0, 0, 240, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (17, 1, 1, 1, 1, 1, 17, N'ColumnDateTime', 17, N'ColumnDateTime', 0, 0, 1, 0, 0, 120, 0, 0, 0, N'', 0, 0, 0, NULL)
GO
INSERT [dbo].[CDEF_tbl_TabRef] ([idxCDEFTabRef], [ApplicationID], [Form], [Grid], [TabPos], [TabRef], [GridPos], [ColumnName], [ResultPos], [ResultName], [ColumnLock], [ColumnJustify], [ColumnCheckBox], [ColumnUserButtonID], [ColumnHide], [Columnwidth], [ColumnColour], [ColumnCheckBoxCounterLimit], [ColumnDropdown], [ColumnDropdownSPR], [ColumnPrimary], [ColumnDateTime], [ColumnSupressTime], [ColumnNotesField]) VALUES (18, 1, 1, 1, 1, 1, 18, N'ColumnSupressTime', 18, N'ColumnSupressTime', 0, 0, 1, 0, 0, 140, 0, 0, 0, NULL, 0, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_TabRef] OFF
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Tabs] ON 
GO
INSERT [dbo].[CDEF_tbl_Tabs] ([idxCDEFtabs], [TabName], [GridID], [FormID], [ApplicationID]) VALUES (1, N'Configurations', 1, 1, 1)
GO
SET IDENTITY_INSERT [dbo].[CDEF_tbl_Tabs] OFF
GO
