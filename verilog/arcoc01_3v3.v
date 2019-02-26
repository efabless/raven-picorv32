module arcoc01_3v3 ( CLK, EN, VDDA, VSSA );

  output CLK;
  input EN;
  input VSSA;
  input VDDA;

  wire real VDDA, VSSA;

  reg CLK;

  initial begin
     if (EN == 1'b1) begin
        CLK <= 1'b0;
     end else if (EN == 1'b0) begin
        CLK <= 1'b0;
     end else begin
        CLK <= 1'bx;
     end
  end

  // arcoc01: typ Fclk = 100 kHz
  // = 10E3 ns period;  1/2 period = 5E3 ns.
  always @(CLK or EN) begin
     if (EN == 1'b1) begin
        #5000;
        CLK <= (CLK === 1'b0);
     end else if (EN == 1'b0) begin
        CLK <= 1'b0;
     end else begin
        CLK <= 1'bx;
     end
  end

endmodule
