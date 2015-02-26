# ddns-utils package:
https://www.opensour.cc/ddns-utils *(coming soon)*  
https://www.GotGetLLC.com/

[Louis T. Getterman IV](https://github.com/LTGIV) ([@LTGIV](https://twitter.com/LTGIV))

## DCU (DDNS Client Updater)
DCU is geared towards nodes needing to update their reciprocal DDNS entry with a WAN auto-detect or manually updated IP address.

## DFWU (DDNS Firewall Update)
DFWU is geared towards hosts that need to remain closed to the world, but open to select nodes which have an ephemeral IP address.  

### DFWU Turnkey install:
`bash <(curl -s https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash||wget -q -O - https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash||echo 'DFWU Install Failure.'>&2)`

### DFWU Manual install:
`git clone https://github.com/LTGIV/ddns-utils.git`  
`sudo bash ddns-utils/dfwu/installer/manifest.bash`
