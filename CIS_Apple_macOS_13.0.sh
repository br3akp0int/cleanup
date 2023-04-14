#!/bin/sh

#CIS Benchmarks for macOS Ventura 13.0
#

echo "Welcome to CIS Benchmarks verification for your macOS"
echo "Run with higher read privileges"
say "Welcome to CIS Benchmarks verification for your macOS"
echo "Your macOS meta details below: "
echo "\n"
echo "====macOS version==== "
sw_vers

echo "\n"
echo "===nix distribution Details===" 
uname -a

echo "\n"
echo "1.1 Ensure All Apple-provided Software Is Current"
echo "Last Successful Update"
defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate
#Remediation
#/usr/bin/sudo /usr/sbin/softwareupdate -i '<package name>'
#/usr/bin/sudo /usr/sbin/softwareupdate -i -a -R
echo "\n"

echo "1.2 Ensure Auto Update Is Enabled"
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('AutomaticCheckEnabled').js
EOS
echo "\n"

#Remediation
#/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "======Download New Updates Enabled Check===="
echo "1.3 Ensure Download New Updates When Available Is Enabled"
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('AutomaticDownload').js
EOS
echo "\n"

echo "====1.4 Ensure Install of macOS Updates Is Enabled ===="
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('AutomaticallyInstallMacOSUpdates').js
EOS
echo "\n"

echo "====1.5 Ensure Install Application Updates from the App Store Is Enabled===="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = 
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.commerce').objectForKey('AutoUpdate'))
  let pref2 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
  .objectForKey('AutomaticallyInstallAppUpdates'))
  if ( pref1 == 1 || pref2 == 1 ) {
    return("true")
  } else {
    return("false")
} }
EOS

echo "\n"

echo "========"
echo "==== 1.6 Ensure Install Security Responses and System Files Is Enabled===="
echo "==Updates for XProtect and Gatekeeper Installed?=="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate').objectForKey('ConfigDataInstall'))
  let pref2 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate').objectForKey('CriticalUpdateInstall'))
  if ( pref1 == 1 && pref2 == 1 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
echo "\n"

echo "====1.7 Ensure Software Update Deferment Is Less Than or Equal to 30 Days ===="
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('enforcedSoftwareUpdateDelay').js
EOS
echo "\n"

echo "====2.0 Secure Config for System Settings===="
echo "====2.1.1.1 Audit iCloud Keychain===="
/usr/bin/defaults read /Users/br3akp0int/Library/Preferences/MobileMeAccounts | grep -B 1 KEYCHAIN_SYNC
echo "\n"
echo "====2.1.1.2 Audit iCloud Drive===="
/usr/bin/defaults read /Users/br3akp0int/Library/Preferences/MobileMeAccounts | /usr/bin/grep -B 1 MOBILE_DOCUMENTS
echo "\n"

echo "====2.1.1.3 Ensure iCloud Drive Document and Desktop Sync Is Disabled===="
echo "=== Number of files Syncing if any==="
/bin/ls -l /Users/br3akp0int/Library/Mobile\ Documents/com~apple~CloudDocs/ | /usr/bin/grep total
echo "\n"

echo "====2.1.2 Audit App Store Password Settings ===="
echo "== Manual: Verify that Purchases and In-App Purchases is set to your requirements"
echo "\n"

echo "====2.2 Network System Settings===="
echo "====2.2.1 2.2.1 Ensure Firewall Is Enabled===="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.alf').objectForKey('globalstate')) 
  let pref2 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
  .objectForKey('EnableFirewall'))
  if ( ( pref1 == 1 ) || ( pref1 == 2 ) || ( pref2 == "true" ) ) {
    return("true")
  } else {
    return("false")
} }
EOS
echo "\n"

echo "Applications Allowing incoming connections currently ..."
/usr/libexec/ApplicationFirewall/socketfilterfw --listapps
# Remove specific apps
# /usr/libexec/ApplicationFirewall/socketfilterfw --remove </path/application name>
echo "\n"

echo "====Stealth Mode Info ===="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.alf').objectForKey('stealthenabled')) 
  let pref2 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
  .objectForKey('EnableStealthMode'))
  if ( ( pref1 == 1 ) || ( pref2 == "true" ) ) {
    return("true")
  } else {
    return("false")
} }
EOS
#Enabling Stealth will take away capapbilities like Ping, etc
#/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
echo "\n"

echo "==== 2.3 General===="
echo "2.3.1.1 Ensure AirDrop Is Disabled "
/usr/bin/defaults read com.apple.NetworkBrowserDisableAirDrop

