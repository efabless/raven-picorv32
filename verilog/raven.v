/*
 *  raven - A full example SoC using PicoRV32 in X-Fab XH018
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Tim Edwards <tim@efabless.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1 ns / 1 ps

`ifndef LVS

// efabless IP
// Synthesizable verilog components
`include "raven_soc.v"
`include "raven_spi.v"
`include "spi_slave.v"
// Functional verilog components
`include "AMUX2_3V.v"
`include "AMUX4_3V.v"
`include "LS_3VX2.v"
// X-Fab SRAM (simple functional stand-in)
`include "XSPRAM_1024X32_M8P.v"

// PDK IP

// 3.3V digital standard cells
// (functional stand-in)
`include "D_CELLS_3V.v"

// 1.8V core / 3.3V I/O padframe cells
// (functional stand-in)
`include "IO_CELLS_F3V.v"
 
// 3.3V core / 3.3V I/O padframe cells (isolate from 1.8V core cells!)
// (functional stand-in)
`include "IO_CELLS_FC3V.v"

// 1.8V Analog cells
`include "apllc03_1v8.v"
`include "acsoc04_1v8.v"

// 3.3V Analog cells
`include "atmpc01_3v3.v"
`include "aadcc01_3v3.v"
`include "adacc01_3v3.v"
`include "aopac01_3v3.v"
`include "abgpc01_3v3.v"
`include "acmpc01_3v3.v"
`include "axtoc02_3v3.v"
`include "arcoc01_3v3.v"
`include "aregc01_3v3.v"
`include "aporc02_3v3.v"
`include "acsoc01_3v3.v"
`include "acsoc02_3v3.v"

`endif

// Primitive devices (for LVS, and need (empty) model to prevent error on simulation).
`include "cmm5t.v"

// raven, a picosoc implementation in X-Fab XH018

module raven (
	// Padframe I/O
	input  real VDD3V3,	// 3V power supply
	output real VDD1V8,	// 1.8V from regulator (for external cap)
	input  real VSS,	// ground

	// Crystal
	input  real XI,	// Crystal oscillator in
	output real XO,	// Crystal oscillator out
	input  XCLK,	// External clock (PLL bypass mode)

	// SPI
	input  SDI,	// SPI controller data in
	output SDO,	// SPI controller data out
	input  CSB,	// SPI controller select
	input  SCK,	// SPI controller clock

	// UART
	output ser_tx,	// uart transmit
	input  ser_rx,	// uart receive

	// IRQ
	input  irq,	// dedicated IRQ pin

	// GPIO
	output [15:0] gpio,	// general-purpose I/O

	// Flash
	output flash_csb,	// SPI flash memory
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3,

	// Analog I/O
	input real adc_high,
	input real adc_low,
	input real adc0_in,
	input real adc1_in,

	output real analog_out,	// test analog port (multiplexed, buffered)

	input real comp_inp,
	input real comp_inn
);
	wire dground;
	wire reset;
	wire resetn;
	wire clk;
	wire irq;

	wire flash_io0_oeb, flash_io0_do, flash_io0_di;
	wire flash_io1_oeb, flash_io1_do, flash_io1_di;
	wire flash_io2_oeb, flash_io2_do, flash_io2_di;
	wire flash_io3_oeb, flash_io3_do, flash_io3_di;

	wire [15:0] gpio_in_core;
	wire [15:0] gpio_out_core;
	wire 	    irq_pin_core;
	wire	    flash_csb_core;
	wire	    flash_clk_core;
	wire	    ser_rx_core;
	wire	    ser_tx_core;

	/* Analog values represented by reals */
	wire real VDD3V3;
	wire real VDD1V8;
	wire real VSS;

	wire real adc_high;
	wire real adc_low;
	wire real adc0_in;
	wire real adc1_in;
	wire real analog_out;
	wire real comp_inp;
	wire real comp_inn;

	// Declare bus widths 
	wire [15:0] gpio_pullup;
	wire [15:0] gpio_pulldown;
	wire [15:0] gpio_outenb;
	wire [9:0]  adc0_data;
	wire [1:0]  adc0_inputsrc;
	wire [9:0]  adc1_data;
	wire [1:0]  adc1_inputsrc;
	wire [9:0]  dac_value;
	wire [1:0]  comp_ninputsrc;
	wire [1:0]  comp_pinputsrc;
	wire [7:0]  spi_config;
	wire [3:0]  spi_pll_trim;
	wire [11:0] spi_mfgr_id;
	wire [7:0]  spi_prod_id;
	wire [3:0]  spi_mask_rev;

	// Declare level-shifted signals

	wire spi_trap_3v;

	wire SCK_core_lv;

	wire spi_pll_vco_ena_lv;
	wire spi_pll_cp_ena_lv;
	wire spi_pll_bias_ena_lv;
	wire [3:0] spi_pll_trim_lv;
	wire spi_irq_lv;
	wire spi_reset_lv;
	wire spi_pll_bypass_lv;
 	wire [7:0] spi_config_lv;
 	wire spi_xtal_ena_lv;
 	wire spi_reg_ena_lv;
 	wire [11:0] spi_mfgr_id_lv;
 	wire [7:0] spi_prod_id_lv;
 	wire [3:0] spi_mask_rev_lv;

	wire adc0_ena_3v, adc0_clk_3v, adc0_convert_3v;
	wire adc0_done_lv;
	wire [9:0] adc0_data_lv;
	wire adc1_ena_3v, adc1_clk_3v, adc1_convert_3v;
	wire adc1_done_lv;
	wire [9:0] adc1_data_lv;

	wire [9:0] dac_value_3v;
	wire dac_ena_3v;
	wire opamp_ena_3v;
	wire opamp_bias_ena_3v;
	wire bg_ena_3v;
	wire comp_out_lv;
	wire comp_ena_3v;
	wire xtal_out_lv;
	wire rcosc_ena_3v;
	wire rcosc_out_lv;
	wire reset_lv;
	wire overtemp_ena_3v;
	wire overtemp_lv;

	/* Padframe pads */

	/* Analog input/output pads */
	APR00DF adc0_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(adc0_in),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	APR00DF adc1_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(adc1_in),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	APR00DF adc_low_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(adc_low),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	APR00DF adc_high_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(adc_high),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	APR00DF ana_out_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(analog_out),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	APR00DF comp_inn_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(comp_inn),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	APR00DF comp_inp_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .PAD(comp_inp),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	/* Power supplies (there are multiple pads that need to be represented) */

	VDDORPADF vddor_pad [4:0] (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .VDD(VDD1V8),
	   .VDDOR(VDD3V3)
	);

	VDDPADF vdd_pad [1:0] (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	VDDPADFC vdd3_pad (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .VDD3(VDD3V3),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	GNDORPADF gndor_pad [6:0] (
	   .GNDOR(VSS),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	CORNERESDF padframe_corner [3:0] (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	/* Custom-designed power cut cell isolates the VDD3 and VDD buses */

	POWERCUTVDD3FC pwr_cut [1:0] (
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

        /* Implement bidirectional I/O with X-Fab pads */
        /* See: /ef/tech/XFAB.3/EFXH018D/libs.ref/verilog/IO_CELLS_3V/IO_CELLS_3V.v */

	BBC4F flash_io_buf_3 (
		.PAD(flash_io3),
		.EN(flash_io3_oeb),
		.A(flash_io3_do),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(flash_io3_di)
	);

	BBC4F flash_io_buf_2 (
		.PAD(flash_io2),
		.EN(flash_io2_oeb),
		.A(flash_io2_do),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(flash_io2_di)
	);

	BBC4F flash_io_buf_1 (
		.PAD(flash_io1),
		.EN(flash_io1_oeb),
		.A(flash_io1_do),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(flash_io1_di)
	);

	BBC4F flash_io_buf_0 (
		.PAD(flash_io0),
		.EN(flash_io0_oeb),
		.A(flash_io0_do),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(flash_io0_di)
	);

	/* Standalone SPI controller (3V) */
	ICFC sck_buf (
		.PAD(SCK),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD3(VDD3V3),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(SCK_core)
	);

	ICFC csb_buf (
		.PAD(CSB),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD3(VDD3V3),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(CSB_core)
	);

	ICFC sdi_buf (
		.PAD(SDI),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD3(VDD3V3),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(SDI_core)
	);

	BT4FC sdo_buf (
		.PAD(SDO),
		.EN(sdo_enb),
		.A(SDO_core),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD3(VDD3V3),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3)
	);

	/* Implement digital input on irq dedicated pin */
	ICF irq_buf (
		.PAD(irq),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(irq_pin_core)
	);

	/* Implement digital input on ser_rx */
	ICF ser_rx_buf (
		.PAD(ser_rx),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(ser_rx_core)
	);

	/* Implement digital outputs on ser_tx, LEDs, csb, and clk */
	BT4F ser_tx_buf (
		.PAD(ser_tx),
		.EN(dground),
		.A(ser_tx_core),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3)
	);

	// GPIO is digital bidirectional buffer with selectable pull-up and pull-down

	BBCUD4F GPIO_buf_15 (
		.A(gpio_out_core[15]),
		.EN(gpio_outenb[15]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[15]),
		.PDEN(gpio_pulldown[15]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[15]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[15])
	);

	BBCUD4F GPIO_buf_14 (
		.A(gpio_out_core[14]),
		.EN(gpio_outenb[14]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[14]),
		.PDEN(gpio_pulldown[14]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[14]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[14])
	);

	BBCUD4F GPIO_buf_13 (
		.A(gpio_out_core[13]),
		.EN(gpio_outenb[13]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[13]),
		.PDEN(gpio_pulldown[13]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[13]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[13])
	);

	BBCUD4F GPIO_buf_12 (
		.A(gpio_out_core[12]),
		.EN(gpio_outenb[12]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[12]),
		.PDEN(gpio_pulldown[12]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[12]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[12])
	);

	BBCUD4F GPIO_buf_11 (
		.A(gpio_out_core[11]),
		.EN(gpio_outenb[11]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[11]),
		.PDEN(gpio_pulldown[11]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[11]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[11])
	);

	BBCUD4F GPIO_buf_10 (
		.A(gpio_out_core[10]),
		.EN(gpio_outenb[10]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[10]),
		.PDEN(gpio_pulldown[10]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[10]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[10])
	);

	BBCUD4F GPIO_buf_9 (
		.A(gpio_out_core[9]),
		.EN(gpio_outenb[9]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[9]),
		.PDEN(gpio_pulldown[9]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[9]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[9])
	);

	BBCUD4F GPIO_buf_8 (
		.A(gpio_out_core[8]),
		.EN(gpio_outenb[8]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[8]),
		.PDEN(gpio_pulldown[8]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[8]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[8])
	);

	BBCUD4F GPIO_buf_7 (
		.A(gpio_out_core[7]),
		.EN(gpio_outenb[7]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[7]),
		.PDEN(gpio_pulldown[7]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[7]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[7])
	);

	BBCUD4F GPIO_buf_6 (
		.A(gpio_out_core[6]),
		.EN(gpio_outenb[6]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[6]),
		.PDEN(gpio_pulldown[6]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[6]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[6])
	);

	BBCUD4F GPIO_buf_5 (
		.A(gpio_out_core[5]),
		.EN(gpio_outenb[5]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[5]),
		.PDEN(gpio_pulldown[5]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[5]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[5])
	);

	BBCUD4F GPIO_buf_4 (
		.A(gpio_out_core[4]),
		.EN(gpio_outenb[4]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[4]),
		.PDEN(gpio_pulldown[4]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[4]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[4])
	);

	BBCUD4F GPIO_buf_3 (
		.A(gpio_out_core[3]),
		.EN(gpio_outenb[3]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[3]),
		.PDEN(gpio_pulldown[3]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[3]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[3])
	);

	BBCUD4F GPIO_buf_2 (
		.A(gpio_out_core[2]),
		.EN(gpio_outenb[2]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[2]),
		.PDEN(gpio_pulldown[2]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[2]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[2])
	);

	BBCUD4F GPIO_buf_1 (
		.A(gpio_out_core[1]),
		.EN(gpio_outenb[1]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[1]),
		.PDEN(gpio_pulldown[1]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[1]),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.Y(gpio_in_core[1])
	);

	BBCUD4F GPIO_buf_0 (
		.A(gpio_out_core[0]),
		.EN(gpio_outenb[0]),
		.GNDO(VSS),
		.GNDR(VSS),
		.PAD(gpio[0]),
		.PDEN(gpio_pulldown[0]),
		.PI(dground),
		.PO(),
		.PUEN(gpio_pullup[0]),
		.VDD(VDD1V8),
		.VDDR(VDD3V3),
		.VDDO(VDD3V3),
		.Y(gpio_in_core[0])
	);

	BT4F flash_csb_buf (
		.PAD(flash_csb),
		.EN(dground),
		.A(flash_csb_core),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3)
		
	);

	BT4F flash_clk_buf (
		.PAD(flash_clk),
		.EN(dground),
		.A(flash_clk_core),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3)
	);

	ICF clk_ext_buf (	// External digital clock for PLL bypass mode
		.PAD(XCLK),
		.PO(),
		.GNDO(VSS),
		.GNDR(VSS),
		.VDD(VDD1V8),
		.VDDO(VDD3V3),
		.VDDR(VDD3V3),
		.PI(dground),
		.Y(clk_ext_core)
	);

	/* Implement MiM capacitors.  Layout uses 20x20um devices, so A=400um^2, P=80um */
	/* Enumerating all of the MiM cap arrays clockwise from the upper left corner */

`ifdef LVS
	cmm5t #(
	   .A(4e-10),
	   .P(8e-05)
	) cap_area_fill_3 [27:0] (
	   .top(VDD3V3),
	   .bottom(VSS),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(7.5e-10),
	   .P(1.1e-04)
	) cap_area_fill_3 [2:0] (
	   .top(VDD3V3),
	   .bottom(VSS),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(4e-10),
	   .P(8e-05)
	) cap_area_fill_3 [11:0] (
	   .top(VDD3V3),
	   .bottom(VSS),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(4.6e-10),
	   .P(8.6-05)
	) cap_area_fill_3 [15:0] (
	   .top(VDD1V8),
	   .bottom(VSS),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(5e-10),
	   .P(9e-05)
	) cap_area_fill_3 [23:0] (
	   .top(VDD3V3),
	   .bottom(VSS),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(6e-10),
	   .P(1e-04)
	) cap_area_fill_3 [4:0] (
	   .top(VSS),
	   .bottom(VDD3V3),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(5e-10),
	   .P(9e-05)
	) cap_area_fill_3 [7:0] (
	   .top(VSS),
	   .bottom(VDD1V8),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(6e-10),
	   .P(1e-04)
	) cap_area_fill_3 [33:0] (
	   .top(VDD3V3),
	   .bottom(VSS),
	   .subs(VSS)
	);
	cmm5t #(
	   .A(4e-10),
	   .P(8e-05)
	) cap_area_fill_3 [35:0] (
	   .top(VDD1V8),
	   .bottom(VSS),
	   .subs(VSS)
	);

	cmm5t #(
	   .A(5e-10),
	   .P(9e-05)
	) cap_area_fill_3 [39:0] (
	   .top(VDD3V3),
	   .bottom(VDD1V8),
	   .subs(VSS)
	);
`endif

	wire	    ram_wenb;
	wire [9:0]  ram_addr;
	wire [31:0] ram_wdata;
	wire [31:0] ram_rdata;

	/* NOTE:  Hardwired digital 0 disallowed in structural netlist.	*/
	/* Must generate from tie-low standard cell.			*/

	LOGIC0_3V ground_digital (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD3V3),
`endif
	   .Q(dground)
	);

	/* SCK_core is also input to raven_soc but needs to be shifted to 1.8V */
	/* Level shift down */
	BU_3VX2 SCK_core_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(SCK_core),
	   .Q(SCK_core_lv)
	);

	/* Due to lack of any SPI configuration behavior on the 1st generation	*/
	/* Raven chip, the spi_config is just grounded.  However, this requires	*/
	/* tie-low inputs.							*/

	LOGIC0_3V spi_config_zero [7:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD3V3),
`endif
	   .Q(spi_config)
	);

	/* SPI internal registers to be read from memory mapped I/O must also	*/
	/* be shifted down.  Those that are sent to the PLL already have	*/
	/* shifted versions.							*/

	BU_3VX2 spi_config_level [7:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_config),
	   .Q(spi_config_lv)
	);
	BU_3VX2 spi_xtal_ena_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_xtal_ena),
	   .Q(spi_xtal_ena_lv)
	);
	BU_3VX2 spi_reg_ena_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_reg_ena),
	   .Q(spi_reg_ena_lv)
	);
	BU_3VX2 spi_mfgr_id_level [11:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_mfgr_id),
	   .Q(spi_mfgr_id_lv)
	);
	BU_3VX2 spi_prod_id_level [7:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_prod_id),
	   .Q(spi_prod_id_lv)
	);
	BU_3VX2 spi_mask_rev_level [3:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_mask_rev),
	   .Q(spi_mask_rev_lv)
	);

	BU_3VX2 spi_reset_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_reset),
	   .Q(spi_reset_lv)
	);
	BU_3VX2 spi_pll_bypass_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_pll_bypass),
	   .Q(spi_pll_bypass_lv)
	);

	raven_soc soc (
`ifdef LVS
	   	.gnd	      (VSS    ),
	   	.vdd	      (VDD1V8 ),
`endif
		.pll_clk      (clk    ),
		.ext_clk      (clk_ext_core),
		.ext_clk_sel  (spi_pll_bypass_lv),
		.reset        (reset_lv ),
		.ext_reset    (spi_reset_lv ),

		.ram_wenb     (ram_wenb    ),
		.ram_addr     (ram_addr	   ),
		.ram_wdata    (ram_wdata   ),
		.ram_rdata    (ram_rdata   ),

		.gpio_out      (gpio_out_core),
		.gpio_in       (gpio_in_core),
		.gpio_pullup   (gpio_pullup),
		.gpio_pulldown (gpio_pulldown),
		.gpio_outenb   (gpio_outenb),

		.adc0_ena     (adc0_ena),
		.adc0_convert (adc0_convert),
		.adc0_data    (adc0_data_lv),
		.adc0_done    (adc0_done_lv),
		.adc0_clk     (adc0_clk),
		.adc0_inputsrc (adc0_inputsrc),

		.adc1_ena      (adc1_ena),
		.adc1_convert  (adc1_convert),
		.adc1_data     (adc1_data_lv),
		.adc1_done     (adc1_done_lv),
		.adc1_clk      (adc1_clk),
		.adc1_inputsrc (adc1_inputsrc),

		.dac_ena     (dac_ena),
		.dac_value   (dac_value),

		.analog_out_sel (analog_out_sel),
		.opamp_ena	(opamp_ena),
		.opamp_bias_ena	(opamp_bias_ena),
		.bg_ena		(bg_ena),

		.comp_ena       (comp_ena),
		.comp_ninputsrc (comp_ninputsrc),
		.comp_pinputsrc (comp_pinputsrc),
		.rcosc_ena	(rcosc_ena),

		.overtemp_ena	(overtemp_ena),
		.overtemp	(overtemp_lv),
		.rcosc_in	(rcosc_out_lv),
		.xtal_in	(xtal_out_lv),
		.comp_in	(comp_out_lv),
		.spi_sck	(SCK_core_lv),

		.spi_ro_config	(spi_config_lv),
		.spi_ro_xtal_ena (spi_xtal_ena_lv),
		.spi_ro_reg_ena	(spi_reg_ena_lv),
		.spi_ro_pll_cp_ena (spi_pll_cp_ena_lv),
		.spi_ro_pll_vco_ena (spi_pll_vco_ena_lv),
		.spi_ro_pll_bias_ena (spi_pll_bias_ena_lv),
		.spi_ro_pll_trim (spi_pll_trim_lv),
		.spi_ro_mfgr_id	(spi_mfgr_id_lv),
		.spi_ro_prod_id	(spi_prod_id_lv),
		.spi_ro_mask_rev (spi_mask_rev_lv),

		.ser_tx    (ser_tx_core ),
		.ser_rx    (ser_rx_core ),

		.irq_pin   (irq_pin_core),
		.irq_spi   (spi_irq_lv),

		.trap	   (spi_trap),

		.flash_csb (flash_csb_core),
		.flash_clk (flash_clk_core),

		.flash_io0_oeb (flash_io0_oeb),
		.flash_io1_oeb (flash_io1_oeb),
		.flash_io2_oeb (flash_io2_oeb),
		.flash_io3_oeb (flash_io3_oeb),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di)
	);

	/* Level shift up */

	LS_3VX2 spi_trap_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(spi_trap),
	   .Q(spi_trap_3v)
	);

	/* Metal programming for mask revision */

	wire [3:0] pground;
	wire [3:0] ppower;

	LOGIC0_3V prog_ground [3:0] (
`ifdef LVS
	    .gnd(VSS),
	    .vdd3(VDD3V3),
`endif
	    .Q(pground)
	);
	LOGIC1_3V prog_power [3:0] (
`ifdef LVS
	    .gnd(VSS),
	    .vdd3(VDD3V3),
`endif
	    .Q(ppower)
	);

	/* Standalone SPI (3V)*/
	/* Operates at 3V so that it can control the xtal oscillator, PLL, */
	/* and 1.8V regulator, which cannot be changed from the CPU 	   */
	/* without potentially killing it.				   */

	raven_spi spi (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD3V3),
