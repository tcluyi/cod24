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


module ID (
    input wire clk,
    input wire reset,

    input wire [31:0] pc_i,
    input wire [31:0] inst_i,
    input wire [4:0] rf_waddr_exe_i,
    input wire [4:0] rf_waddr_mem_i,
    input wire [4:0] rf_waddr_wb_i,
    
    output reg [31:0] pc_o,
    output reg [31:0] inst_o,
    output reg [31:0] imm_o,
    output reg [4:0] rf_raddr_a_o,
    output reg [4:0] rf_raddr_b_o,
    output reg [4:0]  rf_waddr_o,

    //output reg [1:0] stall_time,
    output reg flush_o,
    output reg stall_o
);

  logic is_rtype, is_itype, is_stype, is_btype, is_jtype, is_utype;
  logic [31:0] imm_i, imm_s, imm_b, imm_j, imm_u;

  always_comb begin
    pc_o = pc_i;
    inst_o = inst_i;

    is_rtype = (inst_i[6:0] == 7'b0110011);
    is_itype = (inst_i[6:0] == 7'b0010011) || (inst_i[6:0] == 7'b1100111) || (inst_i[6:0] == 7'b0000011);
    is_stype = (inst_i[6:0] == 7'b0100011);
    is_btype = (inst_i[6:0] == 7'b1100011);
    is_jtype = (inst_i[6:0] == 7'b1101111);
    is_utype = (inst_i[6:0] == 7'b0110111);

	imm_i = {{20{inst_i[31]}}, inst_i[31:20]}; 
    imm_s = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}; 
	imm_b = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
	imm_j = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
	imm_u = {inst_i[31:12], {12{1'b0}}};

    rf_waddr_o = inst_i[11:7];
    rf_raddr_a_o = inst_i[19:15];
    rf_raddr_b_o = inst_i[24:20];
    imm_o = is_itype? imm_i : is_stype? imm_s : is_btype? imm_b : is_jtype? imm_j : is_utype? imm_u : 32'b0; 

    stall_o = (rf_waddr_exe_i && (inst_i[19:15] == rf_waddr_exe_i || inst_i[24:20] == rf_waddr_exe_i))? 1'b1 : 
                 (rf_waddr_mem_i && (inst_i[19:15] == rf_waddr_mem_i || inst_i[24:20] == rf_waddr_mem_i))? 1'b1 : 
                 (rf_waddr_wb_i && (inst_i[19:15] == rf_waddr_wb_i || inst_i[24:20] == rf_waddr_wb_i))? 1'b1 : 1'b0;
    flush_o = 1'b0;
  end

endmodule