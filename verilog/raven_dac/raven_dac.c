#include "../raven_defs.h"

// --------------------------------------------------------

void main()
{
	unsigned int i;

	/* Test 1: toggle the GPIO pins once as the first action */

	reg_gpio_pu   = 0x5a5a;		// Add pullup to lines that are input
	reg_gpio_ena  = 0xa5a5;		// Assign GPIO outputs
	reg_gpio_data = 0xffff;		// Toggle GPIO outputs
	reg_gpio_data = 0x0000;

	/* Test 2a: enable the bandgap.

	/* Test 2b: configure the op-amp, and set to buffer the bandgap */

	reg_analog_out_sel = 1;
	reg_analog_out_bias_ena  = 1;
	reg_analog_out_ena = 1;

	/* Test 3: configure the DAC */

	reg_analog_out_sel = 0;

	reg_dac_ena = 1;

	for (i = 0; i <= 1020; i += 10) {
	    reg_dac_data = i;
	}
}

