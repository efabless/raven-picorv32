TOOLCHAIN_PATH = /opt/riscv32imc/bin/
# TOOLCHAIN_PATH = /ef/apps/bin/

# ---- Test patterns for project raven ----

.SUFFIXES:

PATTERN = raven_cam

all:  ${PATTERN:=.vcd}

hex:  ${PATTERN:=.hex}

%.vvp: %_tb.v %.hex
	iverilog -I ../../../ip \
	-I ../../../ip/raven_soc/11/verilog/source \
	$< -o $@

%.vcd: %.vvp
	vvp $<

%.elf: %.c ../sections.lds ../start.s i2c_io.c spi_io.c
	$(TOOLCHAIN_PATH)riscv32-unknown-elf-gcc -march=rv32imc -Wl,-Bstatic,-T,../sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../start.s i2c_io.c spi_io.c $<

%.hex: %.elf
	$(TOOLCHAIN_PATH)riscv32-unknown-elf-objcopy -O verilog $< /dev/stdout | sed -e '1 s/@00000000/@00100000/; 2,65537 d;' > $@

%.bin: %.elf
	$(TOOLCHAIN_PATH)riscv32-unknown-elf-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd

.PHONY: clean hex all

