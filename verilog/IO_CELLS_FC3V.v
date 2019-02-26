//************************************************************************
// Simple functional stand-in for X-Fab I/O cells IO_CELLS_FC3V.v
//************************************************************************

`timescale 1ns/10ps


//****************************************************************************
//   technology       : xh018
//   module name      : BT4FC
//   cell_description : Tri-state output Buffer, Strength 4mA @ 3.3 V,
//                      Normal, High noise (Fast speed)
//****************************************************************************

module BT4FC (A, EN, GNDO, GNDR, PAD, VDD3, VDDO, VDDR);

   input     A, EN, GNDO, GNDR, VDD3, VDDO, VDDR;
   output    PAD;

   wire      ck_sub, ck_GNDO, ck_GNDR, ck_VDD3, ck_VDDO, ck_VDDR;

   check_gnd i0  (ck_GNDO, GNDO);
   check_gnd i1  (ck_GNDR, GNDR);
   check_vdd i2  (ck_VDD3, VDD3);
   check_vdd i3  (ck_VDDO, VDDO);
   check_vdd i4  (ck_VDDR, VDDR);

   and       i5  (ck_sub, ck_GNDO, ck_GNDR, ck_VDD3, ck_VDDO, ck_VDDR);

   check_buf i6  (ck_A, A, ck_sub);
   check_buf i7  (ck_EN, EN, ck_sub);

// Function PAD: A; Tristate function: EN
   bufif0    i8  (PAD, ck_A, ck_EN);

// timing section:
   specify

      (A +=> PAD) = (0.02, 0.02);
      (EN  => PAD) = (0.02, 0.02, 0.02, 0.02, 0.02, 0.02);

   endspecify
endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : ICFC
//   cell_description : Non-Inverting CMOS Input Buffer
//****************************************************************************

module ICFC (GNDO, GNDR, PAD, PI, PO, VDD3, VDDO, VDDR, Y);

   input     GNDO, GNDR, PAD, PI, VDD3, VDDO, VDDR;
   output    PO, Y;

   wire real GNDO, GNDR, VDD3, VDDO, VDDR;

   wire      ck_sub, ck_GNDO, ck_GNDR, ck_VDD3, ck_VDDO, ck_VDDR;

   check_gnd i0  (ck_GNDO, GNDO);
   check_gnd i1  (ck_GNDR, GNDR);
   check_vdd i2  (ck_VDD3, VDD3);
   check_vdd i3  (ck_VDDO, VDDO);
   check_vdd i4  (ck_VDDR, VDDR);

   and       i5  (ck_sub, ck_GNDO, ck_GNDR, ck_VDD3, ck_VDDO, ck_VDDR);

   check_buf i6  (ck_PAD, PAD, ck_sub);
   check_buf i7  (ck_PI, PI, ck_sub);

// Function PO: !(PAD&PI)
   nand      i8  (PO, ck_PAD, ck_PI);

// Function Y: PAD
   buf       i10 (Y, ck_PAD);

// timing section:
   specify

      (PAD -=> PO) = (0.02, 0.02);
      (PI -=> PO) = (0.02, 0.02);

      (PAD +=> Y) = (0.02, 0.02);

   endspecify
endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : POWERCUTVDD3FC
//   cell_description : Power cut cell 5um width for isolating VDD3
//   last modified by : Tim Edwards
//****************************************************************************

module POWERCUTVDD3FC (GNDO, GNDR, VDDO, VDDR);

   input     GNDO, GNDR, VDDO, VDDR;

endmodule

//****************************************************************************
//   technology       : xh018
//   module name      : VDDPADFC
//   cell_description : VDD3 core and IO supply cell
//****************************************************************************

module VDDPADFC (GNDO, GNDR, VDD3, VDDO, VDDR);

   input     GNDO, GNDR, VDD3, VDDO, VDDR;

endmodule

