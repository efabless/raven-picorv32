#ifndef SPI_IO_H
#define SPI_IO_H

void write_spi_slave(uint32_t slave_addr, uint32_t data);
uint32_t read_spi_slave_byte(uint32_t slave_addr);
void read_spi_slave_bytes(uint32_t slave_addr, uint32_t *data, int len);
void spi_init();
void spi_start();
void spi_stop();
uint32_t spi_write(volatile uint32_t data);
uint32_t spi_read();

#endif // SPI_IO_H