//-------------------------------------
// SPI controller for raven (PicoSoC)
//-------------------------------------
// Written by Tim Edwards
// efabless, inc. January 3, 2018
//-------------------------------------

// `include "spi_slave.v"

//-----------------------------------------------------------
// This is a standalone slave SPI for the raven chip that is
// intended to be independent of the picosoc and independent
// of all IP blocks except the power-on-reset.  This SPI has
// register outputs controlling the functions that critically
// affect operation of the picosoc and so cannot be accessed
// from the picosoc itself.  This includes the PLL enables
// and trim, and the crystal oscillator enable.  It also has
// a general reset for the picosoc, an IRQ input, a bypass for
// the entire crystal oscillator and PLL chain, the
// manufacturer and product IDs and product revision number.
// To be independent of the 1.8V regulator, the slave SPI is
// synthesized with the 3V digital library and runs off of
// the 3V supply.
//-----------------------------------------------------------

//------------------------------------------------------------
// Picochip defined registers:
// Register 0:  SPI status and control (unused & reserved)
// Register 1h: Mask revision (= 0) (readonly)
// Register 1l and 2:  Manufacturer ID (0x456) (readonly)
// Register 3:  Product ID (= 2) (readonly)
//
// Register 4:  X-Fab IP enable and trim (xtal, regulator, PLL)  (8 bits)
// Register 5:  PLL bypass (1 bit)
// Register 6:  IRQ (1 bit)
// Register 7:  reset (1 bit)
// Register 8:  trap (1 bit) (readonly)
//------------------------------------------------------------

module raven_spi(RST, SCK, SDI, CSB, SDO, sdo_enb,
	xtal_ena, reg_ena, pll_vco_ena, pll_cp_ena, pll_bias_ena,
	pll_trim, pll_bypass, irq, reset, trap,
	mfgr_id, prod_id, mask_rev_in, mask_rev);

    input RST;
    input SCK;
    input SDI;
    input CSB;
    output SDO;
    output sdo_enb;
    output xtal_ena;
    output reg_ena;
    output pll_vco_ena;
    output pll_cp_ena;
    output pll_bias_ena;
    output [3:0] pll_trim;
    output pll_bypass;
    output irq;
    output reset;
    input  trap;
    input [3:0] mask_rev_in;	// metal programmed
    output [11:0] mfgr_id;
    output [7:0] prod_id;
    output [3:0] mask_rev;

    reg xtal_ena;
    reg reg_ena;
    reg [3:0] pll_trim;
    reg pll_vco_ena;
    reg pll_cp_ena;
    reg pll_bias_ena;
    reg pll_bypass;
    reg irq;
    reg reset;

    wire [7:0] odata;
    wire [7:0] idata;
    wire [7:0] iaddr;

    wire trap;
    wire rdstb;
    wire wrstb;

    // Instantiate the SPI slave module

    spi_slave U1 (
	.SCK(SCK),
	.SDI(SDI),
	.CSB(CSB),
	.SDO(SDO),
	.sdoenb(sdo_enb),
	.idata(odata),
	.odata(idata),
	.oaddr(iaddr),
	.rdstb(rdstb),
	.wrstb(wrstb)
    );

    wire [11:0] mfgr_id;
    wire [7:0] prod_id;
    wire [3:0] mask_rev;

    assign mfgr_id = 12'h456;		// Hard-coded
    assign prod_id = 8'h02;		// Hard-coded
    assign mask_rev = mask_rev_in;	// Copy in to out.

    // Send register contents to odata on SPI read command
    // All values are 1-4 bits and no shadow registers are required.

    assign odata = 
	(iaddr == 8'h00) ? 8'h00 :	// SPI status (fixed)
	(iaddr == 8'h01) ? {mask_rev, mfgr_id[11:8]} : 	// Mask rev (metal programmed)
	(iaddr == 8'h02) ? mfgr_id[7:0] :	// Manufacturer ID (fixed)
	(iaddr == 8'h03) ? prod_id :	// Product ID (fixed)
	(iaddr == 8'h04) ? {xtal_ena, reg_ena, pll_vco_ena, pll_cp_ena, pll_trim} :
	(iaddr == 8'h05) ? {7'b0000000, pll_bypass} :
	(iaddr == 8'h06) ? {7'b0000000, irq} :
	(iaddr == 8'h07) ? {7'b0000000, reset} :
	(iaddr == 8'h08) ? {7'b0000000, trap} :
			   8'h00;	// Default

    // Register mapping and I/O to slave module

    always @(posedge SCK or posedge RST) begin
	if (RST == 1'b1) begin
	    pll_trim <= 4'b0000;
	    xtal_ena <= 1'b1;
	    reg_ena <= 1'b1;
	    pll_vco_ena <= 1'b1;
	    pll_cp_ena <= 1'b1;
	    pll_bias_ena <= 1'b1;
	    pll_bypass <= 1'b0;
	    irq <= 1'b0;
	    reset <= 1'b0;
	end else if (wrstb == 1'b1) begin
	    case (iaddr)
		8'h04: begin
			 pll_trim    <= idata[7:4];
			 pll_cp_ena  <= idata[3];
			 pll_vco_ena <= idata[2];
			 reg_ena     <= idata[1];
			 xtal_ena    <= idata[0];
		       end
		8'h05: begin
			 pll_bypass <= idata[0];
		       end
		8'h06: begin
			 irq <= idata[0];
		       end
		8'h07: begin
			 reset <= idata[0];
		       end
		// Register 8 is read-only
	    endcase	// (iaddr)
	end
    end
endmodule	// raven_spi
