module aadcc01_3v3 ( D, EOC, CLK, EN, START, VDD, VDDA, VIN, VREFH, VREFL, VSS,
VSSA );

  input VDD;
  input VIN;
  input CLK;
  input VREFH;
  input EN;
  input VSSA;
  input VDDA;
  input VREFL;
  input START;
  output EOC;
  output  [9:0] D;
  input VSS;

  wire real VDD, VIN, VREFH, VSSA, VDDA, VREFL, VSS;

  integer count;
  real hold, fvalue, NaN;

  reg EOC;
  reg [9:0] D;

  initial begin
     EOC <= 1'b1;
     D <= 10'bx;
     count = 0;
     hold = VREFL;
     NaN = 0.0 / 0.0;
  end

  always @(posedge START) begin
     if (count == 0) begin
	count = 1;
     end
  end

  always @(posedge CLK) begin
     if (EN == 1'b0) begin
        EOC <= 1'b1;
        D <= 0;
	count = 12;
        hold = VREFL;

     end else begin
	if (count > 0) begin
	   if (count <= 12) begin
               count <= count + 1;
	   end else begin
	       count <= 0;
	   end

	   if ((count < 3) && (START == 1'b0)) begin
	      // Start pulse too short
	      count <= 0;
	   end else if (count == 2) begin
	      // Sample input
	      hold = VIN;
	   end else if (count == 3) begin
	      // Set start of conversion signal
	      EOC <= 1'b0;
	   end else if (count == 12) begin
	      if (hold == NaN) begin
	         D <= 10'bx;
	      end else if (VREFH == NaN) begin
	         D <= 10'bx;
	      end else if (hold > VREFH) begin
		 D <= 10'd1023;
	      end else if (VREFL == NaN) begin
	         D <= 10'bx;
	      end else if (hold < VREFL) begin
		 D <= 10'd0;
	      end else begin
	         fvalue = 1024 * (hold - VREFL) / (VREFH - VREFL);
	         D <= $rtoi(fvalue + 0.5);
	      end
	      EOC <= 1'b1;
	   end
	end        
     end
  end

endmodule
