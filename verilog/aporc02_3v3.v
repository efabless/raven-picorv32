module aporc02_3v3 ( POR, PORB, VDDA, VSSA );

  output POR;
  input VSSA;
  input VDDA;
  output PORB;

  wire real VSSA;
  wire real VDDA;

  reg POR, PORB, powergood;
  real NaN;

  initial begin
     NaN = 0.0 / 0.0;
     POR <= 1'bx;
     PORB <= 1'bx;
     powergood <= 1'b0;
  end

  always @(VDDA) begin
     if (VDDA == NaN) begin
        POR <= 1'bx;
        PORB <= 1'bx;
        powergood <= 1'b0;
     end else if (VDDA > 2.09) begin
	if (powergood == 1'b0) begin
	   POR <= 1'b1;		// Raise reset
	   PORB <= 1'b0;	// Raise reset
	   #20000;
	   POR <= 1'b0;		// after 20us lower reset.
	   PORB <= 1'b1;	// after 20us lower reset.
	   powergood <= 1'b1;
	end

     end else if (VDDA < 0.5) begin
  	 POR <= 1'bx;
  	 PORB <= 1'bx;
	 powergood <= 1'b0;

     end else if (VDDA < 1.87) begin
	 if (powergood == 1'b1) begin
  	    POR <= 1'b1;	// Power supply dropped; raise reset
  	    PORB <= 1'b0;
	    powergood <= 1'b0;

         end else begin
    	    POR <= 1'b0;	// Not yet triggered
  	    PORB <= 1'b1;
         end
     end
  end
    
endmodule
