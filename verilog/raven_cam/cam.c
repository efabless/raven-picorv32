#include "cam.h"
#include "spi_io.h"
#include "i2c_io.h"

void _delay_ms(int v) {
    for (j = 0; j < 170 * v; j++);
}

bool check_spi() {
    // test spi with write and read from test register
    write_spi_slave(0x00, 0x55);
    data = read_spi_slave_byte(0x00);
    if (data == 0x55) {
        return true;
    }
    return false;
}

bool check_camera() {
    uint8_t vid, pid;
    write_sensor_reg(0xff, 0x01);
    read_sensor_reg(OV2640_CHIPID_HIGH, &vid);
    read_sensor_reg(OV2640_CHIPID_LOW, &pid);
    if ((vid != 0x26 ) && (( pid != 0x41 ) || ( pid != 0x42 )))
        return false;
    else
        return true;
}

void reset_cpld() {
    write_reg(0x07, 0x80);
    _delay_ms(1000);
    write_reg(0x07, 0x00);
    _delay_ms(1000);
}

void init_camera() {
    write_sensor_reg(0xff, 0x01);
    write_sensor_reg(0x12, 0x80);
    _delay_ms(1000);

    write_sensor_reg_list(OV2640_JPEG_INIT);
    write_sensor_reg_list(OV2640_YUV422);
    write_sensor_reg_list(OV2640_JPEG);
    write_sensor_reg(0xff, 0x01);
    write_sensor_reg(0x15, 0x00);
    write_sensor_reg_list(OV2640_160x120_JPEG);
//    write_sensor_reg_list(OV2640_320x240_JPEG);
    //write_sensor_reg(0xff, 0x00);
    //write_sensor_reg(0x44, 0x32);

//    write_sensor_reg_list(OV2640_QVGA);

}

void flush_fifo(void) {
	write_reg(ARDUCHIP_FIFO, FIFO_CLEAR_MASK);
}

void start_capture(void) {
	write_reg(ARDUCHIP_FIFO, FIFO_START_MASK);
}

void clear_fifo_flag(void) {
	write_reg(ARDUCHIP_FIFO, FIFO_CLEAR_MASK);
}

uint8_t read_fifo(void) {}

uint8_t read_reg(uint8_t addr) {
    return read_spi_slave_byte(addr);
}

void write_reg(uint8_t addr, uint8_t data) {
    write_spi_slave(addr, data);
}

void write_sensor_reg(uint8_t addr, uint8_t data) {
    write_i2c_slave(SENSOR_ADDR, addr, data);
}

void write_sensor_reg_list(const struct sensor_reg reglist[]) {
    uint16_t reg_addr = 0;
    uint16_t reg_val = 0;
    const struct sensor_reg *next = reglist;
    while ((reg_addr != 0xff) | (reg_val != 0xff))
    {
        reg_addr = &next->reg;
        reg_val = &next->val;
        write_sensor_reg(reg_addr, reg_val);
        next++;
    }
}

void read_sensor_reg(uint8_t addr, uint8_t* data) {
    data = read_i2c_slave_byte(SENSOR_ADDR, addr);
}

uint32_t read_fifo_length()
{
	uint32_t len1,len2,len3,length=0;
	len1 = read_reg(FIFO_SIZE1);
    len2 = read_reg(FIFO_SIZE2);
    len3 = read_reg(FIFO_SIZE3) & 0x7f;
    length = ((len3 << 16) | (len2 << 8) | len1) & 0x07fffff;
	return length;
}

void set_JPEG_size(uint8_t size) {
    write_sensor_reg_list(OV2640_160x120_JPEG);
}

void set_Light_Mode(uint8_t Light_Mode) {}
void set_Color_Saturation(uint8_t Color_Saturation) {}
void set_Brightness(uint8_t Brightness) {}
void set_Contrast(uint8_t Contrast) {}
void set_Special_effects(uint8_t Special_effect) {}