#Disable Airdrop
#defaults write com.apple.NetworkBrowserDisableAirDrop -bool true

echo "==2.3.1.2 Ensure AirPlay Receiver Is Disabled=="
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.controlcenter')\
.objectForKey('AirplayRecieverEnabled').js
EOS
echo "\n"

echo "==2.3.2 Date & Time=="
echo "==2.3.2.1 Ensure Set Time and Date Automatically Is Enabled=="
#sudo /usr/sbin/systemsetup -getusingnetworktime
echo "\n"

echo "==2.3.2.2 Ensure Time Is Set Within Appropriate Limits=="
echo "==Ensure that the offset result(s) are between -270.x and 270.x seconds.=="
#sudo /usr/bin/sntp time.asia.apple.com
echo "\n"

echo "===2.3.3.1 Ensure DVD or CD Sharing Is Disabled ==="
/bin/launchctl list | grep -c com.apple.ODSAgent

echo "\n"

echo "===2.3.3.2 Ensure Screen Sharing Is Disabled==="
/bin/launchctl list | grep -c com.apple.screensharing
echo "\n"

echo "===2.3.3.3 Ensure File Sharing Is Disabled==="
/bin/launchctl list | grep -c "com.apple.smbd"
echo "\n"

echo "===2.3.3.4Ensure Printer Sharing Is Disabled ==="
/usr/sbin/cupsctl | grep -c "_share_printers=0"
echo "\n"

echo "===2.3.3.5 Ensure Remote Login Is Disabled==="
#sudo /usr/sbin/systemsetup -getremotelogin
echo "\n"

echo "===2.3.3.6 Ensure Remote Management Is Disabled==="
/bin/ps -ef | /usr/bin/grep -e ARDAgent
echo "\n"

echo "===2.3.3.7 Ensure Remote Apple Events Is Disabled==="
#sudo /usr/sbin/systemsetup -getremoteappleevents
echo "\n"

echo "===2.3.3.8 Ensure Internet Sharing Is Disabled==="
/usr/bin/defaults read /Library/Preferences/SystemConfiguration/com.apple.nat >nul 2>&1 | grep -c "Enabled = 1;"
echo "\n"

echo "===2.3.3.9 Ensure Content Caching Is Disabled==="
echo "===Check manually Security & Privacy==="


echo "===2.3.3.10 Ensure Media Sharing Is Disabled==="
/usr/bin/defaults read com.apple.amp.mediasharingd home-sharing-enabled
echo "\n"

echo "===2.3.3.11 Ensure Bluetooth Sharing Is Disabled ==="
/usr/bin/defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled
echo "\n"

echo "===2.3.3.12 Ensure Computer Name Does Not Contain PII or Protected 
Organizational Information : Manual ==="

echo "\n"
echo "===2.3.4 Time Machine==="
echo "===2.3.4.1 Ensure Backup Automatically is Enabled If Time Machine 
Is Enabled==="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.TimeMachine')
\
.objectForKey('AutoBackup'))
if ( pref1  == null ) {
  return("Preference Not Set")
}  else if ( pref1 == 1 ) {
  return("true")
}  else {
  return("false")
} }
EOS
echo "\n"

echo "===2.3.4.2 Ensure Time Machine Volumes Are Encrypted If Time 
Machine Is Enabled==="
/usr/bin/defaults read /Library/Preferences/com.apple.TimeMachine.plist | grep -c NotEncrypted

echo "\n"

echo "===2.4 Control Center==="
echo "===2.4.1 Ensure Show Wi-Fi status in Menu Bar Is Enabled==="
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.controlcenter')\
.objectForKey('WiFi').js
EOS
echo "\n"

echo "===2.4.2 Ensure Show Bluetooth Status in Menu Bar Is Enabled==="
echo "===2.5 Siri & Spotlight==="
echo "===Skipping this...\n"

/usr/bin/defaults read com.apple.assistant.support.plist 'Assistant 
Enabled'

echo "===2.6 Privacy & Security==="
echo "2.6.1 Location Services: Trivial; Skipping these..."
echo "2.6.1.1 Ensure Location Services Is Enabled"
echo "2.6.1.2 Ensure Location Services Is in the Menu Bar "
echo "2.6.1.3 Audit Location Services Access"
echo "2.6.2 Ensure Sending Diagnostic and Usage Data to Apple Is 
Disabled "
/usr/bin/defaults read /Library/Application\
Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit
echo "\n2.6.3 Ensure Limit Ad Tracking Is Enabled"
/usr/bin/defaults read 
/Users/br3akp0int/Library/Preferences/com.apple.AdLib.plist 
allowApplePersonalizedAdvertising

