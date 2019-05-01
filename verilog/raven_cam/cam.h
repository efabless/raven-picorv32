#ifndef CAM_H
#define CAM_H
#include "../raven_defs.h"

#define PROGMEM
#define SENSOR_ADDR             0x60  // I2C addresss for sensor

#define TEST_REG       	        0x00  //TEST register
#define MAX_FIFO_SIZE		    0x5FFFF	 // 384 KByte

#define ARDUCHIP_FIFO      		0x04  //FIFO and I2C control
#define FIFO_CLEAR_MASK    		0x01
#define FIFO_START_MASK    		0x02
#define FIFO_RDPTR_RST_MASK     0x10
#define FIFO_WRPTR_RST_MASK     0x20

#define ARDUCHIP_GPIO			  0x06  //GPIO Write Register

#define BURST_FIFO_READ			0x3C  //Burst FIFO read operation
#define SINGLE_FIFO_READ		0x3D  //Single FIFO read operation

#define ARDUCHIP_REV       		0x40  //ArduCHIP revision
#define VER_LOW_MASK       		0x3F
#define VER_HIGH_MASK      		0xC0

#define ARDUCHIP_TRIG      		0x41  //Trigger source
#define VSYNC_MASK         		0x01
#define SHUTTER_MASK       		0x02
#define CAP_DONE_MASK      		0x08

#define FIFO_SIZE1				0x42  //Camera write FIFO size[7:0] for burst to read
#define FIFO_SIZE2				0x43  //Camera write FIFO size[15:8]
#define FIFO_SIZE3				0x44  //Camera write FIFO size[18:16]

#define OV2640_CHIPID_HIGH 	    0x0A
#define OV2640_CHIPID_LOW 	    0x0B

//typedef unsigned char uint8_t;

struct sensor_reg {
	volatile uint32_t reg;
	volatile uint32_t val;
};

/****************************************************/
/* Sensor related definition 												*/
/****************************************************/
#define BMP 	0
#define JPEG	1
#define RAW	  2

#define OV2640  	5


#define OV2640_160x120 		0	//160x120
#define OV2640_176x144 		1	//176x144
#define OV2640_320x240 		2	//320x240
#define OV2640_352x288 		3	//352x288
#define OV2640_640x480		4	//640x480
#define OV2640_800x600 		5	//800x600
#define OV2640_1024x768		6	//1024x768
#define OV2640_1280x1024	7	//1280x1024
#define OV2640_1600x1200	8	//1600x1200



//Light Mode

#define Auto                    0
#define Sunny                   1
#define Cloudy                  2
#define Office                  3
#define Home                    4

#define Advanced_AWB            0
#define Simple_AWB              1
#define Manual_day              2
#define Manual_A                3
#define Manual_cwf              4
#define Manual_cloudy           5

//Color Saturation

#define Saturation4             0
#define Saturation3             1
#define Saturation2             2
#define Saturation1             3
#define Saturation0             4
#define Saturation_1            5
#define Saturation_2            6
#define Saturation_3            7
#define Saturation_4            8

//Brightness

#define Brightness4             0
#define Brightness3             1
#define Brightness2             2
#define Brightness1             3
#define Brightness0             4
#define Brightness_1            5
#define Brightness_2            6
#define Brightness_3            7
#define Brightness_4            8

//Contrast

#define Contrast4               0
#define Contrast3               1
#define Contrast2               2
#define Contrast1               3
#define Contrast0               4
#define Contrast_1              5
#define Contrast_2              6
#define Contrast_3              7
#define Contrast_4              8

#define degree_180              0
#define degree_150              1
#define degree_120              2
#define degree_90               3
#define degree_60               4
#define degree_30               5
#define degree_0                6
#define degree30                7
#define degree60                8
#define degree90                9
#define degree120               10
#define degree150               11

//Special effects

#define Antique                 0
#define Bluish                  1
#define Greenish                2
#define Reddish                 3
#define BW                      4
#define Negative                5
#define BWnegative              6
#define Normal                  7
#define Sepia                   8
#define Overexposure            9
#define Solarize                10
#define Blueish                 11
#define Yellowish               12

#define Exposure_17_EV                    0
#define Exposure_13_EV                    1
#define Exposure_10_EV                    2
#define Exposure_07_EV                    3
#define Exposure_03_EV                    4
#define Exposure_default                  5
#define Exposure03_EV                     6
#define Exposure07_EV                     7
#define Exposure10_EV                     8
#define Exposure13_EV                     9
#define Exposure17_EV                     10

#define Auto_Sharpness_default              0
#define Auto_Sharpness1                     1
#define Auto_Sharpness2                     2
#define Manual_Sharpnessoff                 3
#define Manual_Sharpness1                   4
#define Manual_Sharpness2                   5
#define Manual_Sharpness3                   6
#define Manual_Sharpness4                   7
#define Manual_Sharpness5                   8

#define Sharpness1                         0
#define Sharpness2                         1
#define Sharpness3                         2
#define Sharpness4                         3
#define Sharpness5                         4
#define Sharpness6                         5
#define Sharpness7                         6
#define Sharpness8                         7
#define Sharpness_auto                       8

#define EV3                                 0
#define EV2                                 1
#define EV1                                 2
#define EV0                                 3
#define EV_1                                4
#define EV_2                                5
#define EV_3                                6

#define MIRROR                              0
#define FLIP                                1
#define MIRROR_FLIP                         2

#define high_quality                         0
#define default_quality                      1
#define low_quality                          2

#define Color_bar                      0
#define Color_square                   1
#define BW_square                      2
#define DLI                            3

#define Night_Mode_On                  0
#define Night_Mode_Off                 1

#define Off                            0
#define Manual_50HZ                    1
#define Manual_60HZ                    2
#define Auto_Detection                 3

bool check_spi();
bool check_camera(uint32_t *vid, uint32_t *pid);
void reset_cpld();
void init_camera();

void flush_fifo(void);
void reset_fifo_read_ptr(void);
void start_capture(void);
void clear_fifo_flag(void);
uint8_t read_fifo(void);

uint8_t read_reg(uint32_t addr);
void write_reg(uint32_t addr, uint32_t data);

void write_sensor_reg(uint32_t addr, uint32_t data);
void write_sensor_reg_list(const struct sensor_reg reglist[]);
bool read_sensor_reg_list(const struct sensor_reg reglist[]);

void read_sensor_reg(uint32_t addr, uint32_t* data);

uint32_t read_fifo_length();
void set_frame_count();

bool set_JPEG_size(uint8_t size);
void set_Light_Mode(uint8_t Light_Mode);
void set_Color_Saturation(uint8_t Color_Saturation);
void set_Brightness(uint8_t Brightness);
void set_Contrast(uint8_t Contrast);
void set_Special_effects(uint8_t Special_effect);

extern const struct sensor_reg OV2640_JPEG_INIT[];
extern const struct sensor_reg OV2640_JPEG[];
extern const struct sensor_reg OV2640_YUV422[];
extern const struct sensor_reg OV2640_160x120_JPEG[];
extern const struct sensor_reg OV2640_320x240_JPEG[];
extern const struct sensor_reg OV2640_QVGA[];

#endif // CAM_H