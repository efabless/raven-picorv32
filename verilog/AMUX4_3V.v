// Analog 4-input, 1-output multiplexer
// with 1.8V digital select.
//
// NOTE:  This is a simple functional model only and captures
// none of the internal workings of the multiplexer, such
// as double-gating each input and connecting the middle node
// to VSSA on the unselected input.

module AMUX4_3V (
   input real VDD3V3,
   input real VDD1V8,
   input real VSSA,
   input real AIN1,
   input real AIN2,
   input real AIN3,
   input real AIN4,
   output real AOUT,
   input [1:0] SEL
);
   wire real VDD3V3, VDD1V8, VSSA;
   wire real AIN1, AIN2, AIN3, AIN4;
   wire real AOUT;
   wire [1:0] SEL;
   real NaN;

   initial begin
      NaN = 0.0 / 0.0;
   end

   assign AOUT = (SEL == 2'b11) ? AIN4 :
		    (SEL == 2'b10) ? AIN3 :
		    (SEL == 2'b01) ? AIN2 :
		    (SEL == 2'b00) ? AIN1 :
		    NaN;

endmodule
