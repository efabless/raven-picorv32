module axtoc02_3v3 ( CLK, XI, XO, EN, GNDO, GNDR, VDD, VDDO, VDDR );

  output XO;
  input GNDO;
  input EN;
  input GNDR;
  input VDDR;
  input VDD;
  output CLK;
  input VDDO;
  input XI;

  reg real XO;
  wire real XI;
  wire real VDDR;

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
	end else if (VDDR == NaN) begin
	   XO = NaN;
	   CLK <= 1'bx;
        end else if (XI > XO) begin
	   CLK <= 1'b0;
	   #80;
	   XO = (VDDR / 2) + 0.1;
        end else begin
	   CLK <= 1'b1;
	   #80;
	   XO = (VDDR / 2) - 0.1;
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
