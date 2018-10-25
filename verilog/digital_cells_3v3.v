//************************************************************************
// Simple functional models for basic digital standard cells
// Process:  non-specific
//************************************************************************

`timescale 1ns/10ps

//****************************************************************************
//   technology  : Non-specific
//   module name : digital_bufx2_3v3
//   description : Buffer
//****************************************************************************

module digital_bufx2_3v3 (A, Q);

   input     A;
   output    Q;

   // Function Q = A
   wire Q;
   assign Q = A;

endmodule

//****************************************************************************
//   technology  : Non-specific
//   module name : digital_inv_x2_3v3
//   description : Inverter
//****************************************************************************

module digital_invx2_3v3 (A, Q);

   input     A;
   output    Q;

   // Function Q = !A
   wire Q;
   assign Q = !A;

endmodule

//****************************************************************************
//   technology  : Non-specifc
//   module name : digital_logic0_3v3
//   description : Constant logic 0
//****************************************************************************

module digital_logic0_3v3 (Q);

   output    Q;

   // Function Q = 0
   wire Q;
   assign Q = 1'b0;

endmodule

//****************************************************************************
//   technology  : Non-specific
//   module name : digital_logic1_3v3
//   description : Constant logic 1
//****************************************************************************

module digital_logic1_3v3 (Q);

   output    Q;

   // Function Q = 1
   wire Q;
   assign Q = 1'b1;

endmodule

//****************************************************************************

