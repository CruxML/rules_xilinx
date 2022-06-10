
module load_data (
    input  logic clk,
    input  logic rst,
    output logic value
);

  logic [ 4:0] count;
  logic [31:0] data  [1];

  initial begin
    $readmemh("tests/basic/some_data.dat", data);
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= 0;
    end else begin
      value <= data[0][count];
    end
  end

endmodule
