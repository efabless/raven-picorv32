#include "../raven_defs.h"

typedef struct
{
  unsigned int bit0:1;
  unsigned int bit1:1;
  unsigned int bit2:1;
  unsigned int bit3:1;
  unsigned int bit4:1;
  unsigned int bit5:1;
  unsigned int bit6:1;
  unsigned int bit7:1;
} Port;

#define PORT0 *(volatile Port *) reg_gpio_data

/* Define the port used for I2C data and clk as shown above to access them pin wise */
#define I2C_DATA PORT0.bit0
#define I2C_CLK  PORT0.bit1

#define I2C_SLAVE_ADDR (unsigned char) 0xA2

#define SCL_HIGH (reg_gpio_data |= (1U << 14))
#define SCL_LOW ((reg_gpio_data) &= ~(1U << (14)))
#define SCL_CHECK (!!((reg_gpio_data) & (1U << (14))))
#define SDA_HIGH (reg_gpio_data |= (1U << 15))
#define SDA_LOW ((reg_gpio_data) &= ~(1U << (15)))
#define SDA_CHECK (!!((reg_gpio_data) & (1U << (15))))

void i2c_start(void)
{
    /* I2C Start condition, data line goes low when clock is high */
    SDA_HIGH;
    SCL_HIGH;
    SDA_LOW;
    SCL_LOW;
}

void i2c_stop (void)
{
    /* I2C Stop condition, clock goes high when data is low */
    SCL_LOW;
    SDA_LOW;
    SCL_HIGH;
    SDA_HIGH;
}

void i2c_write(unsigned char data)
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
      	data  <<= 1;
		/* Generate clock for 8 data bits */
		SCL_HIGH;
		SCL_LOW;
	}

	/* Generate clock for ACK */
	SCL_HIGH;
        /* Wait for clock to go high, clock stretching */
        while(SCL_CHECK);
        /* Clock high, valid ACK */
	inBit = SDA_CHECK;
	SCL_LOW;
}

unsigned char i2c_read(void)
{
	unsigned char inData, inBits;

	inData = 0x00;
	/* 8 bits */
	for(inBits = 0; inBits < 8; inBits++)
	{
		inData <<= 1;
		SCL_HIGH;
      	inData |= SDA_CHECK;
		SCL_LOW;
	}

   return inData;
}

void write_i2c_slave(unsigned char addr, unsigned char ctl, unsigned char data)
{
    /* Start */
  	i2c_start();
	/* Slave address */
   	i2c_write(addr);
	/* Slave control byte */
   	i2c_write(0xBB);
	/* Slave data */
   	i2c_write(data);
	/* Stop */
   	i2c_stop();
}

unsigned char read_i2c_slave(unsigned char addr, unsigned char ctl)
{
   	unsigned char inData;

	/* Start */
  	i2c_start();
	/* Slave address */
   	i2c_write(addr);
	/* Slave control byte */
   	i2c_write(ctl);
	/* Stop */
   	i2c_stop();

	/* Start */
   	i2c_start();
	/* Slave address + read */
   	i2c_write(addr | 1);
	/* Read */
	inData = i2c_read();

   	return inData;
}