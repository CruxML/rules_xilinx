module zcu111_top (
    output logic [7:0] leds
);

  logic axi_clk;
  logic axi_rst;
  logic clk_250;
  logic rst_250;

  logic [7:0] led_values;

  always_comb begin
    led_values = 8'hA5;
    for (int i = 1; i < 8; i++) begin
      leds[i] = led_values[i];
    end
  end

  zynq_axi zynq_axi (
      .axi_clk(axi_clk),
      .axi_rst(axi_rst),
      .clk_250(clk_250),
      .rst_250(rst_250),
      .m_axi_araddr(),
      .m_axi_arburst(),
      .m_axi_arcache(),
      .m_axi_arid(),
      .m_axi_arlen(),
      .m_axi_arlock(),
      .m_axi_arprot(),
      .m_axi_arqos(),
      .m_axi_arready(1'b1),
      .m_axi_arsize(),
      .m_axi_aruser(),
      .m_axi_arvalid(),
      .m_axi_awaddr(),
      .m_axi_awburst(),
      .m_axi_awcache(),
      .m_axi_awid(),
      .m_axi_awlen(),
      .m_axi_awlock(),
      .m_axi_awprot(),
      .m_axi_awqos(),
      .m_axi_awready(1'b1),
      .m_axi_awsize(),
      .m_axi_awuser(),
      .m_axi_awvalid(),
      .m_axi_bid(8'h0),
      .m_axi_bready(),
      .m_axi_bresp(2'b0),
      .m_axi_bvalid(1'b1),
      .m_axi_rdata(64'h0),
      .m_axi_rid(8'h0),
      .m_axi_rlast(1'b1),
      .m_axi_rready(),
      .m_axi_rresp(2'b0),
      .m_axi_rvalid(1'b1),
      .m_axi_wdata(),
      .m_axi_wlast(),
      .m_axi_wready(1'b1),
      .m_axi_wstrb(),
      .m_axi_wvalid()
  );

  zcu111_submodule zcu111_submodule (
      .a(led_values[0]),
      .b(leds[0])
  );

endmodule