`endif
	   .RST(reset),
	   .SCK(SCK_core),
	   .SDI(SDI_core),
	   .CSB(CSB_core),
	   .SDO(SDO_core),
	   .sdo_enb(sdo_enb),
	   .xtal_ena(spi_xtal_ena),
	   .reg_ena(spi_reg_ena),
	   .pll_vco_ena(spi_pll_vco_ena),
	   .pll_cp_ena(spi_pll_cp_ena),
	   .pll_bias_ena(spi_pll_bias_ena),
	   .pll_trim(spi_pll_trim),
	   .pll_bypass(spi_pll_bypass),
	   .irq(spi_irq),
	   .reset(spi_reset),
	   .trap(spi_trap_3v),
	   .mask_rev_in(pground),		// Metal programmed
	   .mfgr_id(spi_mfgr_id),
	   .prod_id(spi_prod_id),
	   .mask_rev(spi_mask_rev)
	);

	/* Level shift down.  Unfortunately, PLL is in 1.8V only or	*/
	/* else this would be easier.					*/

	BU_3VX2 pll_vco_ena_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_pll_vco_ena),
	   .Q(spi_pll_vco_ena_lv)
	);
	BU_3VX2 pll_cp_ena_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_pll_cp_ena),
	   .Q(spi_pll_cp_ena_lv)
	);
	BU_3VX2 pll_trim_level [3:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_pll_trim),
	   .Q(spi_pll_trim_lv)
	);
	BU_3VX2 pll_bias_ena_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_pll_bias_ena),
	   .Q(spi_pll_bias_ena_lv)
	);
	BU_3VX2 spi_irq_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(spi_irq),
	   .Q(spi_irq_lv)
	);

	/* RAM module */

        XSPRAM_1024X32_M8P xfab_mem(
`ifdef LVS
	    .VSSM(VSS),
	    .VDD18M(VDD1V8),
