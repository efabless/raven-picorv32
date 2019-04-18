#include "../raven_defs.h"

#define CS_PIN (uint32_t) (1 << 8) // bit 8
#define SDI_PIN (uint32_t) (1 << 9) // bit 9
#define SDO_PIN (uint32_t) (1 << 10) // bit 10
#define SCK_PIN (uint32_t) (1 << 11) // bit 11

#define SDI_IN (volatile uint32_t) (reg_gpio_ena |= (SDI_PIN))
#define SDO_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~(SDO_PIN))
#define SCK_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~(SCK_PIN))
#define CS_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~(CS_PIN))

#define CS_LOW (volatile uint32_t) ((reg_gpio_data) &= ~(CS_PIN))
#define CS_HIGH (volatile uint32_t) ((reg_gpio_data) |= (CS_PIN))
#define SCK_LOW (volatile uint32_t) ((reg_gpio_data) &= ~(SCK_PIN))
#define SCK_HIGH (volatile uint32_t) ((reg_gpio_data) |= (SCK_PIN))
#define SDI_READ (volatile uint32_t) ((reg_gpio_data) & (SDI_PIN))
#define SDO_LOW (volatile uint32_t) ((reg_gpio_data) &= ~(SDO_PIN))
#define SDO_HIGH (volatile uint32_t) ((reg_gpio_data) |= (SDO_PIN))

extern void print_ln(const char *p);
extern void putchar(char c);

void spi_delay()
{
//	for (int j = 0; j < 200000; j++);  // 1 secs
//	for (int j = 0; j < 100000; j++);  // 0.5 secs
//	for (int j = 0; j < 100; j++);  // ~23 usec (measured)
	for (int j = 0; j < 2; j++);  // ~23 usec (measured)
//	for (int j = 0; j < 1; j++);  // ~23 usec (measured)
}

void spi_init()
{
    // disable internal pull-up and pull-down resistors
    reg_gpio_pu |= SDI_PIN & SDO_PIN & SCK_PIN & CS_PIN;
    reg_gpio_pd |= SDI_PIN & SDO_PIN & SCK_PIN & CS_PIN;

    reg_gpio_pd &= ~(CS_PIN);  // enable pull-down on select

    SDI_IN;
    SDO_OUT;
    SCK_OUT;
    CS_OUT;

    SCK_LOW;
    CS_HIGH;
}

void spi_start()
{
    CS_LOW;
    spi_delay();
}

void spi_stop()
{
    CS_HIGH;
    spi_delay();
}

void spi_write_bit(volatile uint32_t b)
{
    // mode = 0 (CPOL = 0, CPHA = 0)
    if ( b > 0 ) {
        SDO_HIGH;
    } else {
        SDO_LOW;
    }

    SCK_HIGH;
    spi_delay();
    SCK_LOW;
    spi_delay();
}

volatile uint32_t spi_read_bit()
{

    volatile uint32_t b;

    SDO_HIGH;
    spi_delay();
    SCK_HIGH;

    SDI_IN;
    if (SDI_READ)
        b = 1;
    else
        b = 0;

    SDO_LOW;
    SCK_LOW;

    return b;
}

void spi_write(volatile uint32_t data)
{
 	/* 8 bits */
	for (int i = 0; i < 8; i++)
	{
	    spi_write_bit(data & (uint32_t) 0x0080);
      	data  <<= 1;
	}
}

volatile uint32_t spi_read()
{
	volatile uint32_t data;

	data = 0x0000;
	for (int i = 0; i < 8; i++)
	{
		data <<= 1;
      	data |= spi_read_bit();
	}

   return data;
}

void write_spi_slave(volatile uint32_t slave_addr, volatile uint32_t data)
{
  	spi_start();
   	spi_write(slave_addr | (uint32_t) 0x0080);  // MSB set for write
//   	spi_write(slave_addr);
   	spi_write(data);
   	spi_stop();
}

uint32_t read_spi_slave_byte(volatile uint32_t slave_addr)
{
   	volatile uint32_t data;

  	spi_start();
   	spi_write(slave_addr); // MSB clear for write
	data = spi_read();
	spi_stop();

   	return data;
}

void read_spi_slave_bytes(volatile uint32_t slave_addr, volatile uint32_t *data, int len)
{
   	int i;

  	spi_start();
   	spi_write(slave_addr);

    spi_start();
    spi_write(slave_addr | (uint32_t) 0x0001);  // addr + read mode
    for (i = 0; i < len-1; i++)
	    data[i] = spi_read(true);
	data[len-1] = spi_read(false);
	spi_stop();
}