// TODO: When rvalid is low, the inferred fifo has invalid data at the output port, the builtin fifo has the last valid data.
// This should be resolved in the future.
module fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int FIFO_DEPTH = 16,
    parameter bit BUILT_IN   = 0
) (
    input clk,
    input rst,
    output logic [DATA_WIDTH - 1:0] rdata,
    input logic [DATA_WIDTH - 1:0] wdata,
    input logic ren,
    input logic wen,
    output logic wready,
    output logic rvalid,
    output logic rerr,
    output logic werr
);
  initial begin
    // Data width needs to be less or equal to 72.
    assert (DATA_WIDTH <= 72);

  end
  if (BUILT_IN) begin : xilinx_built_in
    localparam FIFO_DATA_WIDTH = (DATA_WIDTH <= 4) ? 4 : (DATA_WIDTH <= 9) ? 8 : (DATA_WIDTH <= 18) ? 16:(DATA_WIDTH <= 36) ? 32:64;
    localparam FIFO_PARITY_WIDTH = (DATA_WIDTH <= 4) ? 0 : (DATA_WIDTH <= 9) ? 1 : (DATA_WIDTH <= 18) ? 2:(DATA_WIDTH <= 36) ? 4:8;
    localparam ROUNDED_DATA_WIDTH = FIFO_DATA_WIDTH + FIFO_PARITY_WIDTH;
    logic [ROUNDED_DATA_WIDTH-1:0] data_in_tmp;
    logic [ROUNDED_DATA_WIDTH-1:0] data_out_tmp;
    logic empty;
    logic full;
    assign wready = !full;
    assign rvalid = !empty;

    assign data_in_tmp = {{(ROUNDED_DATA_WIDTH - DATA_WIDTH) {1'b0}}, wdata};
    assign rdata = data_out_tmp[DATA_WIDTH-1:0];

    FIFO36E2 #(
        .CASCADE_ORDER("NONE"),
        .CLOCK_DOMAINS("COMMON"),
        .EN_ECC_PIPE("FALSE"),
        .EN_ECC_READ("FALSE"),
        .EN_ECC_WRITE("FALSE"),
        .FIRST_WORD_FALL_THROUGH("TRUE"),
        .INIT(72'h000000000000000000),
        .PROG_EMPTY_THRESH(256),
        .PROG_FULL_THRESH(256),
        .IS_RDCLK_INVERTED(1'b0),
        .IS_RDEN_INVERTED(1'b0),
        .IS_RSTREG_INVERTED(1'b0),
        .IS_RST_INVERTED(1'b0),
        .IS_WRCLK_INVERTED(1'b0),
        .IS_WREN_INVERTED(1'b0),
        .RDCOUNT_TYPE("RAW_PNTR"),
        .READ_WIDTH(ROUNDED_DATA_WIDTH),
        .REGISTER_MODE("UNREGISTERED"),
        .RSTREG_PRIORITY("RSTREG"),
        .SLEEP_ASYNC("FALSE"),
        .SRVAL(72'h000000000000000000),
        .WRCOUNT_TYPE("RAW_PNTR"),
        .WRITE_WIDTH(ROUNDED_DATA_WIDTH)
    ) FIFO36E2 (
        // Turn off lint for empty ports.
        /* verilator lint_off PINCONNECTEMPTY */
        .CASDOUT(),
        .CASDOUTP(),
        .CASNXTEMPTY(),
        .CASPRVRDEN(),
        .DBITERR(),
        .ECCPARITY(),
        .SBITERR(),
        .DOUT(data_out_tmp[FIFO_DATA_WIDTH-1:0]),
        .DOUTP(data_out_tmp[ROUNDED_DATA_WIDTH-1:FIFO_DATA_WIDTH]),
        .EMPTY(empty),
        .FULL(full),
        .PROGEMPTY(),
        .PROGFULL(),
        .RDCOUNT(),
        .RDERR(),
        .RDRSTBUSY(),
        .WRCOUNT(),
        .WRERR(),
        .WRRSTBUSY(),
        /* verilator lint_on PINCONNECTEMPTY */
        .CASDIN(1'b0),
        .CASDINP(1'b0),
        .CASDOMUX(1'b0),
        .CASDOMUXEN(1'b0),
        .CASNXTRDEN(1'b0),
        .CASOREGIMUX(1'b0),
        .CASOREGIMUXEN(1'b0),
        .CASPRVEMPTY(1'b0),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(clk),
        .RDEN(ren),
        .REGCE(1'b1),
        .RSTREG(1'b1),
        .SLEEP(1'b0),
        .RST(rst),
        .WRCLK(clk),
        .WREN(wen),
        .DIN(data_in_tmp[FIFO_DATA_WIDTH-1:0]),
        .DINP(data_in_tmp[ROUNDED_DATA_WIDTH-1:FIFO_DATA_WIDTH])
    );


    // Seems like it can't be inferred properly :/
    // https://support.xilinx.com/s/question/0D52E000074KxXQSA0/is-it-possible-for-vivado-to-actually-infer-bram-fifo
  end else begin : inferred
    logic [$clog2(FIFO_DEPTH) - 1:0] waddr, raddr, waddr_next;
    (* RAM_STYLE = "BLOCK" *)
    logic [FIFO_DEPTH - 1:0][DATA_WIDTH-1:0] fifo_data;
    logic [1:0] push_pop;
    logic empty, full;

    always_comb begin
      waddr_next = waddr + 1;
      empty = waddr == raddr;
      full = waddr_next == raddr;
      push_pop = {wen, ren};

      rdata = fifo_data[raddr];
      rvalid = !empty;
      wready = !full;
    end

    always_ff @(posedge clk) begin
      if (rst) begin
        waddr <= 0;
        raddr <= 0;
        rerr  <= 0;
        werr  <= 0;
      end else begin
        case (push_pop)
          2'b00: ;  // Do nothing
          2'b01: begin  // Just read.
            if (!empty) begin
              raddr <= raddr + 1;
            end else begin
              rerr <= 1;
            end
          end
          2'b10: begin  // Just write.
            if (wready) begin
              waddr <= waddr_next;
              fifo_data[waddr] <= wdata;
            end else begin
              werr <= 1;
            end
          end
          2'b11: begin  // Read and write.
            // TODO(stridge) implement first word fall through? Leave unimplemented for now.
            if (!empty) begin
              raddr <= raddr + 1;
            end else begin
              rerr <= 1;
            end
            if (wready) begin
              waddr <= waddr_next;
              fifo_data[waddr] <= wdata;
            end else begin
              werr <= 1;
            end
          end
        endcase
      end
    end
  end
endmodule
