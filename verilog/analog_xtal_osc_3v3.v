module analog_xtal_osc_3v3 ( CLK, XI, XO, EN, GNDA, VDD, VDDA );

  output XO;
  input GNDA;
  input EN;
  input VDD;
  output CLK;
  input VDDA;
  input XI;

  reg real XO;
  wire real XI;
  wire real VDDA;
  wire real GNDA;

  reg CLK;
  real NaN;

  initial begin
     NaN = 0.0 / 0.0;
     CLK <= 1'b0;
  end

  always @(XI) begin
     if (EN == 1'b1) begin
	if (XI == NaN) begin
	   XO = NaN;
	   CLK <= 1'bx;
	end else if (VDDA == NaN) begin
	   XO = NaN;
	   CLK <= 1'bx;
        end else if (XI > XO) begin
	   CLK <= 1'b0;
	   #80;
	   XO = (VDDA / 2) + 0.1;
        end else begin
	   CLK <= 1'b1;
	   #80;
	   XO = (VDDA / 2) - 0.1;
        end
     end else if (EN == 1'b0) begin
	XO = XI;
	CLK <= 1'b0;
     end else begin
	XO = XI;
	CLK <= 1'bx;
     end
  end
endmodule
