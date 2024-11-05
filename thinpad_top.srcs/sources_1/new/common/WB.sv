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


module WB (
    input wire clk,
    input wire reset,

    input wire [31:0] pc_i,
    input wire [31:0] inst_i,
    input wire [31:0] imm_i,
    input wire [4:0] rf_waddr_i,
    input wire [31:0] mem_data_i,
    input wire [31:0] alu_y_i,
    
    output reg [4:0]  rf_waddr_o,
    output reg [31:0] rf_wdata_o,
    output reg rf_we_o
);

  logic is_rtype, is_itype1, is_itype2, is_stype, is_btype, is_jtype, is_utype;

  always_comb begin
    //pc_o = pc_i;

    is_rtype = (inst_i[6:0] == 7'b0110011);
    is_itype1 = (inst_i[6:0] == 7'b0010011);
    is_itype2 = (inst_i[6:0] == 7'b1100111) || (inst_i[6:0] == 7'b0000011);
    is_stype = (inst_i[6:0] == 7'b0100011);
    is_btype = (inst_i[6:0] == 7'b1100011);
    is_jtype = (inst_i[6:0] == 7'b1101111);
    is_utype = (inst_i[6:0] == 7'b0110111);
  end

  always_comb begin
    if (is_rtype) begin
      rf_wdata_o = alu_y_i;
      rf_waddr_o = rf_waddr_i;
      rf_we_o = 1'b1;
    end else if (is_itype1) begin
      rf_wdata_o = alu_y_i;
      rf_waddr_o = rf_waddr_i;
      rf_we_o = 1'b1;
    end else if (is_itype2) begin
      if (inst_i[6:0] == 7'b1100111) begin
        rf_wdata_o = pc_i + 4;
        rf_waddr_o = rf_waddr_i;
        rf_we_o = 1'b1;
      end else begin
        rf_we_o = 1'b1;
        rf_waddr_o = rf_waddr_i;
        if (inst_i[14:12] == 3'b000) rf_wdata_o = {{24{mem_data_i[7]}}, mem_data_i};
        else rf_wdata_o = mem_data_i;
      end
    end else if (is_jtype) begin
      rf_wdata_o = pc_i + 4;
      rf_waddr_o = rf_waddr_i;
      rf_we_o = 1'b1;
    end else if (is_utype) begin
      rf_waddr_o <= rf_waddr_i;
      rf_wdata_o <= imm_i;
      rf_we_o <= 1'b1;
    end else begin
      rf_we_o = 1'b0;
    end
  end

endmodule