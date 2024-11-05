`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/27 00:49:55
// Design Name: 
// Module Name: ID
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


module IF_ID (
    input wire clk,
    input wire reset,

    input wire [31:0] pc_i,
    input wire [31:0] inst_i,
    
    output reg [31:0] pc_o,
    output reg [31:0] inst_o,

    input wire stall_i,
    input wire bubble_i
);

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_o <= 32'h8000_0000;
      inst_o <= 32'b0;
    end else if (stall_i) begin
      //do nothing
    end else if (bubble_i) begin
      pc_o <= 32'b0;
      inst_o <= 32'b0;
    end else begin
      pc_o <= pc_i;
      inst_o <= inst_i;
    end
  end
endmodule