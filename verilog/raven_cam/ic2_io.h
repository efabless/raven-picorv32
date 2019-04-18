#ifndef I2C_IO_H
#define I2C_IO_H

#define RTC_I2C_ADDR (uint32_t) 0xA2 // RTC PCF8563
//#define RTC_I2C_ADDR (uint32_t)0xD0 // RTC DS3231

void write_i2c_slave(uint32_t slave_addr, uint32_t word_addr, uint32_t data);
uint32_t read_i2c_slave_byte(uint32_t slave_addr, uint32_t word_addr);
void read_i2c_slave_bytes(uint32_t slave_addr, uint32_t word_addr, uint32_t *data, int len);
void i2c_init();
void i2c_start();
void i2c_stop();
uint32_t i2c_write(volatile uint32_t data);
uint32_t i2c_read(bool ack);

#endif // I2C_IO_H