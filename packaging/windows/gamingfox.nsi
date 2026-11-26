; GamingFox Windows installer (NSIS). Built in GitHub Actions:
;   makensis /DVERSION=161.0 /DSRCDIR=C:\path\to\gamingfox /DOUTFILE=GamingFox-Setup.exe gamingfox.nsi
Unicode true
SetCompressor /SOLID lzma
!include "MUI2.nsh"

Name "GamingFox"
OutFile "${OUTFILE}"
InstallDir "$PROGRAMFILES64\GamingFox"
InstallDirRegKey HKLM "Software\GamingFox" "InstallDir"
RequestExecutionLevel admin
BrandingText "GamingFox ${VERSION}"

!define MUI_ICON "${SRCDIR}\gamingfox.ico"
!define MUI_UNICON "${SRCDIR}\gamingfox.ico"
!define MUI_FINISHPAGE_RUN "$INSTDIR\gamingfox.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Start GamingFox"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

!define UNINST "Software\Microsoft\Windows\CurrentVersion\Uninstall\GamingFox"

Section "GamingFox"
  SetShellVarContext all
  SetOutPath "$INSTDIR"
  File /r "${SRCDIR}\*.*"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\GamingFox.lnk" "$INSTDIR\gamingfox.exe"
  CreateShortcut "$DESKTOP\GamingFox.lnk" "$INSTDIR\gamingfox.exe"
  WriteRegStr HKLM "Software\GamingFox" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "${UNINST}" "DisplayName" "GamingFox"
  WriteRegStr HKLM "${UNINST}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "${UNINST}" "Publisher" "Hollow"
  WriteRegStr HKLM "${UNINST}" "DisplayIcon" "$INSTDIR\gamingfox.exe"
  WriteRegStr HKLM "${UNINST}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "${UNINST}" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /S'
  WriteRegDWORD HKLM "${UNINST}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINST}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetShellVarContext all
  Delete "$SMPROGRAMS\GamingFox.lnk"
  Delete "$DESKTOP\GamingFox.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "${UNINST}"
  DeleteRegKey HKLM "Software\GamingFox"
SectionEnd
