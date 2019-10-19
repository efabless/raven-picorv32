#! /usr/bin/tclsh
source ~/tclftdi.tcl
source ../../test/startup_flash.tcl
write_flash ftdi0 raven_adc2.hex
exit
