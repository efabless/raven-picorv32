module aopac01_3v3 ( OUT, EN, IB, INN, INP, VDDA, VSSA );

  input IB;
  input EN;
  input VSSA;
  input VDDA;
  input INN;
  input INP;
  output OUT;

  wire real IB, VSSA, VDDA, INN, INP;
  reg  real OUT;
  wire real outval, nextout;
  real NaN;

  initial begin
     NaN = 0.0 / 0.0;
     OUT <= 0.0;
  end

  // Gain and poles are more or less randomly assigned here.
  // Updates are restricted to exact (1ns) intervals so that
  // equations remain valid for the same parameters.
 
  assign outval = 100.0 * (INP - INN);
  assign nextout = 0.999 * OUT + 0.001 * outval;

  always @(INN or INP or EN) begin
     if (EN == 1'b1) begin
	#1 OUT <= 0.99 * OUT + 0.01 * outval;
        if (nextout > VDDA) begin
	   #1 OUT <= VDDA;
	end else if (nextout < VSSA) begin
	   #1 OUT <= VSSA;
	end else begin
	   #1 OUT <= nextout;
	end
     end else if (EN == 1'b0) begin
	OUT <= 0.0;
     end else begin
	OUT <= NaN;
     end
  end
endmodule
