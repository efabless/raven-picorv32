#include "../raven_defs.h"

#define SDA_PIN 13
#define SCL_PIN 14

#define SCL_HIGH (reg_gpio_data |= (1U << SCL_PIN))
#define SCL_LOW ((reg_gpio_data) &= ~(1U << (SCL_PIN)))
#define SCL_READ (!!((reg_gpio_data) & (1U << (SCL_PIN))))
#define SDA_HIGH (reg_gpio_data |= (1U << SDA_PIN))
#define SDA_LOW ((reg_gpio_data) &= ~(1U << (SDA_PIN)))
#define SDA_READ (!!((reg_gpio_data) & (1U << (SDA_PIN))))


void i2c_delay()
{
}

void i2c_start(void)
{
    /* i2c start condition, data line goes low when clock is high */
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
    SCL_LOW;
    SDA_LOW;
    i2c_delay();
    SCL_HIGH;
    i2c_delay();
    SDA_HIGH;
    i2c_delay();
}

bool clock()
{
    bool clk;
    bool in_data;

    SCL_HIGH;
    clk = SCL_READ;

    // wait for clock to go high - clock stretching
    while (!clk)
        clk = SCL_READ;

    in_data = SDA_READ;
    i2c_delay();
    SCL_LOW;
    return in_data;
}

bool i2c_write(unsigned char data)
{
	unsigned char outBits;
	unsigned char inBit;

 	/* 8 bits */
	for(outBits = 0; outBits < 8; outBits++)
	{
	    if(data & 0x80)
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

unsigned char i2c_read(bool ack)
{
	unsigned char inData, inBits;

	inData = 0x00;
	/* 8 bits */
	for(inBits = 0; inBits < 8; inBits++)
	{
		inData <<= 1;
      	inData |= clock();
	}

	if (ack) {
	    SDA_LOW;
	} else {
	    SDA_HIGH;
	}
	i2c_delay();
	clock();

   return inData;
}

void write_i2c_slave(unsigned char slave_addr, unsigned char word_addr, unsigned char data)
{
  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);
   	i2c_write(data);
   	i2c_stop();
}

unsigned char read_i2c_slave_byte(unsigned char slave_addr, unsigned char word_addr)
{
   	unsigned char inData;

  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);

    i2c_start();
    i2c_write(slave_addr | 1);  // addr + read mode
	inData = i2c_read(false);
	i2c_stop();

   	return inData;
}

unsigned char * read_i2c_slave_bytes(unsigned char slave_addr, unsigned char word_addr, int n_bytes)
{
   	unsigned char inData[n_bytes];
   	int i;

  	i2c_start();
   	i2c_write(slave_addr);
   	i2c_write(word_addr);

    i2c_start();
    i2c_write(slave_addr | 1);  // addr + read mode
    for (i = 0; i < n_bytes; i++)
	    inData[i] = i2c_read(true);
	inData[n_bytes] = i2c_read(false);
	i2c_stop();

   	return inData;
}