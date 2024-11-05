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


module MEM_WB (
    input wire clk,
    input wire reset,

    input wire [31:0] pc_i,
    input wire [31:0] inst_i,
    input wire [31:0] imm_i,
    input wire [4:0] rf_waddr_i,
    input wire [31:0] mem_data_i,
    input wire [31:0] alu_y_i,
    
    output reg [31:0] pc_o,
    output reg [31:0] inst_o,
    output reg [31:0] imm_o,
    output reg [4:0]  rf_waddr_o,
    output reg [31:0] mem_data_o,
    output reg [31:0] alu_y_o,

    input wire stall_i,
    input wire bubble_i
);

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_o <= 32'h8000_0000;
      inst_o <= 32'b0;
      imm_o <= 32'b0;
      rf_waddr_o <= 4'b0;
      mem_data_o <= 32'b0;
      alu_y_o <= 32'b0;
    end else if (stall_i) begin
      //do nothing
    end else if (bubble_i) begin
      pc_o <= 32'b0;
      inst_o <= 32'b0;
      imm_o <= 32'b0;
      rf_waddr_o <= 4'b0;
      mem_data_o <= 32'b0;
      alu_y_o <= 32'b0;
    end else begin
      pc_o <= pc_i;
      inst_o <= inst_i;
      imm_o <= imm_i;
      rf_waddr_o <= rf_waddr_i;
      mem_data_o <= mem_data_i;
      alu_y_o <= alu_y_i;
    end
  end
endmodule