#include "../raven_defs.h"

// --------------------------------------------------------

void main()
{
    int i;

    /* Test : toggle the GPIO pins once as the first action */
    reg_gpio_pu = 0x5a5a;
    reg_gpio_ena =  0xa5a5;

    reg_gpio_data = 0xffff;
    reg_gpio_data = 0x0000;

    /* loop test: cycle all GPIO periodically; continue indefinitely */
    while (1) {
	for (i = 0 ; i < 100000000; i++);
        reg_gpio_data = 0xffff;
	for (i = 0 ; i < 100000000; i++);
	reg_gpio_data = 0x0000;
    }
}

