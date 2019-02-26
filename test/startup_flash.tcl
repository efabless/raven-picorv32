# Startup script for command-line invocation of tclftdi
# This startup script assumes that the test board is physically
# configured for communication with the SPI flash.  For the first
# revision board, that means that the J2 jumper must be in the
# top position, and the Raven chip must be in a disabled state by
# jumpering its power supply to the FTDI chip's 1.8V supply.

# Define procedure to check for vendor/product ID on the SPI flash

proc ftdi::flash_check {device} {
    set flash_id [spi_read $device 159 3]
    set vendor_id [lindex $flash_id 0]
    set product_id [lindex $flash_id 1]
    set feature_id [lindex $flash_id 2]

    if {$vendor_id != 1} {
        puts stderr "Error:  Received vendor ID of $vendor_id, expecting 1"
    }

    if {$product_id != 96} {
	puts stderr "Error:  Received product ID of $product_id, expecting 96"
    }

    if {$feature_id != 24} {
        puts stderr "Error:  Received feature ID of $feature_id, expecting 24"
    }

    if {$vendor_id == 1 && $product_id == 96 && $feature_id == 24} {
        puts stdout "Confirmed SPI flash is a Cypress 128MB device"
	return 0
    }
    return 1
}

#------------------------------------------------------------------
# Define procedure to write and read contents of the SPI flash.
#------------------------------------------------------------------

# Check write status on the flash.  If return value is 1, then device is busy

proc ftdi::flash_busy {device} {
    # Command 0x05 = read status register 1
    set status [spi_read $device 5 1]
    return [expr {$status & 1}]
}

# Check write status on the flash from status registers 1 and 2,
# which are returned as a list.
#
# If register 2 return value bit 6 is set, then an erase error
# occurred.  If return value bit 5 is set, then a programming
# error occurred.

proc ftdi::flash_status {device} {
    # Command 0x05 = read status register 1
    set status1 [spi_read $device 5 1]
    # Command 0x07 = read status register 2
    set status2 [spi_read $device 7 1]
    return [list $status1 $status2]
}

# Program the configuration register 1 for quad operation.  This
# disables the use of the WR# and RESET# pins as those functions---
# which are not being used on the board anyway.  Therefore this
# procedure must be done to allow quad operation, but there is no
# reason to ever disable this mode.

proc ftdi::enable_quad {device} {

    spi_command $device 8

    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Read status register so we don't change it.
    set status [spi_read $device 5 1]

    # Apply non-volatile write enable
    spi_write $device 6 {}

    # Write status and configuration 1 registers.
    spi_write $device 1 {$status 2}

    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Apply write disable
    spi_write $device 4 {}

    # Read back the config 1 register, check for value 2
    set config [spi_read $device 53 1]

    if {$config != 2} {
        puts stderr "Bad configuration 1 register value $config is not 2!"
    } else {
        puts stdout "Configuration 1 register okay;  quad mode enabled."
    }
}

# Read status and configuration registers

proc ftdi::read_registers {device} {

    spi_command $device 8

    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    set status  [spi_read $device  5 1]
    set config1 [spi_read $device 53 1]
    set config2 [spi_read $device 21 1]
    set config3 [spi_read $device 51 1]

    puts stdout "Register values:"
    puts stdout "Status   = $status"
    puts stdout "Config 1 = $config1"
    puts stdout "Config 2 = $config2"
    puts stdout "Config 3 = $config3"
}

# Read registers by address (test)
# Note read using this method has latency bits.

proc ftdi::read_register_addr {device address} {

    spi_command $device 8

    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    set cword [expr {101 << 24}]
    set cmdword [expr {$cword + $address}]
    
    spi_command $device 32
    set rval [spi_read $device $cmdword 2]
    spi_command $device 8

    # Assumes 8 bits latency---but is that always true??
    set regval [lindex $rval 1]

    puts stdout "Register value = $regval"
}

# Set the number of latency cycles.  NOTE:  This MUST be done in
# conjunction with setting the number of latency cycles in the
# software when enabling dual or quad modes.

