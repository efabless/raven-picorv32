#ifndef SPI_IO_H
#define SPI_IO_H
#include "../raven_defs.h"

void write_spi_slave(volatile uint32_t slave_addr, volatile uint32_t data);
uint32_t read_spi_slave_byte(volatile uint32_t slave_addr);
void read_spi_slave_bytes(volatile uint32_t slave_addr, volatile uint32_t *data, int len);
void spi_init();
void spi_start();
void spi_stop();
void spi_write(volatile uint32_t data);
uint32_t spi_read();

#endif // SPI_IO_H