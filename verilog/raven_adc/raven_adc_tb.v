/*
 *  Raven - A full example SoC using PicoRV32 in X-Fab XH018
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

`include "../raven.v"
`include "../spiflash.v"

module raven_adc_tb;
	reg XCLK;
	reg real VDD3V3;

	reg real XI;
	wire real XO;

	reg real adc_h, adc_l;
	reg real adc_0, adc_1;
	reg real comp_n, comp_p;
	wire real ana_out;

	always #1000 XCLK <= (XCLK === 1'b0);
	always #50 XI = VDD3V3 - XO;

	initial begin
		XCLK <= 1'b0;
		XI = 0.0;
		#150;
		XI = VDD3V3 / 2 - 0.1;
	end

	initial begin
		// Ramp VDD3V3 from 0 to 3.3V
		VDD3V3 = 0.0;
		#50;
		repeat (33) begin
		   #3;
		   VDD3V3 = VDD3V3 + 0.1;
		end
	end

	initial begin
		// Analog input pin values

		adc_h = 0.0;
		adc_l = 0.0;
		adc_0 = 0.0;
		adc_1 = 0.0;
		comp_n = 0.0;
		comp_p = 0.0;
		#2000;
		adc_h = 3.25;
		adc_l = 0.05;
		adc_0 = 1.1;
		adc_1 = 1.5;
		comp_n = 2.0;
		comp_p = 2.5;
	end

	initial begin
		$dumpfile("raven_adc.vcd");
		$dumpvars(0, raven_adc_tb);

		// Only 1000 cycles needed to complete the test.
		repeat (1) begin
			repeat (1000) @(posedge XCLK);
			$display("+1000 cycles");
		end
		$finish;
	end

	wire [15:0] gpio;

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire flash_io2;
	wire flash_io3;

	reg SDI, CSB, SCK;
	wire SDO;

	always @(uut.adc0_input) begin
		#1 $display("ADC0 input value = %g (V) at time %g", uut.adc0_input, $realtime);
	end

	always @(posedge uut.adc0_done) begin
		#1 $display("ADC0 out = %b at time %g", uut.adc0_data, $realtime);
	end

	wire real VDD1V8;
	wire real VSS;

	assign VSS = 0.0;

	raven uut (
		.VDD3V3	  (VDD3V3  ),
		.VDD1V8	  (VDD1V8),
		.VSS	  (VSS),
		.XI	  (XI),
		.XO	  (XO),
		.XCLK	  (XCLK),
		.SDI	  (SDI),
		.SDO	  (SDO),
		.CSB	  (CSB),
		.SCK	  (SCK),
		.ser_rx	  (1'b0     ),
		.ser_tx	  (         ),
		.irq	  (1'b0	    ),
		.gpio     (gpio     ),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.flash_io2(flash_io2),
		.flash_io3(flash_io3),
		.adc_high (adc_h),
		.adc_low  (adc_l),
		.adc0_in  (adc_0),
		.adc1_in  (adc_1),
		.analog_out(ana_out),
		.comp_inp (comp_p),
		.comp_inn (comp_n)
	);

	spiflash #(
		.FILENAME("raven_adc.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(flash_io2),
		.io3(flash_io3)
	);
endmodule