`endif
            .Q(ram_rdata),
            .D(ram_wdata),
            .A(ram_addr),
            .CLK(clk),
            .CEn(reset_lv),  // SRAM enable
            .WEn(ram_wenb),  // note:  not maskable by byte
            .OEn(reset_lv),  // always enabled when SRAM is
            .RDY()           // unused
        );

	/* Analog components (multiplexers) */
	wire real adc0_input;
	wire real adc1_input;
	wire real comp_ninput;
	wire real comp_pinput;
	wire real opamp_input;
	wire real dac_out;
	wire real bandgap_out;

        AMUX4_3V adc0_input_mux (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .AIN1(adc0_in),
	   .AIN2(VDD1V8),
	   .AIN3(dac_out),
	   .AIN4(VSS),
	   .AOUT(adc0_input),
	   .SEL(adc0_inputsrc)
	);

        AMUX4_3V adc1_input_mux (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .AIN1(adc1_in),
	   .AIN2(VDD3V3),
	   .AIN3(bandgap_out),
	   .AIN4(comp_inp),
	   .AOUT(adc1_input),
	   .SEL(adc1_inputsrc)
	);

        AMUX4_3V comp_ninput_mux (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .AIN1(comp_inn),
	   .AIN2(dac_out),
	   .AIN3(bandgap_out),
	   .AIN4(VDD1V8),
	   .AOUT(comp_ninput),
	   .SEL(comp_ninputsrc)
	);

        AMUX4_3V comp_pinput_mux (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .AIN1(comp_inp),
	   .AIN2(dac_out),
	   .AIN3(bandgap_out),
	   .AIN4(VDD1V8),
	   .AOUT(comp_pinput),
	   .SEL(comp_pinputsrc)
	);

        AMUX2_3V analog_out_mux (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .AIN1(dac_out),
	   .AIN2(bandgap_out),
	   .AOUT(opamp_input),
	   .SEL(analog_out_sel)
	);

	/* Level shift up */

	LS_3VX2 adc0_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(adc0_ena),
	   .Q(adc0_ena_3v)
	);
	LS_3VX2 adc0_clk_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(adc0_clk),
	   .Q(adc0_clk_3v)
	);
	LS_3VX2 adc0_convert_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(adc0_convert),
	   .Q(adc0_convert_3v)
	);

	/* ADC 0 */
	aadcc01_3v3 adc0 (
	   .VDD(VDD3V3),
	   .VIN(adc0_input),
	   .CLK(adc0_clk_3v),
	   .VREFH(adc_high),
	   .EN(adc0_ena_3v),
	   .VSSA(VSS),
	   .VDDA(VDD3V3),
	   .VREFL(adc_low),
	   .START(adc0_convert_3v),
	   .EOC(adc0_done),
	   .D(adc0_data),
	   .VSS(VSS)
	);

	/* Level shift down */
	
	BU_3VX2 adc0_done_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(adc0_done),
	   .Q(adc0_done_lv)
	);

	BU_3VX2 adc0_data_level [9:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(adc0_data),
	   .Q(adc0_data_lv)
	);

	/* Level shift up */


	LS_3VX2 adc1_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(adc1_ena),
	   .Q(adc1_ena_3v)
	);
	LS_3VX2 adc1_clk_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(adc1_clk),
	   .Q(adc1_clk_3v)
	);
	LS_3VX2 adc1_convert_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(adc1_convert),
	   .Q(adc1_convert_3v)
	);

	/* ADC 1 */
	aadcc01_3v3 adc1 (
	   .VDD(VDD3V3),
	   .VIN(adc1_input),
	   .CLK(adc1_clk_3v),
	   .VREFH(adc_high),
	   .EN(adc1_ena_3v),
	   .VSSA(VSS),
	   .VDDA(VDD3V3),
	   .VREFL(adc_low),
	   .START(adc1_convert_3v),
	   .EOC(adc1_done),
	   .D(adc1_data),
	   .VSS(VSS)
	);

	/* Level shift down */
	
	BU_3VX2 adc1_done_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(adc1_done),
	   .Q(adc1_done_lv)
	);

	BU_3VX2 adc1_data_level [9:0] (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(adc1_data),
	   .Q(adc1_data_lv)
	);

	/* Level shift up */

	LS_3VX2 dac_value_level [9:0] (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(dac_value),
	   .Q(dac_value_3v)
	);


	LS_3VX2 dac_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(dac_ena),
	   .Q(dac_ena_3v)
	);

	/* DAC */
	adacc01_3v3 dac (
	   .OUT(dac_out),
	   .D(dac_value_3v),
	   .EN(dac_ena_3v),
	   .VDD(VDD3V3),
	   .VDDA(VDD3V3),
	   .VREFH(adc_high),
	   .VREFL(adc_low),
	   .VSS(VSS),
	   .VSSA(VSS)
	);

	/* Level shift up */

	LS_3VX2 opamp_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(opamp_ena),
	   .Q(opamp_ena_3v)
	);

	wire real bias3u;

	/* Opamp (analog output buffer) */
	aopac01_3v3 opamp (
	   .OUT(analog_out),
	   .EN(opamp_ena_3v),
	   .IB(bias3u),
	   .INN(analog_out),
	   .INP(opamp_input),
	   .VDDA(VDD3V3),
	   .VSSA(VSS)
	);

	/* Level shift up */

	LS_3VX2 opamp_bias_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(opamp_bias_ena),
	   .Q(opamp_bias_ena_3v)
	);

	/* Biasing for op-amp */
	acsoc02_3v3 opamp_bias (
	   .EN(opamp_bias_ena_3v),
	   .VDDA(VDD3V3),
	   .VSSA(VSS),
	   .CS_8U(),
	   .CS_4U(),
	   .CS_2U(bias3u),
	   .CS_1U(bias3u)
	);

	/* Level shift up */

	LS_3VX2 bg_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(bg_ena),
	   .Q(bg_ena_3v)
	);

	/* Bandgap */
	abgpc01_3v3 bandgap (
	   .EN(bg_ena_3v),
	   .VBGP(bandgap_out),
	   .VSSA(VSS),
	   .VDDA(VDD3V3),
	   .VBGVTN()
	);

	wire real bias400n;

	/* Comparator */
	acmpc01_3v3 comparator (
	   .OUT(comp_out),
	   .EN(comp_ena_3v),
	   .IBN(bias400n),
	   .INN(comp_ninput),	// multiplexed
	   .INP(comp_pinput),	// multiplexed
	   .VDDA(VDD3V3),
	   .VSSA(VSS)
	);

	/* Level shift down */

	BU_3VX2 comp_out_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(comp_out),
	   .Q(comp_out_lv)
	);

	/* Level shift up */

	LS_3VX2 comp_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(comp_ena),
	   .Q(comp_ena_3v)
	);

	/* Bias for comparator */
	acsoc01_3v3 comp_bias (
	   .EN(comp_ena_3v),
	   .VSSA(VSS),
	   .VDDA(VDD3V3),
	   .CS0_200N(bias400n),
	   .CS1_200N(bias400n),
	   .CS2_200N(),
	   .CS3_200N()
	);

	/* Crystal oscillator (5-12.5 MHz) */
	axtoc02_3v3 xtal (
	   .CLK(xtal_out),
	   .XI(XI),
	   .XO(XO),
	   .EN(spi_xtal_ena),
	   .GNDO(VSS),
	   .GNDR(VSS),
	   .VDD(VDD1V8),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3)
	);

	/* Level shift down (because xtal osc is 3V but PLL is 1.8V) */

	BU_3VX2 xtal_out_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(xtal_out),
	   .Q(xtal_out_lv)
	);

	wire real bias10u, bias5u;

	/* 8x clock multiplier PLL (NOTE: IP from A_CELLS_1V8) */
	apllc03_1v8 pll (
	   .VSSD(VSS),
	   .EN_VCO(spi_pll_vco_ena_lv),
	   .EN_CP(spi_pll_cp_ena_lv),
	   .B_VCO(bias5u),
	   .B_CP(bias10u),
	   .VSSA(VSS),
	   .VDDD(VDD1V8),
	   .VDDA(VDD1V8),
	   .VCO_IN(),
	   .CLK(clk),		// output (fast) clock
	   .REF(xtal_out_lv),	// input (slow) clock
	   .B(spi_pll_trim_lv) 	// 4-bit trim
	);

	/* Biasing for PLL */
	acsoc04_1v8 pll_bias (
	   .EN(spi_pll_bias_ena_lv),
	   .VDDA(VDD1V8),
	   .VSSA(VSS),
	   .CS3_8u(bias10u),
	   .CS2_4u(bias5u),
	   .CS1_2u(bias10u),
	   .CS0_1u(bias5u)
	);

	/* Level shift up */

	LS_3VX2 rcosc_ena_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(rcosc_ena),
	   .Q(rcosc_ena_3v)
	);

	/* RC oscillator */
	arcoc01_3v3 rcosc (
	   .CLK(rcosc_out),
	   .EN(rcosc_ena_3v),
	   .VDDA(VDD3V3),
	   .VSSA(VSS)
	);

	/* Level shift down */

	BU_3VX2 rcosc_out_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(rcosc_out),
	   .Q(rcosc_out_lv)
	);

	/* 1.8V regulator needs inverted enable (3V) */
	IN_3VX2 reg_enb_inv (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD3V3),
`endif
	   .A(spi_reg_ena),
	   .Q(spi_reg_enb)
	);

	/* 1.8V regulator (x2) */
	/* NOTE:  Array of two devices combined into one here. . .	*/
	/* need to figure out how to get iverilog to honor the analog	*/
	/* connection (maybe not possible).				*/
	aregc01_3v3 regulator [1:0] (
	   .OUT(VDD1V8),
	   .VIN3(VDD3V3),
	   .GNDO(VSS),
	   .EN(spi_reg_ena),
	   .GNDR(VSS),
	   .VDDO(VDD3V3),
	   .VDDR(VDD3V3),
	   .VDD(VDD1V8),
	   .ENB(spi_reg_enb)
	);

	/* Power-on-reset */
	aporc02_3v3 por (
	   .POR(reset),
	   .PORB(resetn),
	   .VDDA(VDD3V3),
	   .VSSA(VSS)
	);

	/* Level shift down */

	BU_3VX2 por_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(reset),
	   .Q(reset_lv)
	);

	/* Level shift up */

	LS_3VX2 temp_level (
	   .VDD3V3(VDD3V3),
	   .VDD1V8(VDD1V8),
	   .VSSA(VSS),
	   .A(overtemp_ena),
	   .Q(overtemp_ena_3v)
	);

	/* Over-temperature alarm */
	atmpc01_3v3 temp (
	   .OVT(overtemp),
	   .EN(overtemp_ena_3v),
	   .VDDA(VDD3V3),
	   .VSSA(VSS)
	);

	/* Level shift down */

	BU_3VX2 overtemp_level (
`ifdef LVS
	   .gnd(VSS),
	   .vdd3(VDD1V8),
`endif
	   .A(overtemp),
	   .Q(overtemp_lv)
	);

endmodule	// raven
