# Startup script for command-line invocation of tclftdi
# This startup script assumes that the board is physically configured
# for communication with the Raven chip on-board SPI.

# 1) Define simplified read and write operations for the Raven SPI

proc ftdi::raven_read {device addr nbytes} {
    if {$nbytes > 7} {
        return [ftdi::raven_stream_read $device $addr $nbytes]
    } else {
        set cmdword [expr {(0x40 + ($nbytes << 3)) * 256 + $addr}]
        return [ftdi::spi_read $device $cmdword $nbytes]
    }
}

proc ftdi::raven_write {device addr data} {
    set nbytes [llength $data]
    if {$nbytes > 7} {
        ftdi::raven_stream_write $device $addr $data
    } else {
        set cmdword [expr {(0x80 + ($nbytes << 3)) * 256 + $addr}]
        ftdi::spi_write $device $cmdword $data
    }
}

proc ftdi::raven_stream_read {device addr nbytes} {
    set cmdword [expr {0x40 * 256 + $addr}]
    # return [ftdi::spi_read $device $cmdword $nbytes]
    return [ftdi::bitbang_read $device $cmdword $nbytes]
}

proc ftdi::raven_stream_write {device addr data} {
    set cmdword [expr {0x80 * 256 + $addr}]
    # ftdi::spi_write $device $cmdword $data
    ftdi::bitbang_write $device $cmdword $data
}

# 2. Define procedure to check for vendor/product ID on Raven

proc ftdi::raven_check {device} {
    set raven_id [ftdi::raven_read $device 1 3]
    set vendor_id [expr {[lindex $raven_id 0] * 256 + [lindex $raven_id 1]}]
    set product_id [lindex $raven_id 2]

    if {$vendor_id != 1110} {
	puts stderr "Error:  Received vendor ID of $vendor_id, expecting 1110"
    }

    if {$product_id != 2} {
	puts stderr "Error:  Received product ID of $product_id, expecting 2"
    }

    if {$vendor_id == 1110 && $product_id == 2} {
        puts stdout "Confirmed DUT is efabless Raven"
	return 0
    }
    return 1
}

# 3. Define additional access commands so that one does not have to memorize
#    register locations

# 3a. Reset Raven.  mode can be "pulse", "on", or "off".  Default is "pulse".

proc ftdi::reset {device {mode pulse}} {
    if {$mode == "pulse" || $mode == "on"} {
        ftdi::raven_write $device 7 1
    }
    if {$mode == "pulse" || $mode == "off"} {
        ftdi::raven_write $device 7 0
    }
}

# 3b. Set clock.  mode is "external" ("ext") or "internal" ("pll").  Default
# mode is "internal" (PLL 100MHz clock).  This routine both switches to the
# external clock and powers down the PLL and crystal oscillator, and vice
# versa.

proc ftdi::set_clock {device {mode internal}} {
    if {$mode == "internal" || $mode == "pll"} {
        ftdi::raven_write $device 4 0x0f
        ftdi::raven_write $device 5 0
    }
    if {$mode == "external" || $mode == "ext"} {
        ftdi::raven_write $device 5 1
        ftdi::raven_write $device 4 0x04
    }
}

# 3c. Apply IRQ.  mode can be "pulse", "on", or "off".  Default is "pulse".

proc ftdi::interrupt {device {mode pulse}} {
    if {$mode == "pulse" || $mode == "on"} {
        ftdi::raven_write $device 6 1
    }
    if {$mode == "pulse" || $mode == "off"} {
        ftdi::raven_write $device 6 0
    }
}

# 3d. Get the CPU trap state.  Returns 1 or 0

proc ftdi::get_trap {device} {
    return [ftdi::raven_read $device 8 1]
}

# 3e. Power down the Raven chip

proc ftdi::powerdown {device} {
    ftdi::raven_write $device 4 0
}

# 3f. Power up the Raven chip

proc ftdi::powerup {device} {
    ftdi::raven_write $device 4 0x0f
}

# Open the device

setid 24592 1027
set raven [opendev B]
spi_bitbang $raven {{CSB 3} {SDO 2} {SDI 1} {SCK 0} {USR0 4} {USR1 5} {USR2 6} {USR3 7}}
bitbang_word $raven 8
spi_speed $raven 1.0
spi_command $raven 16

# Check that the communications channel to the Raven SPI is working

if {[ftdi::raven_check $raven] != 0} {exit}

# Import commands
namespace import ftdi::powerup ftdi::powerdown ftdi::interrupt ftdi::get_trap
namespace import ftdi::set_clock ftdi::reset ftdi::raven_check

# Print a list of commands
puts stdout "Raven housekeeping SPI commands:"
puts stdout ""
puts stdout "  reset $raven \[pulse|on|off\]"
puts stdout "  interrupt $raven \[pulse|on|off\]"
puts stdout "  set_clock $raven \[external|internal\]"
puts stdout "  powerup $raven"
puts stdout "  powerdown $raven"
puts stdout "  get_trap $raven"
puts stdout "  raven_check $raven"
puts stdout ""
