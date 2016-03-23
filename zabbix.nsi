!include "x64.nsh"
!include "MUI.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

Name "ARM Zabbix win client"
OutFile "zabbix_inst.exe"
InstallDir "$PROGRAMFILES\zabbix"
SetCompressor lzma

!define MUI_ICON "C:\Users\nosekomoe\Desktop\zabbix_agents_3.0.0.win\zabbix_a.ico"
#!insertmacro MUI_PAGE_WELCOME
#!insertmacro MUI_UNPAGE_CONFIRM
#!insertmacro MUI_UNPAGE_INSTFILES

#---------------------
Var Dialog
Var Text
Var Label
Var Hostname
Var Rbtn1
Var Rbtn2
Var x64state

Page custom nsDialogsPage nsDialogsPageLeave
Page instfiles


Function .onInit
	${If} ${RunningX64}
	#	# 64bit code
	StrCpy $x64state ${BST_CHECKED}
	${Else}
	#	# 32bit code
#	StrCpy $x64state "x86"
	${EndIf}
FunctionEnd


Function nsDialogsPage
	nsDialogs::Create 1018
	Pop $Dialog
	${If} $Dialog == error
		Abort
	${EndIf}
#--------------

	${NSD_CreateLabel} 0 13u 60u 12u "Type hostname: "
	Pop $Label

	${NSD_CreateText} 60u 13u 100% 12u $Hostname
	Pop $Text

	${NSD_CreateRadioButton} 60u 30u 50u 12u "x86"
	Pop $Rbtn1
	${NSD_CreateRadioButton} 60u 45u 50u 12u "x64"
	Pop $Rbtn2
	
	${If} ${RunningX64}
	#	# 64bit code
	${NSD_SetState} $Rbtn2 ${BST_CHECKED}
	${NSD_SetState} $Rbtn1 ${BST_UNCHECKED}
	${Else}
	#	# 32bit code
	${NSD_SetState} $Rbtn1 ${BST_CHECKED}
	${NSD_SetState} $Rbtn2 ${BST_UNCHECKED}
	${EndIf}
		
	#Pop $Btn
	#${NSD_OnClick} $Btn nsDialogsChange
	
	nsDialogs::Show
	
FunctionEnd

Function nsDialogsPageLeave
	${NSD_GetText} $Text $Hostname
	${NSD_GetState} $Rbtn2 $x64state
	${If} $Hostname == "" 
		StrCpy $Hostname "HOST"
	${Else}
	${EndIf}
FunctionEnd

#Function nsDialogsChange
#	
#	MessageBox MB_OK "Hostname is:$Hostname"
#FunctionEnd

Section "zabbix client" SecMain
 SetOutPath "$INSTDIR"
 
DetailPrint "============" 
DetailPrint "Zabbix agent install $x64state"
DetailPrint "Hostname is $Hostname"
DetailPrint "------------"
${If} $x64state == "1"
File "C:\Users\nosekomoe\Desktop\zabbix_agents_3.0.0.win\bin\win64\zabbix_agentd.exe"
DetailPrint "installing x64 version"
${Else}
File "C:\Users\nosekomoe\Desktop\zabbix_agents_3.0.0.win\bin\win32\zabbix_agentd.exe"
DetailPrint "installing x86 version"
${EndIf}
File "C:\Users\nosekomoe\Desktop\firewall_settings.reg"
	FileOpen $9 C:\zabbix_agentd.log w
	FileClose $9
	
	FileOpen $9 $INSTDIR\zabbix.conf w 
	FileWrite $9 "LogFile=C:\zabbix_agentd.log$\n"
	FileWrite $9 "Server=192.168.1.150$\n"
	FileWrite $9 "ListenPort=10050$\n"
	FileWrite $9 "ServerActive=192.168.1.150$\n"
	FileWrite $9 "Hostname="
	FileWrite $9 "$Hostname$\n"
	FileClose $9
	
	FileOpen $9 $INSTDIR\init.cmd w
	FileWrite $9 "@ECHO OFF$\r$\n"
	FileWrite $9 '"$INSTDIR\zabbix_agentd.exe" -c "$INSTDIR\zabbix.conf" -i$\r$\n'
	FileWrite $9 '"$INSTDIR\zabbix_agentd.exe" -c "$INSTDIR\zabbix.conf" -s$\r$\n'
	#FileWrite $9 "PAUSE 60"
	FileClose $9 

 #WriteUninstaller "$INSTDIR\uninstall.exe"
 WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" "zabbix_agent_in" "v2.10|Action=Allow|Active=TRUE|Dir=In|App=%ProgramFiles%\\zabbix\\zabbix_agentd.exe|Name=Zabbix agent|"	
 WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" "zabbix_agent_out" "v2.10|Action=Allow|Active=TRUE|Dir=Out|App=%ProgramFiles%\\zabbix\\zabbix_agentd.exe|Name=Zabbix agent|"
 MessageBox MB_OK "add direwall rules"
 ExecWait '"$INSTDIR\init.cmd"'
 MessageBox MB_OK "install service"
 #ExecWait '"$INSTDIR\zabbix_agentd.exe -c $INSTDIR\zabbix.conf -s"'
 #MessageBox MB_OK "run"
 
SectionEnd

#
#=== UNINSTALL ===
#
#Section "Uninstall"
#	Delete "$INSTDIR\*.*"
#	RMDir "$INSTDIR"
#SectionEnd