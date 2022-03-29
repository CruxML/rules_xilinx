module empty_top (
    output logic [7:0] leds
);

  logic [15:0] a, b, c;

  always_comb begin
    a = 16'h1122;
    b = 16'h2233;
    leds = c[7:0];
  end

  // Include a HLS module.
  adder adder (
      .ap_start(1'b1),
      .a,
      .b,
      .c
  );

endmodule
