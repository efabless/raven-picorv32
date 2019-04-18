#ifndef I2C_IO_H
#define I2C_IO_H

extern void write_i2c_slave(uint32_t slave_addr, uint32_t word_addr, uint32_t data);
extern uint32_t read_i2c_slave_byte(uint32_t slave_addr, uint32_t word_addr);
extern void read_i2c_slave_bytes(uint32_t slave_addr, uint32_t word_addr, uint32_t *data, int len);
extern void i2c_init();
extern void i2c_start();
extern void i2c_stop();
extern uint32_t i2c_write(volatile uint32_t data);
extern uint32_t i2c_read(bool ack);

#define RTC_I2C_ADDR (uint32_t) 0xA2 // RTC PCF8563
//#define RTC_I2C_ADDR (uint32_t)0xD0 // RTC DS3231

#endif // I2C_IO_H