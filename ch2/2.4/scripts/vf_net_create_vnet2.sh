#!/usr/bin/env bash
# create vnet_2

sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cfgcli vnetcfgadd VNET_7_DHCP no
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cfgcli vnetcfgadd VNET_7_HOSTONLY_SUBNET 192.168.1.0
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cfgcli vnetcfgadd VNET_7_HOSTONLY_NETMASK 255.255.255.0
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cfgcli vnetcfgadd VNET_7_NAT yes
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cfgcli vnetcfgadd VNET_7_VIRTUAL_ADAPTER yes

sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --configure
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --stop
sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --start
