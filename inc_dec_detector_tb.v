`include "inc_dec_detector.v"

module inc_dec_detector_tb();
reg clk; // clock for this module
reg rst; // active high asynchronous reset
reg[7:0] data; // 1 - byte input streaming data
reg valid; // high when data is valid
wire[15:0] cnt; // counter output
inc_dec_detector DUT(clk, rst, data, valid, cnt);

always #5 clk = ~clk;

initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, inc_dec_detector_tb);
    $monitor("clk: 1'b%b, cnt: 16'h%h", clk, cnt);
    clk = 1'b0;
    valid = 1'b0;
    rst = 1'b0;
    #3
    rst = 1'b1;
    valid = 1'b1;
    #2
    #10
    rst = 1'b0;
    data = 8'h49;
    #10
    data = 8'h4E;
    #10
    data = 8'h43;
    #10
    valid = 1'b0;
    data = 8'h69;
    #10
    valid = 1'b1;
    data = 8'h44;
    #10
    valid = 1'b0;
    #10
    data = 8'h45;
    valid = 1'b1;
    #10
    data = 8'h43;
    #10
    data = 8'h00;
    #40
    $finish;
end

endmodule