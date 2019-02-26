//Verilog HDL for "XH018_UPDATE_12_2009", "adacc01_3v3" "functional"


module adacc01_3v3 ( OUT, D, EN, VDD, VDDA, VREFH, VREFL, VSS, VSSA );

  input VDD;
  input VREFH;
  input EN;
  input VSSA;
  input VDDA;
  input VREFL;
  input [9:0] D;
  output OUT;
  input VSS;

  wire real VDD, VSSA, VDDA, VREFL, VREFH, VSS;
  reg  real OUT;
  real NaN;

  wire [10:0] Dext;	// unsigned extended

  assign Dext = {1'b0, D};

  initial begin
     NaN = 0.0 / 0.0;
     if (EN == 1'b0) begin
	OUT <= 0.0;
     end else if (VREFH == NaN) begin
	OUT <= NaN;
     end else if (VREFL == NaN) begin
	OUT <= NaN;
     end else if (EN == 1'b1) begin
	OUT <= VREFL + ($itor(Dext) / 1023.0) * (VREFH - VREFL);
     end else begin
	OUT <= NaN;
     end
  end

  always @(D or EN or VREFH or VREFL) begin
     if (EN == 1'b0) begin
	OUT <= 0.0;
     end else if (VREFH == NaN) begin
	OUT <= NaN;
     end else if (VREFL == NaN) begin
	OUT <= NaN;
     end else if (EN == 1'b1) begin
	OUT <= VREFL + ($itor(Dext) / 1023.0) * (VREFH - VREFL);
     end else begin
	OUT <= NaN;
     end
  end 

endmodule
