##
## Handles the embedding of the Win32 app manifest XML into the EXE

# import std/os
# import stdx/osproc
# import std/strformat
# import std/strutils

# # Get binary names
# when defined(windows):
#     const mingw = false
#     const windres = "windres"
# else:
#     const mingw = true
#     const windres = "x86_64-w64-mingw32-windres"

# ## Final path to embedded resource (processed at compile time)
# const resourceCompiledPath = getTempDir() / "nim-reactive" / "app.res"

# # Run code at compile time
# static:

#     echo "Embedding Win32 resource XML..."
#     const xml = """
#         <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
#         <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3">

#             <!-- Application settings -->
#             <asmv3:application>
#                 <asmv3:windowsSettings>
    
#                     <!-- DPI awareness setting (per monitor v2) ... https://docs.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows -->
#                     <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true</dpiAware>
#                     <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2</dpiAwareness>

#                 </asmv3:windowsSettings>
#             </asmv3:application>

#             <!-- WinXP+ control styles and require admin -->
#             <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
#                 <security>
#                     <requestedPrivileges>
#                         <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
#                     </requestedPrivileges>
#                 </security>
#             </trustInfo>

#             <!-- Dependencies -->
#             <dependency>
#                 <dependentAssembly>
#                     <assemblyIdentity type="Win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" language="*"/>
#                 </dependentAssembly>
#             </dependency>

#         </assembly>
#     """

#     # Make sure temp dir exists
#     createDir(getTempDir() / "nim-reactive")

#     # Write to temporary file
#     let manifestPath = getTempDir() / "nim-reactive" / "app.manifest"
#     writeFile(manifestPath, xml)

#     # Create temporary resource file
#     let resourcePath = getTempDir() / "nim-reactive" / "app.rc"
#     writeFile(resourcePath, fmt"""
#         #include <windows.h>
#         CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST "{manifestPath.replace("\\", "\\\\")}"
#     """.strip())

#     # Compile the resource file
#     let res = staticExec(@[
#         windres, 
#         resourcePath,               # Input file
#         "-O", "coff",               # Output COFF format - thanks https://stackoverflow.com/a/67040061/1008736
#         "-o", resourceCompiledPath  # Output file
#     ].quoteShellCommand)

#     echo "windres: ", res

    
# # Include the built resource file into the app
# {. link:resourceCompiledPath .}