echo "\n"
echo "===2.6.4 Ensure Gatekeeper Is Enabled==="
/usr/sbin/spctl --status
echo "\n"

echo "=====2.6.5 Ensure FileVault Is Enabled==="
/usr/bin/fdesetup status
echo "\n"

echo "===2.6.6 Audit Lockdown Mode: Not Needed ==="
echo "\n"

echo "===2.6.7 Ensure an Administrator Password Is Required to 
Access System-Wide Preferences: Manual==="
echo "\n"

echo "===2.7 Desktop & Dock==="
echo "===2.7.1 Ensure Screen Saver Corners Are Secure==="
/usr/bin/defaults read com.apple.dock wvous-tl-corner
echo "===2.8 Displays==="
echo "===2.8.1 Audit Universal Control Settings:Manual==="
echo "===2.9 Battery (Energy Saver)==="
echo "===2.9.1 Ensure Power Nap Is Disabled for Intel Macs==="
/usr/bin/pmset -g custom | /usr/bin/grep -c 'powernap 1'
echo "\n"

echo "===2.9.2 Ensure Wake for Network Access Is Disabled==="
/usr/bin/pmset -g custom | /usr/bin/grep -e womp
echo "\n"

echo "===2.9.3 Ensure the OS is not Activate When Resuming from Sleep==="
echo "===2.10.1 Ensure an Inactivity Interval of 20 Minutes Or Less for the Screen 
Saver Is Enabled==="
echo "===2.10.2 Ensure a Password is Required to Wake the Computer From Sleep or Screen 
Saver Is Enabled ==="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')
\
  .objectForKey('askForPassword'))
  let pref2 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')
\
  .objectForKey('askForPasswordDelay'))
  if ( pref1 == 1 && pref2 <= 5 ) {
    return("true")
  } else {
    return("false")
  }
} EOS
echo "\n"

echo "===2.10.4 Ensure Login Window Displays as Name and Password Is Enabled 
(Automated)==="
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('SHOWFULLNAME').js
EOS
echo "\n"
echo "===2.11 Touch ID & Password (Login Password)==="
echo "===2.12 Users & Groups==="
echo "===2.12.1 Ensure Guest Account Is Disabled==="
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
  .objectForKey('DisableGuestAccount'))
  let pref2 =
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')
\
  .objectForKey('GuestEnabled'))
  if ( pref1 == 1 || pref2 == 0 ) {
    return("true")
  } else {
    return("false")
} }
EOS
echo "\n"

echo "===2.12.2 Ensure Guest Access to Shared Folders Is Disabled==="
/usr/sbin/sysadminctl -smbGuestAccess status
echo "2.12.3 Ensure Automatic Login Is Disabled"
echo "======2.13 Passwords==="
echo "======2.13.1 Audit Passwords System Preference Setting=="
echo "======\n 3 Logging and Auditing==="
/bin/launchctl list | /usr/bin/grep -i auditd
echo "==check /var/log/install.log =="
grep -i all_max= /etc/asl/com.apple.install
echo "======4 Network Configurations=="
echo "======Bonjour Service Disabled?=="
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.mDNSResponder')\
.objectForKey('NoMulticastAdvertisements').js
EOS
echo "======HTTP=="
/bin/launchctl list | /usr/bin/grep -c "org.apache.httpd"
echo "=====NFS=="
/bin/launchctl list | /usr/bin/grep -c com.apple.nfsd

echo "\n"
echo "===5 System Access, Authentication and Authorization==="
echo "===SIP=="
/usr/bin/csrutil status
echo "====File Integrity=="
/usr/sbin/nvram -p | /usr/bin/grep -c "amfi_get_out_of_my_way=1"
/usr/bin/csrutil authenticated-root status

echo "\n"
echo "No World Writable Files Exist in the System Folder"
#sudo /usr/bin/find /System/Volumes/Data/System -type d -perm -2 -ls | /usr/bin/grep -v 
"Drop Box" | /usr/bin/wc -l | /usr/bin/xargs

echo "===5.3.1 Ensure all user storage APFS volumes are encrypted=="
/usr/sbin/diskutil ap list
echo "===Firmware T2 chip"
/usr/sbin/system_profiler SPiBridgeDataType | grep "T2"
echo "===End of CIS Tests, Thank You!==="
say "Thank you for your Patience :)"
echo "\n"





