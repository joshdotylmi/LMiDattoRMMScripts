#!/bin/bash
sudo rm -rf /Library/Nessus
sudo rm -rf /Library/NessusAgent
sudo rm /Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist
sudo rm -rf /Library/LaunchDaemons/com.tenablesecurity.nessusd.plist
sudo rm -r /Library/PreferencePanes/Nessus Agent Preferences.prefPane
sudo rm -rf /Library/PreferencePanes/Nessus Preferences.prefPane
sudo rm -rf /Applications/Nessus
sudo launchctl remove com.tenablesecurity.nessusd
