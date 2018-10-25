module analog_ldo_3v3 ( OUT, VIN3, GNDA, EN, VDDA, VDD, ENB );

  input VDD;
  input VDDA;
  input GNDA;
  input EN;
  output OUT;
  input ENB;
  input VIN3;

  wire real VDDA;
  wire real GNDA;
  wire real VDD;
  reg real OUT;
  wire EN;
  real NaN;

  initial begin
     NaN = 0.0 / 0.0;
     OUT <= 0.0;
  end

  always @(VDDA or EN) begin
     if (EN == 1'b1) begin
        if (VDDA > 1.8) begin
	    OUT <= 1.8;
	end else begin
	    OUT <= VDDA;
	end
     end else if (EN == 1'b0) begin
	OUT <= 0.0;
     end else begin
	OUT <= NaN;
     end
  end
endmodule