proc ftdi::set_latency {device cycles} {

    spi_command $device 8

    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Read config register3 "before" value
    set config3 [spi_read $device 51 1]
    puts stdout "Register 3 value before programming = $config3"

    # Apply non-volatile write enable
    spi_write $device 6 {}

    # Write configuration 3 register.
    set cword [expr {113 << 24}]
    set cmdword [expr {$cword + 4}]
    set cval [expr {0x70 + $cycles}]

    spi_command $device 32
    spi_write $device $cmdword {$cval}
    spi_command $device 8

    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Apply write disable
    spi_write $device 4 {}

    # Read back the config 3 register, check for value $cycles 
    set config [spi_read $device 51 1]

    if {$config != $cval} {
        puts stderr "Bad configuration 3 register value $config is not $cval!"
    } else {
        puts stdout "Configuration 3 register okay;  latency set to $cycles cycles."
    }
}

# Set *volatile* registers

proc ftdi::temp_set_registers {device status config1 config2 config3} {
    # Apply volatile write enable
    spi_command $device 8
    spi_write $device 0x50 {}

    # Write registers
    spi_write $device 0x01 {$status $config1 $config2 $config3}
}

# Set config register 2 (in case of inadvertant overwriting)

proc ftdi::set_config2 {device} {

    spi_command $device 8

    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Read config register2 "before" value
    set config2 [spi_read $device 21 1]
    puts stdout "Register 3 value before programming = $config2"

    # Apply non-volatile write enable
    spi_write $device 6 {}

    # Write configuration 2 register.
    set cword [expr {113 << 24}]
    set cmdword [expr {$cword + 3}]

    spi_command $device 32
    spi_write $device $cmdword {0x60}
    spi_command $device 8

    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Apply write disable
    spi_write $device 4 {}

    # Read back the config 2 register, check for value 0x60 (96)
    set config [spi_read $device 21 1]

    if {$config != 96} {
        puts stderr "Bad configuration 2 register value $config is not 96!"
    } else {
        puts stdout "Configuration 2 register okay;  value is 96."
    }
}

# Write to the flash chip from an intel format hexfile
# This command performs its own erase cycle first.

proc ftdi::write_flash {device hexfile {doerase true} {debug false}} {
    set start 0

    # Check that hexfile is readable.
    if [catch {open $hexfile r} hf] {
        puts stderr "Failure to open/read hex file $hexfile"
	return
    }

    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Apply write enable
    spi_write $device 6 {}

    if {$doerase} {
	# Perform an erase cycle. 

        puts stdout "Starting erase cycle, please wait (takes approx. 1 min.). . ."
        spi_write $device 96 {}

        # Check for erase cycle finished
        while {[ftdi::flash_busy $device] > 0} {
	    after 100
        }
        puts stdout "Erase cycle finished.  Starting programming."
    }

    # Read hex file.  For each address line, convert data to decimal values,
    # and assemble into an array of byte data.

    # Compute the command word.  Command word comes first, followed by
    # address with low byte first, high byte last.  However, note that
    # the command word passed to tclftdi is a single integer which is
    # transmitted msb first, so reorganize the value accordingly.

    # instruction 0x02 = page program w/3-byte address
    set cword [expr {0x02 << 24}]

    # Read in the hex file, convert address blocks, and write them to
    # the SPI flash
    set datavec {}
    while {[gets $hf line] >= 0} {
        if {[string first @ $line] == 0} {
	    set dlen [llength $datavec]
	    if {$dlen > 0} {

	        # Check for last program cycle finished
	        while {[ftdi::flash_busy $device] > 0} {
		   after 100
	        }

		# Output datavec and reset
		puts stdout "Writing $dlen values at start address $address"

	        # Set command length to 4 bytes (1 byte command + 3 bytes address)
		spi_command $device 32
		if {$debug} {
		    puts stdout "Diagnostic: write_flash: command word is $cmdword"
		}
		spi_write $device $cmdword $datavec
	        spi_command $device 8
    
		set datavec {}
	    }

	    # Set the address line (24 bit address)
	    set address 0x[string range $line 3 8]
            # Ignore the first byte (not using 32 bit addressing)
	    set start [format %d 0x[string range $line 3 8]]
	    set cmdword [expr {$cword + $start}]
        } else {
	    # Append data to datavec
            foreach value $line {
		lappend datavec [format %d 0x$value]
	    }
        }
    }

    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Final block
    set dlen [llength $datavec]

if {0} {
    if {$dlen > 0} {
	# Output datavec
	puts stdout "Writing $dlen values at start address $address"
        # Set command length to 4 bytes (1 byte command + 3 bytes address)
	spi_command $device 32
	if {$debug} {puts stdout "Diagnostic: write_flash: command word is $cmdword"}
	spi_write $device $cmdword $datavec
        spi_command $device 8
    }

    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }
}

    # Program the slowest way, one byte at a time.  This only seems to work
    # if write enable/disable is applied between bytes. . . it's very slow,
    # but it does work.

    set nerrors 0
    if {$dlen > 0} {
        for {set i 0} {$i < $dlen} {incr i} {
	    set byte [lindex $datavec $i]
	    if {$debug} {puts stdout "Diagnostic: write_flash: command word is $cmdword"}

	    # Validate as we go
	    set valid [ftdi::read_flash $device $address 1]
	    if {$valid == $byte} {
		puts stdout "Address $address validated byte $byte"
		incr cmdword
		incr address
		continue
	    }

	    while {1} {
	        # Apply write enable
	        spi_write $device 6 {}

        	spi_command $device 32
		spi_write $device $cmdword $byte
		spi_command $device 8

		# Check for program cycle finished
		while {[ftdi::flash_busy $device] > 0} {
		   after 100
		}

	        # Apply write disable
	        spi_write $device 4 {}

		# Validate byte
		set valid [ftdi::read_flash $device $address 1]
		if {$valid == $byte} {
		    break
		} else {
		    puts stderr "Error at address $address wrote $byte read $valid"
		    incr nerrors
		    if {$nerrors > 10} {
			puts stderr "Too many errors;  giving up."
			break
		    }
		}
	    }

	    # Increment address in command
	    incr cmdword
	    incr address
	}
    }

    set status [ftdi::flash_status $device]
    if {[lindex $status 1] > 0} {
        puts stderr "Flash status register 2 returned error code [lindex $status 1]"
        puts stderr "Flash status register 1 value is [lindex $status 0]"
    } else {
        puts stdout "Finished writing data to flash."
    }

    # Apply write disable
    spi_write $device 4 {}

    close $hf
}

