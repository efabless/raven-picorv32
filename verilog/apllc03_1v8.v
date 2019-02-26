module apllc03_1v8 ( CLK, VCO_IN, VDDA, VDDD, VSSA, VSSD, B, B_CP, B_VCO, EN_CP, EN_VCO, REF );

  input VSSD;
  input EN_VCO;
  input EN_CP;
  output B_VCO;
  output B_CP;
  input VSSA;
  input VDDD;
  input VDDA;
  input VCO_IN;
  output CLK;
  input REF;
  input  [3:0] B;

  reg CLK;
  real period, lastedge, refpd;
  wire real VSSD, VSSA, VDDD, VDDA;
  reg real B_VCO, B_CP;

  initial begin
     lastedge = 0.0;
     period = 25.0;	// 25ns period = 40MHz
     CLK <= 0;
     B_VCO <= 1.0;	// Bogus values to tell bias generator
     B_CP <= 1.0;	// that something is connected to it.
  end

  // Toggle clock at rate determined by period
  always @(CLK or EN_VCO) begin
     if (EN_VCO == 1'b1) begin
        #(period / 2.0);
        CLK <= (CLK === 1'b0);
     end else if (EN_VCO == 1'b0) begin
        CLK <= 1'b0;
     end else begin
        CLK <= 1'bx;
     end
  end
   
  // Update period on every reference rising edge
  always @(posedge REF) begin
     if (lastedge > 0.0) begin
	refpd = $realtime - lastedge;
	// Adjust period towards 1/8 the reference period
        period = (0.99 * period) + (0.01 * (refpd / 8.0));
     end
     lastedge = $realtime;
  end
endmodule
