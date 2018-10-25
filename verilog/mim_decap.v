/* Simple verilog model for device cmm5t for LVS purposes */

module cmm5t #(
    parameter [ 0:0] A = 1.0,
    parameter [ 0:0] P = 1.0
) (
	input real top,
	input real bottom,
	input real subs
);

wire real top, bottom, subs;

/* Not modeled, for LVS purposes only */

endmodule	// cmm5t
