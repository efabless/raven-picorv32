//************************************************************************/
// File             : XSPRAM_1024X32_M8P.v
// Description      : Simple functional stand-in for X-Fab verilog model
//************************************************************************/

`timescale 1ns/10ps

module XSPRAM_1024X32_M8P (Q, D, A, CLK, CEn, WEn, OEn, RDY);

output [31:0]	Q;		// RAM data output

input  [31:0]	D;		// RAM data input bus
input  [9:0]	A;		// RAM address bus
input		CLK; 		// RAM clock
input		CEn;		// RAM enable
input		WEn;		// RAM  write enable, 0-active
input		OEn;		// RAM  output enable, 0-active
output		RDY;		// Test output

reg   [31:0] mem [0:1023];
reg   [31:0] Q;
reg	     RDY;

integer i;

initial begin
    for (i = 0; i < 1024; i = i + 1)
	mem[i] = 32'b0;
end

always @(posedge CLK or posedge CEn) begin
    if (CEn) begin
	RDY <= 0;
	Q <= 32'b0;
    end else begin
	RDY <= 1;
	if (!WEn) mem[A] <= D;
	if (!OEn) Q <= mem[A];
    end
end
endmodule

