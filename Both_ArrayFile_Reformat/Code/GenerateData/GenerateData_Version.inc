#RESOURCE VERSIONINFO

#IF %DEF(%BETAVERSION)
    #RESOURCE FILEFLAGS %VS_FF_PRERELEASE
#ELSE
    #RESOURCE FILEFLAGS 0
#ENDIF

#RESOURCE FILEVERSION 1, 0, 0, 0
#RESOURCE PRODUCTVERSION 1, 0, 0, 0

#RESOURCE STRINGINFO "0409", "04B0"

#RESOURCE VERSION$ "CompanyName",      "My Company, Inc."
#RESOURCE VERSION$ "FileDescription",  "Generate Bulk data application"
#RESOURCE VERSION$ "FileVersion",      "01.00.0000"
#RESOURCE VERSION$ "InternalName",     "GenerateData"
#RESOURCE VERSION$ "OriginalFilename", "GenerateData.EXE"
#RESOURCE VERSION$ "LegalCopyright",   "Copyright © 2019 My Company, Inc."
#RESOURCE VERSION$ "ProductName",      "Generate Data"
#RESOURCE VERSION$ "ProductVersion",   "01.00.0000"
#RESOURCE VERSION$ "Comments",         "This app creates automatically generated data"

#RESOURCE ICON, 4000, "GenerateData.ICO"
