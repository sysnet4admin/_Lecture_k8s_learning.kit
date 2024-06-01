#!/usr/bin/env bash
# Reset VMware Fusion Networking

# Clear out the Configuration
sudo rm -f /Library/Preferences/VMware\ Fusion/networking*
sudo rm -f /Library/Preferences/VMware\ Fusion/*location*
sudo rm -rf /Library/Preferences/VMware\ Fusion/vmnet*
sudo rm -rf /var/db/vmware/vmnet-dhcpd-vmnet*

# Reconfigure Networking
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli -c
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --stop
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --start
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --status
