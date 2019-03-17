TOOLCHAIN_PREFIX = /opt/riscv32imc/bin
# TOOLCHAIN_PREFIX = /ef/apps/bin

# ---- Test patterns for project raven ----

.SUFFIXES:

PATTERN = raven_demo

all:  ${PATTERN:=.vcd}

hex:  ${PATTERN:=.hex}

%.vvp: %_tb.v %.hex
	iverilog -I. -I..  $< -o $@

%.vcd: %.vvp
	vvp $<

%.elf: %.c ../sections.lds ../start.s
	$(TOOLCHAIN_PREFIX)riscv32-unknown-elf-gcc -march=rv32imc -Wl,-Bstatic,-T,../sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../start.s $<

%.hex: %.elf
	$(TOOLCHAIN_PREFIX)riscv32-unknown-elf-objcopy -O verilog $< /dev/stdout | sed -e '1 s/@00000000/@00100000/; 2,65537 d;' > $@

%.bin: %.elf
	$(TOOLCHAIN_PREFIX)riscv32-unknown-elf-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd

.PHONY: clean hex all

