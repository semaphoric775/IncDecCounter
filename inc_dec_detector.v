// inc_dec_detector module
//
// This module takes in a stream of ASCII characters one at a time through
// the data input . The data input should be ignored unless the valid input
// is high . The module detects when the sequence " INC" or " DEC" occurs in the
// stream and increments or decrements a 16 - bit counter output .
//
// Author : Eamon Murphy
// Email: epmurphy@ncsu.edu
// Github: https://github.com/semaphoric775
// Approach: My approach is to use a Moore FSM to implement the detector.
//      A combinational block will read the data on the input line (if valid is high) and set the next state.
//      At the positive edge of the clock, the FSM will move to this next state.
//      If the state shows the C at the end of INC or C at the end of DEC is reached,
//      the counter will increment or decrement appropriately.

module inc_dec_detector (
input clk, // clock for this module
input rst, // active high asynchronous reset
input[7:0] data, // 1 - byte input streaming data
input valid, // high when data is valid
output reg[15:0] cnt // counter output
);

//ascii codes for characters in "INC" and "DEC"
parameter ASCII_I = 8'h49;
parameter ASCII_N = 8'h4E;
parameter ASCII_C = 8'h43;
parameter ASCII_E = 8'h45;
parameter ASCII_D = 8'h44;

//state parameters
parameter INIT = 3'b000;
//states moved through when "inc" input
parameter I_INC = 3'b001;
parameter N_INC = 3'b010;
parameter C_INC = 3'b011; //counter should inc at this state
//states moved through when "dec" input
parameter D_DEC = 3'b100;
parameter E_DEC = 3'b101;
parameter C_DEC = 3'b110; //counter should dec at this state

//D flip flops holding the current state
reg[3:0] current_state;
//next_state is a register type but it should synthesize to wires driven by a combinational block
//using System Verilog's always_comb could force this 
reg[3:0] next_state;

//reset logic
always @(rst)
if(rst) begin
    current_state <= INIT;
    cnt <= 16'h0000;
end

//next state logic
always @(*)
//stay on current state ignoring data line when valid goes low
if(!valid)
    next_state <= current_state;
else
begin
   case (current_state)
   //for the long case statements, a task or function in System Verilog would be sensible
        INIT: case(data)
            ASCII_I: next_state <= I_INC;
            ASCII_D: next_state <= D_DEC;
            default: next_state <= INIT;
        endcase
        I_INC: if(data == ASCII_N) next_state <= N_INC; else next_state <= INIT;
        N_INC: if(data == ASCII_C) next_state <= C_INC; else next_state <= INIT;
        C_INC: case(data)
            ASCII_I: next_state <= I_INC;
            ASCII_D: next_state <= D_DEC;
            default: next_state <= INIT;
        endcase
        D_DEC: if(data == ASCII_E) next_state <= E_DEC; else next_state <= INIT;
        E_DEC: if(data == ASCII_C) next_state <= C_DEC; else next_state <= INIT;
        C_DEC: case(data)
            ASCII_I: next_state <= I_INC;
            ASCII_D: next_state <= D_DEC;
            default: next_state <= INIT;
        endcase
        default: next_state <= INIT;
   endcase 
end

always @(posedge clk)
    current_state <= next_state;

//decrement logic
//note that always@(*) should not be used here
//cnt would be included in the sensitivity list, creating an infinite loop in some simulators
//testing if valid is high or low is not needed
//if it is low, current_state does not change and this expression will not trigger
//if it is high, the current_state will change if at the end of "INC" or "DEC"
always @(current_state)
case(current_state)
C_INC: cnt <= (cnt < 65535) ? cnt+1 : cnt;
C_DEC: cnt <= (cnt > 0) ? cnt-1 : cnt;
default: cnt <= cnt;
endcase

endmodule