
run 1-1
run 1-2 

# create cloud dns and input A record and select static IP
# And several minutes later. 
# check certifcate 

openssl s_client -connect oncloud-2.site:443
CONNECTED(00000005)
depth=3 C = BE, O = GlobalSign nv-sa, OU = Root CA, CN = GlobalSign Root CA
verify return:1
depth=2 C = US, O = Google Trust Services LLC, CN = GTS Root R1
verify return:1
depth=1 C = US, O = Google Trust Services LLC, CN = GTS CA 1D4
verify return:1
depth=0 CN = oncloud-2.site
verify return:1
<snipped>

# few minutes later. 
# and then open browser. input "oncloud-2.site" 
