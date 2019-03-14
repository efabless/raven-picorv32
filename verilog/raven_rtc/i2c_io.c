#include "../raven_defs.h"

#define SDA_PIN 14
#define SCL_PIN 15
#define SCL_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~((unit32_t) 1 << SCL_PIN))
#define SCL_IN (volatile uint32_t) (reg_gpio_ena |= ((unit32_t) 1 << SCL_PIN))
#define SDA_OUT (volatile uint32_t) ((reg_gpio_ena) &= ~((unit32_t) 1 << SDA_PIN))
#define SDA_IN (volatile uint32_t) (reg_gpio_ena |= ((unit32_t) 1 << SDA_PIN))

#define SCL_HIGH (volatile uint32_t) (reg_gpio_data |= ((unit32_t) 1 << SCL_PIN))
#define SCL_LOW (volatile uint32_t) ((reg_gpio_data) &= ~((unit32_t) 1 << SCL_PIN))
#define SCL_READ (volatile uint32_t) (!!((reg_gpio_data) & ((unit32_t) 1 << SCL_PIN)))
#define SDA_HIGH (volatile uint32_t) (reg_gpio_data |= ((unit32_t) 1 << SDA_PIN))
#define SDA_LOW (volatile uint32_t) ((reg_gpio_data) &= ~((unit32_t) 1 << SDA_PIN))
#define SDA_READ (volatile uint32_t) (!!((reg_gpio_data) & ((unit32_t) 1 << SDA_PIN)))


void i2c_delay()
{
	for (int j = 0; j < 2; j++);
}

void i2c_start(void)
{
    /* i2c start condition, data line goes low when clock is high */
    SCL_OUT; SDA_OUT;
    SDA_HIGH;
    SCL_HIGH;
    i2c_delay();
    SDA_LOW;
    i2c_delay();
    SCL_LOW;
    i2c_delay();
}

void i2c_stop (void)
{
    /* i2c stop condition, clock goes high when data is low */
    SCL_OUT; SDA_OUT;
    SCL_LOW;
    SDA_LOW;
    i2c_delay();
    SCL_HIGH;
    i2c_delay();
    SDA_HIGH;
    i2c_delay();
}

volatile uint32_t clock()
{
    volatile uint32_t clk;
    volatile uint32_t data;

    SCL_HIGH;
    SCL_IN; clk = SCL_READ;

    // wait for clock to go high - clock stretching
    while (!clk)
        clk = SCL_READ;

    SDA_IN; data = SDA_READ;
    i2c_delay();
    SCL_OUT;
    SCL_LOW;
    SDA_OUT;
    return data;
}

volatile uint32_t i2c_write(volatile uint32_t data)
{
	int bits;

 	SDA_OUT;
 	/* 8 bits */
	for(bits = 0; bits < 8; bits++)
	{
	    if (data & (unit32_t) 0x0080)
		    SDA_HIGH;
		else
		    SDA_LOW;
        i2c_delay();
      	data  <<= 1;
		/* Generate clock for 8 data bits */
		clock();
	}
	return clock();
}

volatile uint32_t i2c_read(bool ack)
{
	volatile uint32_t data;
	int bits;

	data = 0x0000;
	/* 8 bits */
	for (bits = 0; bits < 8; bits++)
	{
		data <<= 1;
      	data |= clock();
	}

    SDA_OUT;
	if (ack) {
	    SDA_LOW;
	} else {
	    SDA_HIGH;
	}
	i2c_delay();
	clock();

   return data;
}

void write_i2c_slave(volatile uint32_t slave_addr, volatile uint32_t word_addr, volatile uint32_t data)
{
  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);
   	i2c_write(data);
   	i2c_stop();
}

volatile uint32_t read_i2c_slave_byte(volatile uint32_t slave_addr, volatile uint32_t word_addr)
{
   	volatile uint32_t data;

  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);

    i2c_start();
    i2c_write(slave_addr | (volatile uint32_t) 1);  // addr + read mode
	data = i2c_read(false);
	i2c_stop();

   	return data;
}

void read_i2c_slave_bytes(volatile uint32_t slave_addr, volatile uint32_t word_addr, volatile uint32_t *data, int len)
{
   	int i;

  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);

    i2c_start();
    i2c_write(slave_addr | (volatile uint32_t) 1);  // addr + read mode
    for (i = 0; i < len; i++)
	    data[i] = i2c_read(true);
	data[len] = i2c_read(false);
	i2c_stop();
}