//************************************************************************************
// Simple functional models for I/O cells with 3.3V pad, 1.8V core
// #######################################################################
 
`timescale 1ns/10ps

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_analog
//   cell_description : Analog I/O Cell with standard ESD diodes and low
//                      resistance connection pad to core.
//****************************************************************************

module io_analog (GNDA, PAD, VDD, VDDA);

   input     GNDA, VDD, VDDA;
   input     PAD;

   wire real GNDA, VDD, VDDA;
   wire real PAD;

endmodule

//****************************************************************************
//   technology       : non-specific
//   module name      : io_bidirectional
//   cell_description : Bi-directional Buffer with Non-Inverting CMOS
//                      Input
//****************************************************************************

module io_bidirectional (A, EN, GNDA, PAD, VDD, VDDA, Y);

   input     A, EN, GNDA, VDD, VDDA;
   inout     PAD;
   output    Y;

   wire real GNDA, VDD, VDDA;

   wire      ck_sub, ck_GNDA, ck_VDD, ck_VDDA;

   check_gnd i0  (ck_GNDA, GNDA);
   check_vdd i1  (ck_VDD, VDD);
   check_vdd i2  (ck_VDDA, VDDA);

   and       i3  (ck_sub, ck_GNDA, ck_VDD, ck_VDDA);

   check_buf i4  (ck_A, A, ck_sub);
   check_buf i5  (ck_EN, EN, ck_sub);
   check_buf i6  (ck_PAD, PAD, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i7 (PAD, ck_A, ck_EN);

// Function Y: PAD
   buf       i13 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_bidirectional_pu_pd
//   cell_description : Bi-directional Buffer with Non-Inverting CMOS Input
//                      and Gated Pull-down and Pull-up
//****************************************************************************

module io_bidirectional_pu_pd (A, EN, GNDA, PAD, PDEN, PUEN, VDD, VDDA, Y);

   input     A, EN, GNDA, PDEN, PUEN, VDD, VDDA;
   inout     PAD;
   output    Y;

   wire real GNDA, VDD, VDDA;

   wire      ck_sub, ck_GNDA, ck_VDD, ck_VDDA;

// Pull-up and pull-down connections

   buf       pu1 (PUEN_en, PUEN);
   not       pd1 (PDEN_enb, PDEN);

   check_gnd i0  (ck_GNDA, GNDA);
   check_vdd i1  (ck_VDD, VDD);
   check_vdd i2  (ck_VDDA, VDDA);

   and       i3  (ck_sub, ck_GNDA, ck_VDD, ck_VDDA);

   check_buf i4  (ck_A, A, ck_sub);
   check_buf i5  (ck_EN, EN, ck_sub);
   check_buf i6  (ck_PAD, PAD, ck_sub);
   check_buf i7  (ck_PDEN, PDEN, ck_sub);
   check_buf i8  (ck_PUEN, PUEN, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i12 (PAD, ck_A, ck_EN);

// Function Y: PAD
   buf       i15 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_output
//   cell_description : Tri-state output Buffer
//****************************************************************************

module io_output (A, EN, GNDA, PAD, VDD, VDDA);

   input     A, EN, GNDA, VDD, VDDA;
   output    PAD;

   wire real GNDA, VDD, VDDA;

   wire      ck_sub, ck_GNDA, ck_VDD, ck_VDDA;

   check_gnd i0  (ck_GNDA, GNDA);
   check_vdd i1  (ck_VDD, VDD);
   check_vdd i2  (ck_VDDA, VDDA);

   and       i3  (ck_sub, ck_GNDA, ck_VDD, ck_VDDA);

   check_buf i4  (ck_A, A, ck_sub);
   check_buf i5  (ck_EN, EN, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i6  (PAD, ck_A, ck_EN);

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_ground
//   cell_description : GNDA ground cell
//****************************************************************************

module io_ground (GNDA, VDD, VDDA);

   input     GNDA, VDD, VDDA;

   wire real GNDA, VDD, VDDA;

endmodule

//****************************************************************************
//   technology       : Non-specifc
//   module name      : io_input
//   cell_description : Non-Inverting CMOS Input Buffer
//****************************************************************************

module io_input (GNDA, PAD, VDD, VDDA, Y);

   input     GNDA, PAD, VDD, VDDA;
   output    Y;

   wire real GNDA, VDD, VDDA;

   wire      ck_sub, ck_GNDA, ck_VDD, ck_VDDA;

   check_gnd i0  (ck_GNDA, GNDA);
   check_vdd i1  (ck_VDD, VDD);
   check_vdd i2  (ck_VDDA, VDDA);

   and       i3  (ck_sub, ck_GNDA, ck_VDD, ck_VDDA);

   check_buf i4  (ck_PAD, PAD, ck_sub);

// Function Y: PAD
   buf       i5 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_vdda
//   cell_description : VDDA supply cell
//****************************************************************************

module io_vdda (GNDA, VDD, VDDA);

   input     GNDA, VDD, VDDA;
   wire real GNDA, VDD, VDDA;

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_vdd
//   cell_description : 1.8V VDD core and IO supply cell
//****************************************************************************

module io_vdd (GNDA, VDD, VDDA);

   input     GNDA, VDD, VDDA;

   wire real GNDA, VDD, VDDA;

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_corner_clamp
//   cell_description : Corner cell with voltage clamp
//****************************************************************************

module io_corner_clamp (GNDA, VDD, VDDA);

   input     GNDA, VDD, VDDA;

   wire real GNDA, VDD, VDDA;

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

// --------------------------------------------------------------------

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

// --------------------------------------------------------------------

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

// --------------------------------------------------------------------

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

// --------------------------------------------------------------------

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

// --------------------------------------------------------------------
