module aregc01_3v3 ( OUT, VIN3, GNDO, EN, GNDR, VDDO, VDDR, VDD, ENB );

  input VDD;
  input VDDO;
  input GNDO;
  input VDDR;
  input GNDR;
  input EN;
  output OUT;
  input ENB;
  input VIN3;

  wire real VDDR;
  reg real OUT;
  wire EN;
  real NaN;

  initial begin
     NaN = 0.0 / 0.0;
     OUT <= 0.0;
  end

  always @(VDDR or EN) begin
     if (EN == 1'b1) begin
        if (VDDR > 1.8) begin
	    OUT <= 1.8;
	end else begin
	    OUT <= VDDR;
	end
     end else if (EN == 1'b0) begin
	OUT <= 0.0;
     end else begin
	OUT <= NaN;
     end
  end
endmodule