# Read back values from the flash memory

proc ftdi::read_flash {device start length {debug false}} {
    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Set command length to 4 bytes (1 byte command + 3 bytes address)
    spi_command $device 32

    # instruction 0x03 = read values w/3-byte address
    set cword [expr {0x03 << 24}]
    set cmdword [expr {$cword + $start}]

    if {$debug} {puts stdout "Diagnostic: read_flash: command word is $cmdword"}
    set memvals [spi_read $device $cmdword $length]
    spi_command $device 8
    return $memvals
}

# Write values into the flash memory (note: must be erased first)

proc ftdi::write_flash_values {device start values {debug false}} {
    # Check for device ready
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Apply write enable
    spi_write $device 6 {}

    # Set command length to 4 bytes (1 byte command + 3 bytes address)
    spi_command $device 32

    # instruction 0x02 = page program w/3-byte address
    set cword [expr {0x02 << 24}]
    set cmdword [expr {$cword + $start}]

    if {$debug} {
	puts stdout "Diagnostic: write_flash: command word is $cmdword"
    }
    spi_write $device $cmdword $values
    spi_command $device 8

    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }

    # Apply write disable
    spi_write $device 4 {}
}

# Erase the entire flash device

proc ftdi::erase_flash {device} {
    # Apply write enable
    spi_write $device 6 {}

    spi_write $device 96 {}

    puts stdout "Waiting for erase cycle to finish (takes approximately 1 minute). . ."
    # Check for program cycle finished
    while {[ftdi::flash_busy $device] > 0} {
	after 100
    }
    puts stdout "Erase cycle done."

    # Apply write disable
    spi_write $device 4 {}
}

setid 24592 1027
set flash [opendev -invert A]
spi_bitbang $flash {{CSB 3} {SDO 2} {SDI 1} {SCK 0} {USR0 4} {USR1 5} {USR2 6} {USR3 7}}
bitbang_word $flash 8
spi_speed $flash 1.0
spi_command $flash 8

# Check that the communcation to the SPI flash is working
if {[ftdi::flash_check $flash] != 0} {exit}

# Import main commands
namespace import ftdi::erase_flash ftdi::write_flash ftdi::flash_check
namespace import ftdi::enable_quad ftdi::set_latency

# Print a list of the main commands
puts stdout "SPI Flash commands:"
puts stdout ""
puts stdout "write_flash $flash <hexfile> \[<doerase> \[<debug>\]\]"
puts stdout "erase_flash $flash"
puts stdout "flash_check $flash"
puts stdout "enable_quad $flash"
puts stdout "set_latency $flash <value>"
puts stdout ""
