`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/04 11:45:39
// Design Name: 
// Module Name: regfile
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


module regfile(
    input wire clk,
    input wire reset,
    input wire [4:0]  rf_raddr_a,
    output reg [15:0] rf_rdata_a,
    input wire [4:0]  rf_raddr_b,
    output reg [15:0] rf_rdata_b,
    input wire [4:0]  rf_waddr,
    input wire [15:0] rf_wdata,
    input wire rf_we
    );
    
    logic [15:0] registers [31:0];
    int i;
   
    always_ff @(posedge clk or posedge reset) begin  
      if (reset) begin  
        for (i = 0; i < 32; i++) registers[i] <= 16'b0;  
      end else if (rf_we && rf_waddr) begin  
        registers[rf_waddr] <= rf_wdata;
      end  
    end  
  
    assign rf_rdata_a = registers[rf_raddr_a];  
    assign rf_rdata_b = registers[rf_raddr_b];
  
endmodule
