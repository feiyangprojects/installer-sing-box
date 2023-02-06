!include "MUI2.nsh"
!include "x64.nsh"

!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin"
    MessageBox MB_ICONEXCLAMATION "Administrator rights required!"
    SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
    Quit
${EndIf}
!macroend

!define APPNAME "sing-box"
!define APPDESCRIPTION "The universal proxy platform."
!define APPLICENSE "GPL-3.0-or-later"
!define APPVERSIONMAJOR 1
!define APPVERSIONMINOR 1
!define APPVERSIONBUILD 2
!define APPVERSIONPATCH 1000000

Target amd64-unicode

Name "${APPNAME}"
OutFile "app-installer.exe"

VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "FileDescription" "${APPDESCRIPTION}"
VIAddVersionKey "LegalCopyright" "${APPLICENSE}"
VIAddVersionKey "FileVersion" "${APPVERSIONMAJOR}.${APPVERSIONMINOR}.${APPVERSIONBUILD}.${APPVERSIONPATCH}"
VIAddVersionKey "ProductVersion" "${APPVERSIONMAJOR}.${APPVERSIONMINOR}.${APPVERSIONBUILD}.${APPVERSIONPATCH}"
VIFileVersion "${APPVERSIONMAJOR}.${APPVERSIONMINOR}.${APPVERSIONBUILD}.${APPVERSIONPATCH}"
VIProductVersion "${APPVERSIONMAJOR}.${APPVERSIONMINOR}.${APPVERSIONBUILD}.${APPVERSIONPATCH}"

InstallDir "$PROGRAMFILES64\${APPNAME}"

RequestExecutionLevel admin

!define MUI_ICON "app.ico"
!define MUI_UNICON "app.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE true
!define MUI_UNFINISHPAGE_NOAUTOCLOSE true

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "app\license.rtf"
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function .onInit
    SetShellVarContext all
    !insertmacro VerifyUserIsAdmin
FunctionEnd

Section "Install"
    SectionIn RO

    SetOutPath "$INSTDIR"

    Exec '"C:\Windows\System32\taskkill.exe" /F /T /IM sing-box.exe'

    File /R "app\yacd"
    File "app\geo*.db"
    ${If} ${IsNativeAMD64}
        File /ONAME=${APPNAME}.exe "app\${APPNAME}-amd64.exe"
    ${ElseIf} ${IsNativeARM64}
        File /ONAME=${APPNAME}.exe "app\${APPNAME}-arm64.exe"
    ${EndIf}

    WriteUninstaller "Uninstall.exe"

    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "-NoExit -Command $$env:PATH += ';$INSTDIR'; sing-box"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall ${APPNAME}.lnk" "$INSTDIR\Uninstall.exe"

    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /S"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""

    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${APPVERSIONMAJOR}.${APPVERSIONMINOR}.${APPVERSIONBUILD}.${APPVERSIONPATCH}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMajor" "${APPVERSIONMAJOR}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMinor" "${APPVERSIONMINOR}"
    # There is no option for modifying or repairing the install
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
SectionEnd

Function un.onInit
    SetShellVarContext all

    !insertmacro VerifyUserIsAdmin
FunctionEnd
 
Section "Uninstall"
    RMDir /R "$SMPROGRAMS\${APPNAME}"

    RMDir /R "$INSTDIR"

    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd
