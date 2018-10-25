#include "../raven_defs.h"

// --------------------------------------------------------

void main()
{
	int i;

	/* Test 1: toggle the GPIO pins once as the first action */

	reg_gpio_pu   = 0x5a5a;		// Add pullup to lines that are input
	reg_gpio_ena  = 0xa5a5;		// Assign GPIO outputs
	reg_gpio_data = 0xffff;		// Toggle GPIO outputs
	reg_gpio_data = 0x0000;

	/* Test 2: configure the ADC */

	reg_adc0_clk_source = 3;		/* external XCLK pin */
	reg_adc0_ena = 1;

	for (i = 0; i < 4; i++) {
	    reg_adc0_input_source = i;		/* choose each source in turn */
	    reg_adc0_convert = 1;		/* Start conversion */
	    reg_adc0_convert = 0;
	    while (1) {
		if (reg_adc0_done != 0) break;	/* Wait for EOC */
	    }
	}
}

