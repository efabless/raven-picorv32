# ---- Test patterns for project raven ----

.SUFFIXES:

PATTERNS = raven_gpio raven_adc raven_dac raven_uart

all:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i && make $${i}.vcd ) ; \
	done

clean:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i && make clean ) ; \
	done

.PHONY: clean all
