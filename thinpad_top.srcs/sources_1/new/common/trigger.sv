`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/04 17:14:10
// Design Name: 
// Module Name: trigger
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


module trigger (  
    input wire clk,
    input wire reset,
    input wire push_btn,
    output reg step
);  

    reg last;

    always_ff @(posedge clk or posedge reset) begin  
      if (reset) begin
        last <= 0;  
        step <= 0;  
      end else begin
        if (push_btn && !last) begin  
          step <= 1;
        end else begin
          step <= 0;  
        end
        last <= push_btn;  
      end
    end

endmodule
