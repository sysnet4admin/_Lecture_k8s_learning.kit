#!/usr/bin/env bash

# install istioctl  
curl -L  https://github.com/sysnet4admin/BB/raw/main/istioctl/v1.12.2/istioctl -o /usr/local/bin/istioctl
chmod 744 /usr/local/bin/istioctl

curl -L  https://github.com/sysnet4admin/BB/raw/main/istioctl/v1.12.2/istioctl.bash -o /etc/bash_completion.d/istioctl.bash
echo 'source /etc/bash_completion.d/istioctl.bash' >> ~/.bashrc

echo "Successfully installed istioctl"
