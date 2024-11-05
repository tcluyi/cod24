`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/27 00:14:42
// Design Name: 
// Module Name: wishbone_master
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


module mem_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,
    
    input wire [31:0] pc_i,
    input wire [31:0] inst_i,
    input wire [31:0] mem_addr_i,
    input wire [31:0] mem_data_i,
    input wire mem_w_i,
    input wire mem_en_i,
    output reg [31:0] pc_o,
    output reg [31:0] inst_o,

    input wire stall_i,
    output reg flush_o,
    output reg stall_o,
    
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);

  logic is_rtype, is_itype1, is_itype2, is_stype, is_btype, is_jtype, is_utype;

  always_comb begin
    is_rtype = (inst_i[6:0] == 7'b0110011);
    is_itype1 = (inst_i[6:0] == 7'b0010011);
    is_itype2 = (inst_i[6:0] == 7'b1100011) || (inst_i[6:0] == 7'b0000011);
    is_stype = (inst_i[6:0] == 7'b0100011);
    is_btype = (inst_i[6:0] == 7'b1100011);
    is_jtype = (inst_i[6:0] == 7'b1101111);
    is_utype = (inst_i[6:0] == 7'b0110111);
  end

  typedef enum logic  {
      STATE_IDLE = 0,
      STATE_WAIT = 1
  } state_t;

  state_t state;
  
  always_comb begin
    if (!stall_i) begin
      pc_o = pc_i;
      inst_o = inst_i;
    end
  end 

  always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      pc_o <= 32'h8000_0000;
      inst_o <= 32'b0;

      wb_cyc_o <= 1'b0;
      wb_stb_o <= 1'b0;
      wb_adr_o <= {ADDR_WIDTH{1'b0}};
      wb_dat_o <= {DATA_WIDTH{1'b0}};
      wb_we_o <= 1'b0;
      wb_sel_o <= {DATA_WIDTH/8{1'b1}};
      stall_o <= 1'b0;
      flush_o <= 1'b0;
      state <= STATE_IDLE;
    end else begin
      case (state)
        STATE_IDLE: begin
          if (mem_en_i && !stall_i) begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            wb_adr_o <= mem_addr_i;
            wb_dat_o <= mem_data_i;
            stall_o <= 1'b1;
            flush_o <= 1'b0;
            if (!mem_w_i) begin
              if (is_itype2 && inst_i[14:12] == 3'b000) wb_sel_o <= 4'b0011;
              else if (is_itype2 && inst_i[14:12] == 3'b010) wb_sel_o <= 4'b1111;
              wb_we_o <= 1'b0;
              state <= STATE_WAIT;
            end else begin
              if (is_stype && inst_i[14:12] == 3'b000) wb_sel_o <= 4'b0011;
              else if (is_stype && inst_i[14:12] == 3'b010) wb_sel_o <= 4'b1111;
              wb_we_o <= 1'b1;
              state <= STATE_WAIT;
            end
          end
        end
        STATE_WAIT: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            wb_we_o <= 1'b0;
            stall_o <= 1'b0;
            flush_o <= 1'b0;
            //pc_o <= pc_i;
            //inst_o <= inst_i;
            state <= STATE_IDLE;
          end
        end
      endcase
    end
  end
endmodule
