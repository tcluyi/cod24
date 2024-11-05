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


module EXE (
    input wire clk,
    input wire reset,

    input wire [31:0] pc_i,
    input wire [31:0] inst_i,
    input wire [31:0] imm_i,
    input wire [31:0] rf_rdata_a_i,
    input wire [31:0] rf_rdata_b_i,
    input wire [4:0]  rf_waddr_i,
    
    output reg [31:0] pc_o,
    output reg [31:0] inst_o,
    output reg [31:0] imm_o,
    output reg [4:0]  rf_waddr_o,
    output reg [31:0] pc_target_o,
    output reg jump_en_o,
    output reg [31:0] mem_addr_o,
    output reg [31:0] mem_data_o,
    output reg mem_w_o,
    output reg mem_en_o,
    
    output reg [31:0] alu_a_o,
    output reg [31:0] alu_b_o,
    output reg [3:0] alu_op_o,
      
    output reg flush_o,
    output reg stall_o
);

  logic is_rtype, is_itype1, is_itype2, is_stype, is_btype, is_jtype, is_utype;
  logic [31:0] temp;

  always_comb begin
    pc_o = pc_i;
    inst_o = inst_i;
    imm_o = imm_i;
    rf_waddr_o = rf_waddr_i;

    is_rtype = (inst_i[6:0] == 7'b0110011);
    is_itype1 = (inst_i[6:0] == 7'b0010011);
    is_itype2 = (inst_i[6:0] == 7'b1100111) || (inst_i[6:0] == 7'b0000011);
    is_stype = (inst_i[6:0] == 7'b0100011);
    is_btype = (inst_i[6:0] == 7'b1100011);
    is_jtype = (inst_i[6:0] == 7'b1101111);
    is_utype = (inst_i[6:0] == 7'b0110111);
    
    stall_o = 1'b0;
    flush_o = jump_en_o;
  end

  always_comb begin
    if (is_rtype) begin
      alu_a_o = rf_rdata_a_i;
      alu_b_o = rf_rdata_b_i;
      case (inst_i[14:12])
        3'b000: alu_op_o = 4'b0001;
        3'b111: alu_op_o = 4'b0011;
        3'b110: alu_op_o = 4'b0100;
        3'b100: alu_op_o = 4'b0101;
        default: alu_op_o =4'b0000;
      endcase
    end else if (is_itype1) begin
      alu_a_o = rf_rdata_a_i;
      alu_b_o = imm_i;
      case (inst_i[14:12])
        3'b000: alu_op_o = 4'b0001;
        3'b111: alu_op_o = 4'b0011;
        3'b110: alu_op_o = 4'b0100;
        3'b001: alu_op_o = 4'b0111;
        3'b101: alu_op_o = 4'b1000;
        default: alu_op_o =4'b0000;
      endcase
    end else begin
      alu_op_o = 4'b0000;
    end
  end

  always_comb begin
    if (is_rtype) begin
      mem_w_o = 1'b0;
      jump_en_o = 1'b0;
      mem_en_o = 1'b0;
    end else if (is_itype1) begin
      jump_en_o = 1'b0;
      mem_en_o = 1'b0;
    end else if (is_itype2) begin
      if (inst_i[6:0] == 7'b1100011) begin
        pc_target_o = (rf_rdata_a_i + $signed(imm_i)) & 32'hffff_fffe;
        jump_en_o = 1'b1;
        mem_en_o = 1'b0;
      end else begin
        mem_addr_o = rf_rdata_a_i + $signed(imm_i);
        mem_w_o = 1'b0;
        jump_en_o = 1'b0;
        mem_en_o = 1'b1;
      end
    end else if (is_stype) begin
      mem_addr_o = rf_rdata_a_i + $signed(imm_i);
      mem_w_o = 1'b1;
      jump_en_o = 1'b0;
      mem_en_o = 1'b1;
      if (inst_i[14:12] == 3'b000) mem_data_o = {24'b0, rf_rdata_b_i[7:0]};
      else mem_data_o = rf_rdata_b_i;
    end else if (is_btype) begin
      pc_target_o = pc_i + $signed(imm_i);
      if (inst_i[14:12] == 3'b000) jump_en_o = (rf_rdata_a_i == rf_rdata_b_i)? 1'b1 : 1'b0;
      else jump_en_o = (rf_rdata_a_i == rf_rdata_b_i)? 1'b0 : 1'b1;
      mem_en_o = 1'b0;
    end else if (is_jtype) begin
      pc_target_o = pc_i + $signed(imm_i);
      jump_en_o = 1'b1;
      mem_en_o = 1'b0;
    end else if (is_utype) begin
      jump_en_o = 1'b0;
      mem_en_o = 1'b0;
    end else begin
      jump_en_o = 1'b0;
      mem_en_o = 1'b0;
    end
  end

endmodule