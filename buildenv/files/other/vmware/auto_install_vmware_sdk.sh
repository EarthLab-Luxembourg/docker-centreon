#!/usr/bin/expect

set timeout 120

spawn "/tmp/vmware-vsphere-cli-distrib/vmware-install.pl"

expect "Press enter to display " { send "\r" }
expect "vSphere Software Development Kit License Agreement" { send "q" }
expect "Do you accept" { send "yes\r" }
expect "In which directory do you want to install the executable files" { send "\r" }
# Wait for installation to finish
expect EOF
