// Functional verilog model for level shift cell LS_3VX2
// (1.8V to 3.3V level-shift-up)

module LS_3VX2(
    input VDD3V3,
    input VDD1V8,
    input VSSA,
    input A,
    output Q
);

    wire real VDD3V3, VDD1V8, VSSA;
    wire A, Q;

    assign Q = A;

endmodule
