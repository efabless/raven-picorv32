module abgpc01_3v3 ( VBGP, VBGVTN, EN, VDDA, VSSA );

  input EN;
  output VBGP;
  input VSSA;
  input VDDA;
  output VBGVTN;

  wire real VDDA, VSSA;
  reg real VBGP, VBGVTN;

  initial begin
     if (EN == 1'b1) begin
        VBGP <= 1.235;
        VBGVTN <= 1.018;
     end else begin
        VBGP <= 0.0;
        VBGVTN <= 0.0;
     end
  end

  always @(EN) begin
     if (EN == 1'b1) begin
        VBGP <= 1.235;
        VBGVTN <= 1.018;
     end else begin
        VBGP <= 0.0;
        VBGVTN <= 0.0;
     end
  end

endmodule
