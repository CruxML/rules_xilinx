// TODO(stridge) Add verilog tester.
module fifo_tb ();

  logic clk = 0;
  logic rst = 0;
  logic
      wen,
      ren,
      wready_builtin,
      rvalid_builtin,
      wready_inferred,
      rvalid_inferred,
      rerr_inferred,
      werr_inferred,
      rerr_builtin,
      werr_builtin;

  logic [71:0] wdata, r_data_builtin, rdata_inferred;

  always #10ns clk = !clk;

  fifo #(
      .DATA_WIDTH(72),
      .BUILT_IN  (1),
      .FIFO_DEPTH(100)
  ) fifo_built_in (
      .clk,
      .rst,
      .rdata (r_data_builtin),
      .wdata,
      .ren,
      .wen,
      .wready(wready_builtin),
      .rvalid(rvalid_builtin),
      .rerr  (rerr_builtin),
      .werr  (werr_builtin)
  );

  fifo #(
      .DATA_WIDTH(72),
      .BUILT_IN  (0),
      .FIFO_DEPTH(100)
  ) fifo_inferred (
      .clk,
      .rst,
      .rdata (rdata_inferred),
      .wdata,
      .ren,
      .wen,
      .wready(wready_inferred),
      .rvalid(rvalid_inferred),
      .rerr  (rerr_inferred),
      .werr  (werr_inferred)
  );

  initial begin
    rst   = 1;
    wen   = 0;
    ren   = 0;
    wdata = 0;
    repeat (10) @(negedge clk);
    rst = 0;
    repeat (50) @(negedge clk);
    wen = 1;
    for (int i = 0; i < 100; i++) begin
      wdata = i + 72'hFF000000FF00AA0000;
      @(negedge clk);
    end
    wen = 0;
    @(negedge clk);
    ren = 1;
    for (int i = 0; i < 100; i++) begin
      assert (r_data_builtin === i + 72'hFF000000FF00AA0000);
`ifdef PASSING_TEST
      assert (r_data_builtin === rdata_inferred);
`else
      assert (r_data_builtin === rdata_inferred + 1);
`endif
      @(negedge clk);
    end
    $finish();
  end

endmodule
