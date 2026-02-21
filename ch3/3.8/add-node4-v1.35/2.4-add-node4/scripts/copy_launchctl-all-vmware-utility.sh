#!/usr/bin/env bash

# make reload command to local machine 
cat <<EOF > /usr/local/bin/launchctl-reload-vmware-utility 
sudo launchctl unload -w /Library/LaunchDaemons/com.vagrant.vagrant-vmware-utility.plist
echo "wait for 5seconds..." ; sleep 5 
sudo launchctl load -w /Library/LaunchDaemons/com.vagrant.vagrant-vmware-utility.plist
EOF
sudo chmod 775 /usr/local/bin/launchctl-reload-vmware-utility 

# make load command to local machine
cat <<EOF > /usr/local/bin/launchctl-load-vmware-utility
sudo launchctl load -w /Library/LaunchDaemons/com.vagrant.vagrant-vmware-utility.plist
EOF
sudo chmod 775 /usr/local/bin/launchctl-load-vmware-utility

# make unload command to local machine
cat <<EOF > /usr/local/bin/launchctl-unload-vmware-utility
sudo launchctl unload -w /Library/LaunchDaemons/com.vagrant.vagrant-vmware-utility.plist
EOF
sudo chmod 775 /usr/local/bin/launchctl-unload-vmware-utility
