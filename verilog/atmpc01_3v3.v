module atmpc01_3v3 ( OVT, EN, VDDA, VSSA );

  input EN;
  input VSSA;
  input VDDA;
  output OVT;

  wire real VDDA, VSSA;
  reg OVT;

  // NOTE:  There is no way to declare temperature in verilog
  // without adding an input to the module.  So just assume
  // that the output always reads zero.
 
  initial begin
     OVT <= 1'b0;
  end
endmodule
