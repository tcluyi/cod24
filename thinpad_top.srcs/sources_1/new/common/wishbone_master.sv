module wishbone_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    output reg [4:0]  rf_raddr_a,
    input wire [31:0] rf_rdata_a,
    output reg [4:0]  rf_raddr_b,
    input wire [31:0] rf_rdata_b,
    output reg [4:0]  rf_waddr,
    output reg [31:0] rf_wdata,
    output reg rf_we,
    
    output reg [31:0] alu_a,
    output reg [31:0] alu_b,
    output reg [ 3:0] alu_op,
    input wire [31:0] alu_y,

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

  typedef enum logic [2:0] {
      STATE_IF_IDLE = 0,
      STATE_IF_ACTION = 1,
      STATE_ID = 2,
      STATE_EXE = 3,
      STATE_MEM_IDLE = 4,
      STATE_MEM_ACTION = 5,
      STATE_WB = 6
  } state_t;

  state_t state;
 
  reg [31:0] pc, inst, pc_jump;
  initial begin
    pc = 32'h8000_0000;
  end
 
  reg is_rtype, is_itype1, is_itype2, is_stype, is_btype, is_jtype, is_utype;
  reg [31:0] imm_i, imm_s, imm_b, imm_j, imm_u, imm;
  reg [4:0] rs1, rs2, rd;
  reg [31:0] rd_data;
  reg mem_w;
  reg [31:0] mem_addr, mem_data;
  reg is_jump;
  
  always_comb begin
    is_rtype = (inst[6:0] == 7'b0110011);
    is_itype1 = (inst[6:0] == 7'b0010011);
    is_itype2 = (inst[6:0] == 7'b1100111) || (inst[6:0] == 7'b0000011);
    is_stype = (inst[6:0] == 7'b0100011);
    is_btype = (inst[6:0] == 7'b1100011);
    is_jtype = (inst[6:0] == 7'b1101111);
    is_utype = (inst[6:0] == 7'b0110111);

	imm_i = {{20{inst[31]}}, inst[31:20]}; 
    imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]}; 
	imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
	imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
	imm_u = {inst[31:12], {12{1'b0}}};

    rd = inst[11:7];
    rs1 = inst[19:15];
    rs2 = inst[24:20];
    imm = (is_itype1 || is_itype2)? imm_i : is_stype? imm_s : is_btype? imm_b : is_jtype? imm_j : is_utype? imm_u : 32'b0;
  end

  always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      wb_cyc_o <= 1'b0;
      wb_stb_o <= 1'b0;
      wb_adr_o <= {ADDR_WIDTH{1'b0}};
      wb_dat_o <= {DATA_WIDTH{1'b0}};
      wb_we_o <= 1'b0;
      wb_sel_o <= {DATA_WIDTH/8{1'b1}};

      pc <= 32'h8000_0000;
      inst <= 32'b0;
      pc_jump <= 32'h8000_0000;
      is_jump <= 1'b0;
      
      rf_raddr_a <= 32'b0;
      rf_raddr_b <= 32'b0;
      rf_waddr <= 32'b0;
      rf_wdata <= 32'b0;
      rf_we <= 1'b0;
      
      alu_a <= 31'b0;
      alu_b <= 31'b0;
      alu_op <= 3'b0;
      
      mem_w <= 1'b0;
      mem_data <= 32'b0;
      mem_addr <= 32'b0;
      
      rd_data <= 32'b0;

      state <= STATE_IF_IDLE;
    end else begin
      case (state)
        STATE_IF_IDLE: begin
          rf_we <= 1'b0;
          wb_cyc_o <= 1'b1;
          wb_stb_o <= 1'b1;
          wb_we_o <= 1'b0;
          wb_adr_o <= pc;
          wb_sel_o <= 4'b1111;
          state <= STATE_IF_ACTION;
        end
        STATE_IF_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            wb_we_o <= 1'b0;
            inst <= wb_dat_i;
            state <= STATE_ID;            
          end
        end
        STATE_ID: begin
          rf_raddr_a <= rs1;
          rf_raddr_b <= rs2;
          rf_we <= 1'b0;
          state <= STATE_EXE;
        end
        STATE_EXE: begin
          if (is_rtype) begin
            alu_a <= rf_rdata_a;
            alu_b <= rf_rdata_b;
            case (inst[14:12])
              3'b000: alu_op <= 4'b0001;
              3'b111: alu_op <= 4'b0011;
              3'b110: alu_op <= 4'b0100;
              3'b100: alu_op <= 4'b0101;
              default: alu_op <= 4'b0000;
            endcase
            is_jump <= 1'b0;
            state <= STATE_WB;
          end else if (is_itype1) begin
            alu_a <= rf_rdata_a;
            alu_b <= imm;
            case (inst[14:12])
              3'b000: alu_op <= 4'b0001;
              3'b111: alu_op <= 4'b0011;
              3'b110: alu_op <= 4'b0100;
              3'b001: alu_op <= 4'b0111;
              3'b101: alu_op <= 4'b1000;
              default: alu_op <= 4'b0000;
            endcase
            is_jump <= 1'b0;
            state <= STATE_WB;
          end else if (is_itype2) begin
            if (inst[6:0] == 7'b1100011) begin
              pc_jump <= (rf_rdata_a + $signed(imm)) & 32'hffff_fffe;
              is_jump <= 1'b1;
              state <= STATE_WB;
            end else begin
              mem_addr <= rf_rdata_a + $signed(imm);
              mem_w <= 1'b0;
              is_jump <= 1'b0;
              state <= STATE_MEM_IDLE;
            end
          end else if (is_stype) begin
            mem_addr <= rf_rdata_a + $signed(imm);
            mem_w <= 1'b1;
            is_jump <= 1'b0;
            state <= STATE_MEM_IDLE;
            if (inst[14:12] == 3'b000) mem_data <= {24'b0, rf_rdata_b[7:0]};
            else mem_data <= rf_rdata_b;
          end else if (is_btype) begin
            pc_jump <= pc + $signed(imm);
            if (inst[14:12] == 3'b000) is_jump <= (rf_rdata_a == rf_rdata_b)? 1'b1 : 1'b0;
            else is_jump <= (rf_rdata_a == rf_rdata_b)? 1'b0 : 1'b1;
            state <= STATE_WB;
          end else if (is_jtype) begin
            pc_jump <= pc + $signed(imm);
            is_jump <= 1'b1;
            state <= STATE_WB;
          end else if (is_utype) begin
            is_jump <= 1'b0;
            state <= STATE_WB;
          end else begin
            is_jump <= 1'b0;
            state <= STATE_WB;
          end
        end
        STATE_MEM_IDLE: begin
          wb_cyc_o <= 1'b1;
          wb_stb_o <= 1'b1;
          wb_adr_o <= mem_addr;
          wb_dat_o <= mem_data;
          if (!mem_w) begin
            if (is_itype2 && inst[14:12] == 3'b000) wb_sel_o <= 4'b0011;
            else if (is_itype2 && inst[14:12] == 3'b010) wb_sel_o <= 4'b1111;
            wb_we_o <= 1'b0;
          end else begin
            if (is_stype && inst[14:12] == 3'b000) wb_sel_o <= 4'b0011;
            else if (is_stype && inst[14:12] == 3'b010) wb_sel_o <= 4'b1111;
            wb_we_o <= 1'b1;
          end
          state <= STATE_MEM_ACTION;
        end
        STATE_MEM_ACTION: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            wb_we_o <= 1'b0;
            if (!mem_w) rd_data <= wb_dat_i;
            state <= STATE_WB;          
          end
        end
        STATE_WB: begin
           if (is_rtype) begin
            rf_wdata <= alu_y;
            rf_waddr <= rd;
            rf_we <= 1'b1;
          end else if (is_itype1) begin
            rf_wdata <= alu_y;
            rf_waddr <= rd;
           rf_we <= 1'b1;
          end else if (is_itype2) begin
            if (inst[6:0] == 7'b1100111) begin
              rf_wdata <= pc + 4;
              rf_waddr <= rd;
              rf_we <= 1'b1;
            end else begin
              rf_we <= 1'b1;
              rf_waddr <= rd;
              if (inst[14:12] == 3'b000) rf_wdata <= {{24{rd_data[7]}}, rd_data};
              else rf_wdata <= rd_data;
            end
          end else if (is_jtype) begin
            rf_wdata <= pc + 4;
            rf_waddr <= rd;
            rf_we <= 1'b1;
          end else if (is_utype) begin
            rf_waddr <= rd;
            rf_wdata <= imm;
            rf_we <= 1'b1;
          end else begin
            rf_we <= 1'b0;
          end
          pc <= (is_jump)? pc_jump : pc + 4;
          state <= STATE_IF_IDLE;
        end
      endcase
    end
  end
endmodule
