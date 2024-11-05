module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    input wire [31:0] dip_sw,

    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);

  typedef enum logic [3:0] {
      STATE_IDLE = 0,
      STATE_READ_WAIT_ACTION = 1,
      STATE_READ_WAIT_CHECK = 2,
      STATE_READ_DATA_ACTION = 3,
      STATE_READ_DATA_DONE = 4,
      STATE_WRITE_SRAM_ACTION = 5,
      STATE_WRITE_SRAM_DONE = 6,
      STATE_WRITE_WAIT_ACTION = 7,
      STATE_WRITE_WAIT_CHECK = 8,
      STATE_WRITE_DATA_ACTION = 9,
      STATE_WRITE_DATA_DONE = 10
  } state_t;

  state_t state;

  reg read_check_reg;
  reg write_check_reg;
  reg [31:0] data_reg;
  reg [4:0] count;

  always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      wb_cyc_o <= 1'b0;
      wb_stb_o <= 1'b0;
      wb_adr_o <= {ADDR_WIDTH{1'b0}};
      wb_dat_o <= {DATA_WIDTH{1'b0}};
      wb_we_o <= 1'b0;
      wb_sel_o <= {DATA_WIDTH/8{1'b1}};
      read_check_reg <= 1'b0;
      write_check_reg <= 1'b0;
      data_reg <= 32'b0;
      count <= 4'b0;
      state <= STATE_IDLE;
    end else begin
      case (state)
        STATE_IDLE: begin
          wb_cyc_o <= 1'b1;
          wb_stb_o <= 1'b1;
          wb_we_o <= 1'b0;
          wb_adr_o <= 32'h10000005;
          wb_sel_o <= 4'b0010;
          state <= STATE_READ_WAIT_ACTION;
        end
        STATE_READ_WAIT_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            read_check_reg <= wb_dat_i[8];
            state <= STATE_READ_WAIT_CHECK;
          end
        end
        STATE_READ_WAIT_CHECK: begin
          if (read_check_reg) begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            wb_we_o <= 1'b0;
            wb_adr_o <= 32'h10000000;
            wb_sel_o <= 4'b0001;
            state <= STATE_READ_DATA_ACTION;
          end else begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            wb_we_o <= 1'b0;
            wb_adr_o <= 32'h10000005;
            wb_sel_o <= 4'b0010;
            state <= STATE_READ_WAIT_ACTION;
          end
        end
        STATE_READ_DATA_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            data_reg[7:0] <= wb_dat_i[7:0];
            state <= STATE_READ_DATA_DONE;
          end
        end
        STATE_READ_DATA_DONE: begin
          wb_cyc_o <= 1'b1;
          wb_stb_o <= 1'b1;
          wb_we_o <= 1'b1;
          wb_adr_o <= dip_sw + (count << 2);
          wb_dat_o <= data_reg;
          wb_sel_o <= 4'b0001;
          state <= STATE_WRITE_SRAM_ACTION;
        end
        STATE_WRITE_SRAM_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            wb_we_o <= 1'b0;
            state <= STATE_WRITE_SRAM_DONE;
          end
        end
        STATE_WRITE_SRAM_DONE: begin
          wb_cyc_o <= 1'b1;
          wb_stb_o <= 1'b1;
          wb_we_o <= 1'b0;
          wb_adr_o <= 32'h10000005;
          wb_sel_o <= 4'b0010;
          state <= STATE_WRITE_WAIT_ACTION;
        end
        STATE_WRITE_WAIT_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            write_check_reg <= wb_dat_i[13];
            state <= STATE_WRITE_WAIT_CHECK;
          end
        end
        STATE_WRITE_WAIT_CHECK: begin
          if (write_check_reg) begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            wb_we_o <= 1'b1;
            wb_adr_o <= 32'h10000000;
            wb_dat_o <= data_reg;
            wb_sel_o <= 4'b0001;
            state <= STATE_WRITE_DATA_ACTION;
          end else begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            wb_we_o <= 1'b0;
            wb_adr_o <= 32'h10000005;
            wb_sel_o <= 4'b0010;
            state <= STATE_WRITE_WAIT_ACTION;
          end
        end
        STATE_WRITE_DATA_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            wb_we_o <= 1'b0;
            state <= STATE_WRITE_DATA_DONE;
          end
        end
        STATE_WRITE_DATA_DONE: begin
          count <= count + 1;
          state <= STATE_IDLE;
        end
      endcase
    end
  end
endmodule
