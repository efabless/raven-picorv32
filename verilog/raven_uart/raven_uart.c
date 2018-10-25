#include "../raven_defs.h"

// --------------------------------------------------------

void putchar(char c)
{
	if (c == '\n')
		putchar('\r');
	reg_uart_data = c;
}

void print(const char *p)
{
	while (*p)
		putchar(*(p++));
}

// --------------------------------------------------------

void main()
{
	// Set clock to 64 kbaud
	reg_uart_clkdiv = 625;

	// NOTE: Crystal is running in simulation at 5MHz
	// Internal clock is 8x crystal, or 40MHz
	// Divided by clkdiv is 64 kHz
	// So at this crystal rate, use clkdiv = 4167 for 9600 baud.

	// This should appear at the output, received by the testbench UART.
        print("\n");
        print("  ____  _          ____         ____\n");
        print(" |  _ \\(_) ___ ___/ ___|  ___  / ___|\n");
        print(" | |_) | |/ __/ _ \\___ \\ / _ \\| |\n");
        print(" |  __/| | (_| (_) |__) | (_) | |___\n");
        print(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
}

