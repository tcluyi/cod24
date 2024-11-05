`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/25 11:53:35
// Design Name: 
// Module Name: pc_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_mux(
    input wire clk,  
    input wire reset, 
    input wire [31:0] pc_current,
    input wire [31:0] pc_target,
    input wire jump_en,
    output reg [31:0] pc_next,
    input wire stall_i
);

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_next <= 32'h8000_0000;
    end else if (stall_i) begin
      //nothing
    end else begin
      if (jump_en) pc_next <= pc_target;
      else pc_next <= pc_current + 4;
    end
  end
endmodule
