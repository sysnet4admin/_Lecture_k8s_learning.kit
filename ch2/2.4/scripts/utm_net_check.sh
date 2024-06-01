#!/usr/bin/env bash

# depend on the m series
sudo cat /Library/Preferences/SystemConfiguration/com.apple.vmnet.plist | grep -A1 Shared

