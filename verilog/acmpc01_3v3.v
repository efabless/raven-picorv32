module acmpc01_3v3 ( OUT, EN, IBN, INN, INP, VDDA, VSSA );

  input IBN;
  input EN;
  input VSSA;
  input VDDA;
  input INN;
  input INP;
  output OUT;

  wire real IBN, VSSA, VDDA, INN, INP;

  reg OUT;
  real NaN;

  initial begin
     NaN = 0.0 / 0.0;
     if (EN == 1'b1) begin
	if (INP == NaN) begin
	    OUT <= 1'bx;
	end else if (INN == NaN) begin
	    OUT <= 1'bx;
	end else if (INP > INN) begin
	    OUT <= 1'b1;
	end else begin
	    OUT <= 1'b0;
	end
     end else begin
	OUT <= 1'b0;
     end
  end

  always @(INN or INP or EN) begin
     if (EN == 1'b1) begin
	if (INP == NaN) begin
	    OUT <= 1'bx;
	end else if (INN == NaN) begin
	    OUT <= 1'bx;
	end else if (INP > INN) begin
	    OUT <= 1'b1;
	end else begin
	    OUT <= 1'b0;
	end
     end else begin
	OUT <= 1'b0;
     end
  end
endmodule
