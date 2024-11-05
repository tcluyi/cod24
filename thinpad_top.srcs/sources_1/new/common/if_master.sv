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


module if_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,
    
    input wire [31:0] pc_target,
    input wire jump_en,
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
/*
  pc_mux u_pc_mux(
      .clk(clk_i),
      .reset(rst_i),
      .pc_current(pc_i),
      .pc_target(pc_target),
      .jump_en(jump_en),
      .pc_next(pc_o),
      .stall_i(stall_i)
  );*/

  typedef enum logic {
      STATE_IDLE = 0,
      STATE_READ_WAIT = 1
  } state_t;

  state_t state;
  
  logic [31:0] pc, pc_jump;
  logic is_jump;
  //logic init;
  initial begin
    pc = 32'h8000_0000;
    //init = 1'b1;
  end

  always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      pc <= 32'h8000_0000;
      //init <= 1'b1;
      inst_o <= 32'b0;
      pc_o <= 32'h8000_0000;
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
          if ((!stall_i)) begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            wb_adr_o <= (jump_en)? pc_target : pc;
            is_jump <= jump_en;
            pc_jump <= pc_target;
            wb_sel_o <= 4'b1111;
            wb_we_o <= 1'b0;
            stall_o <= 1'b1;
            flush_o <= 1'b0;
            //init <= 1'b0;
            state <= STATE_READ_WAIT;
          end
        end
        STATE_READ_WAIT: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            wb_we_o <= 1'b0;
            inst_o <= wb_dat_i;
            pc <= (is_jump)? pc_jump + 4 : pc + 4;
            pc_o <= pc;
            stall_o <= 1'b0;
            flush_o <= 1'b0;
            state <= STATE_IDLE;
          end
        end
      endcase
    end
  end
endmodule
