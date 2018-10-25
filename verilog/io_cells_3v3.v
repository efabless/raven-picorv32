//************************************************************************
// Simple functional models for I/O cells with 3.3V pad, 3.3V core
//************************************************************************

`timescale 1ns/10ps

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_bidirectional_3v3
//   cell_description : Tri-state output Buffer (3.3V)
//****************************************************************************

module io_bidirectional_3v3 (A, EN, GNDA, PAD, VDD3, VDDA);

   input     A, EN, GNDA, VDD3, VDDA;
   output    PAD;

   wire      ck_sub, ck_GNDA, ck_VDD3, ck_VDDA;

   check_gnd i0  (ck_GNDA, GNDA);
   check_vdd i1  (ck_VDD3, VDD3);
   check_vdd i2  (ck_VDDA, VDDA);

   and       i3  (ck_sub, ck_GNDA, ck_VDD3, ck_VDDA);

   check_buf i4  (ck_A, A, ck_sub);
   check_buf i5  (ck_EN, EN, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i6  (PAD, ck_A, ck_EN);

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_input_3v3
//   cell_description : Non-Inverting CMOS Input Buffer
//****************************************************************************

module io_input_3v3 (GNDA, PAD, PI, PO, VDD3, VDDA, Y);

   input     GNDA, PAD, PI, VDD3, VDDA;
   output    PO, Y;

   wire real GNDA, VDD3, VDDA;

   wire      ck_sub, ck_GNDA, ck_VDD3, ck_VDDA;

   check_gnd i0  (ck_GNDA, GNDA);
   check_vdd i1  (ck_VDD3, VDD3);
   check_vdd i2  (ck_VDDA, VDDA);

   and       i3  (ck_sub, ck_GNDA, ck_VDD3, ck_VDDA);

   check_buf i4  (ck_PAD, PAD, ck_sub);
   check_buf i5  (ck_PI, PI, ck_sub);

// Function PO: !(PAD&PI)
   nand      i6  (PO, ck_PAD, ck_PI);

// Function Y: PAD
   buf       i10 (Y, ck_PAD);

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_vdd_domain_cut
//   cell_description : Power cut cell for isolating VDD3 domain
//****************************************************************************

module io_vdd_domain_cut (GNDA, VDDA);

   input     GNDA, VDDA;

endmodule

//****************************************************************************
//   technology       : Non-specific
//   module name      : io_vdd3
//   cell_description : VDD3 core and IO supply cell
//****************************************************************************

module io_vdd3 (GNDA, VDD3, VDDA);

   input     GNDA, VDD3, VDDA;

endmodule

