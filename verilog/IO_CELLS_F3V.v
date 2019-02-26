//************************************************************************************
// Simple functional stand-in for X-Fab I/O cells IOCELLS_F3V.v
// #######################################################################
 
`timescale 1ns/10ps

//****************************************************************************
//   technology       : xh018
//   module name      : APR00DF
//   cell_description : Analog I/O Cell with low series resistance less
//                      than 1Ohm, ESD protection structures to Supply and
//    	                to Ground
//****************************************************************************

module APR00DF (GNDO, GNDR, PAD, VDD, VDDO, VDDR);

   input     GNDO, GNDR, VDD, VDDO, VDDR;
   input     PAD;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;
   wire real PAD;

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : BBC4F
//   cell_description : Bi-directional Buffer with Non-Inverting CMOS
//                      Input, Strength 4mA @ 3.3 V, Normal, High noise
//                 (Fast speed)
//****************************************************************************

module BBC4F (A, EN, GNDO, GNDR, PAD, PI, PO, VDD, VDDO, VDDR, Y);

   input     A, EN, GNDO, GNDR, PI, VDD, VDDO, VDDR;
   inout     PAD;
   output    PO, Y;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;

   wire      ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR;

   check_gnd i0  (ck_GNDO, GNDO);
   check_gnd i1  (ck_GNDR, GNDR);
   check_vdd i2  (ck_VDD, VDD);
   check_vdd i3  (ck_VDDO, VDDO);
   check_vdd i4  (ck_VDDR, VDDR);

   and       i5  (ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR);

   check_buf i6  (ck_A, A, ck_sub);
   check_buf i7  (ck_EN, EN, ck_sub);
   check_buf i8  (ck_PAD, PAD, ck_sub);
   check_buf i9  (ck_PI, PI, ck_sub);


// Function PAD: A; Tristate function: EN
   bufif0    i10 (PAD, ck_A, ck_EN);

// Function PO: !(PAD&PI)
   nand      i11 (PO, ck_PAD, ck_PI);

// Function Y: PAD
   buf       i13 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : BBCUD4F
//   cell_description : Bi-directional Buffer with Non-Inverting CMOS Input
//                      and Gated Pull-down and Pull-up, Strength 4mA @ 3.3
//                 V, Normal, High noise (Fast speed)
//****************************************************************************

module BBCUD4F (A, EN, GNDO, GNDR, PAD, PDEN, PI, PO, PUEN, VDD, VDDO, VDDR, Y);

   input     A, EN, GNDO, GNDR, PDEN, PI, PUEN, VDD, VDDO, VDDR;
   inout     PAD;
   output    PO, Y;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;

   wire      ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR;

// Pull-up and pull-down connections

   buf       pu1 (PUEN_en, PUEN);
   not       pd1 (PDEN_enb, PDEN);

`ifdef DISPLAY_PD_PU_EN

     rpmos   pu2 (PAD, 1'b1, PUEN_en);
     rnmos   pd2 (PAD, 1'b0, PDEN_enb);
     nor    (pull1, strong0) pu3 (CURRENT_PU, ck_PAD, PUEN_en);
     and    (pull1, strong0) pd3 (CURRENT_PD, ck_PAD, PDEN_enb);

`endif

   check_gnd i0  (ck_GNDO, GNDO);
   check_gnd i1  (ck_GNDR, GNDR);
   check_vdd i2  (ck_VDD, VDD);
   check_vdd i3  (ck_VDDO, VDDO);
   check_vdd i4  (ck_VDDR, VDDR);

   and       i5  (ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR);

   check_buf i6  (ck_A, A, ck_sub);
   check_buf i7  (ck_EN, EN, ck_sub);
   check_buf i8  (ck_PAD, PAD, ck_sub);
   check_buf i9  (ck_PDEN, PDEN, ck_sub);
   check_buf i10 (ck_PI, PI, ck_sub);
   check_buf i11 (ck_PUEN, PUEN, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i12 (PAD, ck_A, ck_EN);

// Function PO: !(PAD&PI)
   nand      i13 (PO, ck_PAD, ck_PI);

// Function Y: PAD
   buf       i15 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : BT4F
//   cell_description : Tri-state output Buffer, Strength 4mA @ 3.3 V,
//                      Normal, High noise (Fast speed)
//****************************************************************************

module BT4F (A, EN, GNDO, GNDR, PAD, VDD, VDDO, VDDR);

   input     A, EN, GNDO, GNDR, VDD, VDDO, VDDR;
   output    PAD;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;

   wire      ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR;

   check_gnd i0  (ck_GNDO, GNDO);
   check_gnd i1  (ck_GNDR, GNDR);
   check_vdd i2  (ck_VDD, VDD);
   check_vdd i3  (ck_VDDO, VDDO);
   check_vdd i4  (ck_VDDR, VDDR);

   and       i5  (ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR);

   check_buf i6  (ck_A, A, ck_sub);
   check_buf i7  (ck_EN, EN, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i8  (PAD, ck_A, ck_EN);

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : GNDORPADF
//   cell_description : GNDO and GNDR ground cell
//****************************************************************************

module GNDORPADF (GNDOR, VDD, VDDO, VDDR);

   input     GNDOR, VDD, VDDO, VDDR;

   wire real GNDOR, VDD, VDDO, VDDR;

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : ICF
//   cell_description : Non-Inverting CMOS Input Buffer
//****************************************************************************

module ICF (GNDO, GNDR, PAD, PI, PO, VDD, VDDO, VDDR, Y);

   input     GNDO, GNDR, PAD, PI, VDD, VDDO, VDDR;
   output    PO, Y;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;

   wire      ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR;

   check_gnd i0  (ck_GNDO, GNDO);
   check_gnd i1  (ck_GNDR, GNDR);
   check_vdd i2  (ck_VDD, VDD);
   check_vdd i3  (ck_VDDO, VDDO);
   check_vdd i4  (ck_VDDR, VDDR);

   and       i5  (ck_sub, ck_GNDO, ck_GNDR, ck_VDD, ck_VDDO, ck_VDDR);

   check_buf i6  (ck_PAD, PAD, ck_sub);
   check_buf i7  (ck_PI, PI, ck_sub);

// Function PO: !(PAD&PI)
   nand      i8  (PO, ck_PAD, ck_PI);

// Function Y: PAD
   buf       i10 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : VDDORPADF
//   cell_description : VDDO and VDDR supply cell
//****************************************************************************

module VDDORPADF (GNDO, GNDR, VDD, VDDOR);

   input     GNDO, GNDR, VDD, VDDOR;
   wire real GNDO, GNDR, VDD, VDDOR;

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : VDDPADF
//   cell_description : VDD core and IO supply cell
//****************************************************************************

module VDDPADF (GNDO, GNDR, VDD, VDDO, VDDR);

   input     GNDO, GNDR, VDD, VDDO, VDDR;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : CORNERESDF
//   cell_description : Corner cell with ESD protection structure
//****************************************************************************

module CORNERESDF (GNDO, GNDR, VDD, VDDO, VDDR);

   input     GNDO, GNDR, VDD, VDDO, VDDR;

   wire real GNDO, GNDR, VDD, VDDO, VDDR;

endmodule

//************************************************************************/
// Voltage checks

primitive check_buf   (z, a, b);
    output z;
    input a, b ;

// FUNCTION :  Comparison cell

    table
    //  a    b      :   z
        1    1      :   1 ;
        x    1      :   x ;
	0    1      :   0 ;
        1    x      :   x ;
        x    x      :   x ;
	0    x      :   x ;

    endtable
endprimitive

module check_vdd   (z, a);
   output z;
   input a;

   reg z;
   wire real a;

   initial begin
      if (a > 1.5 && a < 3.6) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end

   always @(a) begin
      if (a > 1.5 && a < 3.6) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end
endmodule

module check_vdd1_8   (z, a);
   output z;
   input a;

   reg z;
   wire real a;

   initial begin
      if (a > 1.5 && a < 2.2) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end

   always @(a) begin
      if (a > 1.5 && a < 2.2) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end
endmodule

module check_vdd3   (z, a);
   output z;
   input a;

   reg z;
   wire real a;

   initial begin
      if (a > 2.9 && a < 3.6) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end

   always @(a) begin
      if (a > 2.9 && a < 3.6) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end
endmodule

module check_gnd   (z, a);
   output z;
   input a;

   reg z;
   wire real a;

   initial begin
      if (a < 0.3 && a > -0.3) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end

   always @(a) begin
      if (a < 0.3 && a > -0.3) begin
         z <= 1'b1;
      end else begin
         z <= 1'bx;
      end
   end
endmodule


// cell primitive section --- END ---
// --------------------------------------------------------------------
