#include "../raven_defs.h"

#define SDA_PIN (uint32_t) (1 << 14) // bit 14
#define SCL_PIN (uint32_t) (1 << 15) // bit 15

#define SCL_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~(SCL_PIN))
#define SCL_IN (volatile uint32_t) (reg_gpio_ena |= (SCL_PIN))
#define SDA_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~(SDA_PIN))
#define SDA_IN (volatile uint32_t) (reg_gpio_ena |= (SDA_PIN))

//#define SCL_HIGH (volatile uint32_t) (reg_gpio_data |= (SCL_PIN))
#define SCL_HIGH SCL_IN
#define SCL_LOW SCL_OUT; (volatile uint32_t) ((reg_gpio_data) &= ~(SCL_PIN))
#define SCL_READ (volatile uint32_t) (!!((reg_gpio_data) & (SCL_PIN)))
//#define SDA_HIGH (volatile uint32_t) (reg_gpio_data |= (SDA_PIN))
#define SDA_HIGH SDA_IN
#define SDA_LOW SDA_OUT; (volatile uint32_t) ((reg_gpio_data) &= ~(SDA_PIN))
#define SDA_READ (volatile uint32_t) (!!((reg_gpio_data) & (SDA_PIN)))

extern void print_ln(const char *p);
extern void putchar(char c);

void i2c_delay()
{

//  100k BAUD (I2C standard) = 5 usec
//	for (int j = 0; j < 1000000; j++);  // 5 secs
//	for (int j = 0; j < 200000; j++);  // 1 secs
//	for (int j = 0; j < 100000; j++);  // 0.5 secs
	for (int j = 0; j < 2; j++);  // 10 usec
}

void i2c_init()
{
    SDA_HIGH;
    SCL_HIGH;
    i2c_delay();
}

void i2c_start()
{
    /* i2c start condition, data line goes low when clock is high */
//    SCL_OUT; SDA_OUT;
//    print_ln("i2c_start()...");
    SDA_HIGH;
    SCL_HIGH;
    i2c_delay();
    SDA_LOW;
    i2c_delay();
    SCL_LOW;
    i2c_delay();
}

void i2c_stop ()
{
    /* i2c stop condition, clock goes high when data is low */
//    SCL_OUT; SDA_OUT;
//    SCL_LOW;
//    print_ln("i2c_stop()...");
    SDA_LOW;
    i2c_delay();
    SCL_HIGH;
    i2c_delay();
    SDA_HIGH;
    i2c_delay();
}

void i2c_write_bit(volatile uint32_t b)
{
    volatile uint32_t clk;

    if ( b > 0 )
        SDA_HIGH;
    else
        SDA_LOW;

    i2c_delay();

    SCL_HIGH;

    // clock stretching
    SCL_IN; clk = SCL_READ;
    while (!clk)
        clk = SCL_READ;

    i2c_delay();
    SCL_LOW;

}

volatile uint32_t i2c_read_bit()
{

    volatile uint32_t b;
    volatile uint32_t clk;

    SDA_HIGH;
    i2c_delay();
    SCL_HIGH;

    // clock stretching
    SCL_IN; clk = SCL_READ;
    while (!clk)
        clk = SCL_READ;

    i2c_delay();

    SDA_IN; if ( SDA_READ)
        b = 1;
    else
        b = 0;

    SCL_LOW;

    return b;
}

volatile uint32_t clock()
{
    volatile uint32_t clk;
    volatile uint32_t data;

    print_ln("clock()...");
    SCL_HIGH;
    SCL_IN; clk = SCL_READ;

    // wait for clock to go high - clock stretching
    while (!clk)
        clk = SCL_READ;

    i2c_delay();
    SDA_IN; data = SDA_READ;
//    SCL_OUT;
    SCL_LOW;
//    SDA_OUT;
    return data;
}

bool i2c_write(volatile uint32_t data)
{
    uint32_t ack;

//    print_ln("i2c_write()...");
    putchar('*');
 	/* 8 bits */
	for (int i = 0; i < 8; i++)
	{
	    i2c_write_bit(data & (uint32_t) 0x0080);
      	data  <<= 1;
	}

	ack = i2c_read_bit();

	return ack;
}

volatile uint32_t i2c_read(bool ack)
{
	volatile uint32_t data;

    print_ln("i2c_read()...");
	data = 0x0000;
	for (int i = 0; i < 8; i++)
	{
		data <<= 1;
      	data |= i2c_read_bit();
	}

	if (ack)
	    i2c_write_bit(0);
	else
	    i2c_write_bit(1);

   return data;
}

void write_i2c_slave(volatile uint32_t slave_addr, volatile uint32_t word_addr, volatile uint32_t data)
{
    print_ln("write_i2c_slave()...");
  	i2c_start();
   	if (!i2c_write(slave_addr)) print_ln("** error **");
    if (!i2c_write(word_addr)) print_ln("** error **");
   	i2c_write(data);
   	i2c_stop();
}

uint32_t read_i2c_slave_byte(volatile uint32_t slave_addr, volatile uint32_t word_addr)
{
   	volatile uint32_t data;

    print_ln("read_i2c_slave_byte()...");
  	i2c_start();
   	if (!i2c_write(slave_addr)) print_ln("** error **");
    if (!i2c_write(word_addr)) print_ln("** error **");

    i2c_start();
    i2c_write(slave_addr | (uint32_t) 0x0001);  // addr + read mode
	data = i2c_read(false);
	i2c_stop();

   	return data;
}

void read_i2c_slave_bytes(volatile uint32_t slave_addr, volatile uint32_t word_addr, volatile uint32_t *data, int len)
{
   	int i;

    print_ln("read_i2c_slave_bytes()...");
  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);

    i2c_start();
    i2c_write(slave_addr | (uint32_t) 0x0001);  // addr + read mode
    for (i = 0; i < len-1; i++)
	    data[i] = i2c_read(true);
	data[len-1] = i2c_read(false);
	i2c_stop();
}