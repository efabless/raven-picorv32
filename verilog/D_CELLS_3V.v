//************************************************************************
// Simple functional stand-in for X-Fab verilog models for D_CELLS_3V
// Process:  XH018
//************************************************************************

`timescale 1ns/10ps

//****************************************************************************
//   technology  : X-Fab XH018
//   module name : BU_3VX2
//   description : Buffer
//****************************************************************************

module BU_3VX2 (A, Q);

   input     A;
   output    Q;

   // Function Q = A
   wire Q;
   assign Q = A;

endmodule

//****************************************************************************
//   technology  : X-Fab XH018
//   module name : IN_3VX2
//   description : Inverter
//****************************************************************************

module IN_3VX2 (A, Q);

   input     A;
   output    Q;

   // Function Q = !A
   wire Q;
   assign Q = !A;

endmodule

//****************************************************************************
//   technology  : X-Fab XH018
//   module name : LOGIC0_3V
//   description : Constant logic 0
//****************************************************************************

module LOGIC0_3V (Q);

   output    Q;

   // Function Q = 0
   wire Q;
   assign Q = 1'b0;

endmodule

//****************************************************************************
//   technology  : X-Fab XH018
//   module name : LOGIC1_3V
//   description : Constant logic 1
//****************************************************************************

module LOGIC1_3V (Q);

   output    Q;

   // Function Q = 1
   wire Q;
   assign Q = 1'b1;

endmodule

//****************************************************************************

