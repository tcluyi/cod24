`default_nettype none

module thinpad_top (
    input wire clk_50M,     // 50MHz ʱ������
    input wire clk_11M0592, // 11.0592MHz ʱ�����루���ã��ɲ��ã�

    input wire push_btn,  // BTN5 ��ť���أ���������·������ʱΪ 1
    input wire reset_btn, // BTN6 ��λ��ť����������·������ʱΪ 1

    input  wire [ 3:0] touch_btn,  // BTN1~BTN4����ť���أ�����ʱΪ 1
    input  wire [31:0] dip_sw,     // 32 λ���뿪�أ�����"ON"ʱΪ 1
    output wire [15:0] leds,       // 16 λ LED�����ʱ 1 ����
    output wire [ 7:0] dpy0,       // ����ܵ�λ�źţ�����С���㣬��� 1 ����
    output wire [ 7:0] dpy1,       // ����ܸ�λ�źţ�����С���㣬��� 1 ����

    // CPLD ���ڿ������ź�
    output wire uart_rdn,        // �������źţ�����Ч
    output wire uart_wrn,        // д�����źţ�����Ч
    input  wire uart_dataready,  // ��������׼����
    input  wire uart_tbre,       // �������ݱ�־
    input  wire uart_tsre,       // ���ݷ�����ϱ�־

    // BaseRAM �ź�
    inout wire [31:0] base_ram_data,  // BaseRAM ���ݣ��� 8 λ�� CPLD ���ڿ���������
    output wire [19:0] base_ram_addr,  // BaseRAM ��ַ
    output wire [3:0] base_ram_be_n,  // BaseRAM �ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ 0
    output wire base_ram_ce_n,  // BaseRAM Ƭѡ������Ч
    output wire base_ram_oe_n,  // BaseRAM ��ʹ�ܣ�����Ч
    output wire base_ram_we_n,  // BaseRAM дʹ�ܣ�����Ч

    // ExtRAM �ź�
    inout wire [31:0] ext_ram_data,  // ExtRAM ����
    output wire [19:0] ext_ram_addr,  // ExtRAM ��ַ
    output wire [3:0] ext_ram_be_n,  // ExtRAM �ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ 0
    output wire ext_ram_ce_n,  // ExtRAM Ƭѡ������Ч
    output wire ext_ram_oe_n,  // ExtRAM ��ʹ�ܣ�����Ч
    output wire ext_ram_we_n,  // ExtRAM дʹ�ܣ�����Ч

    // ֱ�������ź�
    output wire txd,  // ֱ�����ڷ��Ͷ�
    input  wire rxd,  // ֱ�����ڽ��ն�

    // Flash �洢���źţ��ο� JS28F640 оƬ�ֲ�
    output wire [22:0] flash_a,  // Flash ��ַ��a0 ���� 8bit ģʽ��Ч��16bit ģʽ������
    inout wire [15:0] flash_d,  // Flash ����
    output wire flash_rp_n,  // Flash ��λ�źţ�����Ч
    output wire flash_vpen,  // Flash д�����źţ��͵�ƽʱ���ܲ�������д
    output wire flash_ce_n,  // Flash Ƭѡ�źţ�����Ч
    output wire flash_oe_n,  // Flash ��ʹ���źţ�����Ч
    output wire flash_we_n,  // Flash дʹ���źţ�����Ч
    output wire flash_byte_n, // Flash 8bit ģʽѡ�񣬵���Ч����ʹ�� flash �� 16 λģʽʱ����Ϊ 1

    // USB �������źţ��ο� SL811 оƬ�ֲ�
    output wire sl811_a0,
    // inout  wire [7:0] sl811_d,     // USB ������������������� dm9k_sd[7:0] ����
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    // ����������źţ��ο� DM9000A оƬ�ֲ�
    output wire dm9k_cmd,
    inout wire [15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input wire dm9k_int,

    // ͼ������ź�
    output wire [2:0] video_red,    // ��ɫ���أ�3 λ
    output wire [2:0] video_green,  // ��ɫ���أ�3 λ
    output wire [1:0] video_blue,   // ��ɫ���أ�2 λ
    output wire       video_hsync,  // ��ͬ����ˮƽͬ�����ź�
    output wire       video_vsync,  // ��ͬ������ֱͬ�����ź�
    output wire       video_clk,    // ����ʱ�����
    output wire       video_de,      // ��������Ч�źţ���������������
    
    output wire [31:0] inst,
    output wire [31:0] pc,
    output wire [31:0] pc2,
    output wire pipestall,
    output wire [1:0] stall_i,
    output wire jump,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [4:0] rd_exe,
    output wire [4:0] rd_mem,
    output wire [4:0] rd_wb,
    output wire [4:0] rd,
    output wire [31:0] rd_data,
    output wire [31:0] imm,
    output wire [31:0] pc_t
);

  /* =========== Demo code begin =========== */

  // PLL ��Ƶʾ��
  logic locked, clk_10M, clk_20M;
  pll_example clock_gen (
      // Clock in ports
      .clk_in1(clk_50M),  // �ⲿʱ������
      // Clock out ports
      .clk_out1(clk_10M),  // ʱ����� 1��Ƶ���� IP ���ý���������
      .clk_out2(clk_20M),  // ʱ����� 2��Ƶ���� IP ���ý���������
      // Status and control signals
      .reset(reset_btn),  // PLL ��λ����
      .locked(locked)  // PLL ����ָʾ�����"1"��ʾʱ���ȶ���
                       // �󼶵�·��λ�ź�Ӧ���������ɣ����£�
  );

  logic reset_of_clk10M;
  // �첽��λ��ͬ���ͷţ��� locked �ź�תΪ�󼶵�·�ĸ�λ reset_of_clk10M
  always_ff @(posedge clk_10M or negedge locked) begin
    if (~locked) reset_of_clk10M <= 1'b1;
    else reset_of_clk10M <= 1'b0;
  end

  /*always_ff @(posedge clk_10M or posedge reset_of_clk10M) begin
    if (reset_of_clk10M) begin
      // Your Code
    end else begin
      // Your Code
    end
  end

  // ��ʹ���ڴ桢����ʱ��������ʹ���ź�
  assign base_ram_ce_n = 1'b1;
  assign base_ram_oe_n = 1'b1;
  assign base_ram_we_n = 1'b1;

  assign ext_ram_ce_n = 1'b1;
  assign ext_ram_oe_n = 1'b1;
  assign ext_ram_we_n = 1'b1;

  assign uart_rdn = 1'b1;
  assign uart_wrn = 1'b1;

  // ��������ӹ�ϵʾ��ͼ��dpy1 ͬ��
  // p=dpy0[0] // ---a---
  // c=dpy0[1] // |     |
  // d=dpy0[2] // f     b
  // e=dpy0[3] // |     |
  // b=dpy0[4] // ---g---
  // a=dpy0[5] // |     |
  // f=dpy0[6] // e     c
  // g=dpy0[7] // |     |
  //           // ---d---  p

  // 7 ���������������ʾ���� number �� 16 ������ʾ�����������
  logic [7:0] number;
  SEG7_LUT segL (
      .oSEG1(dpy0),
      .iDIG (number[3:0])
  );  // dpy0 �ǵ�λ�����
  SEG7_LUT segH (
      .oSEG1(dpy1),
      .iDIG (number[7:4])
  );  // dpy1 �Ǹ�λ�����

  logic [15:0] led_bits;
  assign leds = led_bits;

  always_ff @(posedge push_btn or posedge reset_btn) begin
    if (reset_btn) begin  // ��λ���£����� LED Ϊ��ʼֵ
      led_bits <= 16'h1;
    end else begin  // ÿ�ΰ��°�ť���أ�LED ѭ������
      led_bits <= {led_bits[14:0], led_bits[15]};
    end
  end
  
  // ֱ�����ڽ��շ�����ʾ����ֱ�������յ��������ٷ��ͳ�ȥ
  logic [7:0] ext_uart_rx;
  logic [7:0] ext_uart_buffer, ext_uart_tx;
  logic ext_uart_ready, ext_uart_clear, ext_uart_busy;
  logic ext_uart_start, ext_uart_avai;

  assign number = ext_uart_buffer;

  // ����ģ�飬9600 �޼���λ
  async_receiver #(
      .ClkFrequency(50000000),
      .Baud(9600)
  ) ext_uart_r (
      .clk           (clk_50M),         // �ⲿʱ���ź�
      .RxD           (rxd),             // �ⲿ�����ź�����
      .RxD_data_ready(ext_uart_ready),  // ���ݽ��յ���־
      .RxD_clear     (ext_uart_clear),  // ������ձ�־
      .RxD_data      (ext_uart_rx)      // ���յ���һ�ֽ�����
  );

  assign ext_uart_clear = ext_uart_ready; // �յ����ݵ�ͬʱ�������־����Ϊ������ȡ�� ext_uart_buffer ��
  always_ff @(posedge clk_50M) begin  // ���յ������� ext_uart_buffer
    if (ext_uart_ready) begin
      ext_uart_buffer <= ext_uart_rx;
      ext_uart_avai   <= 1;
    end else if (!ext_uart_busy && ext_uart_avai) begin
      ext_uart_avai <= 0;
    end
  end
  always_ff @(posedge clk_50M) begin  // �������� ext_uart_buffer ���ͳ�ȥ
    if (!ext_uart_busy && ext_uart_avai) begin
      ext_uart_tx <= ext_uart_buffer;
      ext_uart_start <= 1;
    end else begin
      ext_uart_start <= 0;
    end
  end

  // ����ģ�飬9600 �޼���λ
  async_transmitter #(
      .ClkFrequency(50000000),
      .Baud(9600)
  ) ext_uart_t (
      .clk      (clk_50M),         // �ⲿʱ���ź�
      .TxD      (txd),             // �����ź����
      .TxD_busy (ext_uart_busy),   // ������æ״ָ̬ʾ
      .TxD_start(ext_uart_start),  // ��ʼ�����ź�
      .TxD_data (ext_uart_tx)      // �����͵�����
  );

  // ͼ�������ʾ���ֱ��� 800x600@72Hz������ʱ��Ϊ 50MHz
  logic [11:0] hdata;
  assign video_red   = hdata < 266 ? 3'b111 : 0;  // ��ɫ����
  assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0;  // ��ɫ����
  assign video_blue  = hdata >= 532 ? 2'b11 : 0;  // ��ɫ����
  assign video_clk   = clk_50M;
  vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at72 (
      .clk        (clk_50M),
      .hdata      (hdata),        // ������
      .vdata      (),             // ������
      .hsync      (video_hsync),
      .vsync      (video_vsync),
      .data_enable(video_de)
  );*/
  /* =========== Demo code end =========== */

  logic sys_clk;
  logic sys_rst;

  assign sys_clk = clk_10M;
  assign sys_rst = reset_of_clk10M;
  
  // ��ʵ�鲻ʹ�� CPLD ���ڣ����÷�ֹ���߳�ͻ
  assign uart_rdn = 1'b1;
  assign uart_wrn = 1'b1;

  logic [1:0] stall_time;
  logic jump_en;
  logic pipeline_stall;
  
  logic stall_if_i, bubble_if_i, flush_if_o, stall_if_o;
  logic stall_id_i, bubble_id_i, flush_id_o, stall_id_o;
  logic stall_exe_i, bubble_exe_i, flush_exe_o, stall_exe_o;
  logic stall_mem_i, bubble_mem_i, flush_mem_o, stall_mem_o;

  // =========== IF_Master begin =========== 
  logic        wbm0_cyc_o, wbm1_cyc_o;
  logic        wbm0_stb_o, wbm1_stb_o;
  logic        wbm0_ack_i, wbm1_ack_i;
  logic [31:0] wbm0_adr_o, wbm1_adr_o;
  logic [31:0] wbm0_dat_o, wbm1_dat_o;
  logic [31:0] wbm0_dat_i, wbm1_dat_i;
  logic [ 3:0] wbm0_sel_o, wbm1_sel_o;
  logic        wbm0_we_o, wbm1_we_o;

  logic [31:0] pc_if_i, pc_if_o, pc_target;
  logic [31:0] inst_if_o;

  if_master #(
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32)
  ) u_if_master (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      .pc_i(pc_if_i),
      .pc_target(pc_target),
      .jump_en(jump_en),
      .pc_o(pc_if_o),
      .inst_o(inst_if_o),

      .stall_i(stall_if_i),
      
      // wishbone master
      .wb_cyc_o(wbm0_cyc_o),
      .wb_stb_o(wbm0_stb_o),
      .wb_ack_i(wbm0_ack_i),
      .wb_adr_o(wbm0_adr_o),
      .wb_dat_o(wbm0_dat_o),
      .wb_dat_i(wbm0_dat_i),
      .wb_sel_o(wbm0_sel_o),
      .wb_we_o (wbm0_we_o)
  );
  // =========== IF_Master end =========== 

  logic [31:0] pc_id_i;
  logic [31:0] inst_id_i;

  IF_ID u_if_id(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_if_o),
      .inst_i(inst_if_o),

      .pc_o(pc_id_i),
      .inst_o(inst_id_i),

      .stall_i(stall_if_i),
      .bubble_i(bubble_if_i),
      .flush_o(flush_if_o),
      .stall_o(stall_if_o)
  );

  // =========== ID begin =========== 
  logic [31:0] pc_id_o;
  logic [31:0] inst_id_o;
  logic [31:0] imm_id_o;
  logic [4:0] rf_waddr_id_i, rf_waddr_id_o;
  logic rf_we_id_i;
  logic [31:0] rf_wdata_id_i, rf_rdata_a_id_o, rf_rdata_b_id_o;

  logic [4:0] rf_waddr_exe_i, rf_waddr_mem_i, rf_waddr_wb_i;

  ID u_id(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_id_i),
      .inst_i(inst_id_i),
      .rf_waddr_i(rf_waddr_id_i),
      .rf_wdata_i(rf_wdata_id_i),
      .rf_we_i(rf_we_id_i),

      .rf_waddr_exe_i(rf_waddr_exe_i),
      .rf_waddr_mem_i(rf_waddr_mem_i),
      .rf_waddr_wb_i(rf_waddr_wb_i),

      .pc_o(pc_id_o),
      .inst_o(inst_id_o),
      .imm_o(imm_id_o),
      .rf_rdata_a_o(rf_rdata_a_id_o),
      .rf_rdata_b_o(rf_rdata_b_id_o),
      .rf_waddr_o(rf_waddr_id_o),

      .stall_time(stall_time)
  );
  // =========== ID end =========== 

  logic [31:0] pc_exe_i;
  logic [31:0] inst_exe_i;
  logic [31:0] imm_exe_i;
  //logic [4:0] rf_waddr_exe_i;
  logic [31:0] rf_rdata_a_exe_i, rf_rdata_b_exe_i;

  ID_EXE u_id_EXE(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_id_o),
      .inst_i(inst_id_o),
      .imm_i(imm_id_o),
      .rf_rdata_a_i(rf_rdata_a_id_o),
      .rf_rdata_b_i(rf_rdata_b_id_o),
      .rf_waddr_i(rf_waddr_id_o),
      .stall_time(stall_time),

      .pc_o(pc_exe_i),
      .inst_o(inst_exe_i),
      .imm_o(imm_exe_i),
      .rf_rdata_a_o(rf_rdata_a_exe_i),
      .rf_rdata_b_o(rf_rdata_b_exe_i),
      .rf_waddr_o(rf_waddr_exe_i),

      .stall_i(stall_id_i),
      .bubble_i(bubble_id_i),
      .flush_o(flush_id_o),
      .stall_o(stall_id_o)
  );

  // =========== EXE begin =========== 
  logic [31:0] pc_exe_o;
  logic [31:0] inst_exe_o;
  logic [4:0] rf_waddr_exe_o;
  logic [31:0] rf_wdata_exe_o;

  logic [31:0] mem_addr_exe_o, mem_data_exe_o;
  logic mem_w_exe_o, mem_en_exe_o;
  
  EXE u_exe(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_exe_i),
      .inst_i(inst_exe_i),
      .imm_i(imm_exe_i),
      .rf_rdata_a_i(rf_rdata_a_exe_i),
      .rf_rdata_b_i(rf_rdata_b_exe_i),
      .rf_waddr_i(rf_waddr_exe_i),

      .pc_o(pc_exe_o),
      .inst_o(inst_exe_o),
      .rf_waddr_o(rf_waddr_exe_o),
      .rf_wdata_o(rf_wdata_exe_o),
      .pc_target_o(pc_target),
      .jump_en_o(jump_en),
      .mem_addr_o(mem_addr_exe_o),
      .mem_data_o(mem_data_exe_o),
      .mem_w_o(mem_w_exe_o),
      .mem_en_o(mem_en_exe_o)
  );
  // =========== EXE end =========== 

  logic [31:0] pc_mem_i;
  logic [31:0] inst_mem_i;
  //logic [4:0] rf_waddr_mem_i;
  logic [31:0] rf_wdata_mem_i;

  logic [31:0] mem_addr_mem_i, mem_data_mem_i;
  logic mem_w_mem_i, mem_en_mem_i;

  EXE_MEM u_exe_mem(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_exe_o),
      .inst_i(inst_exe_o),
      .rf_waddr_i(rf_waddr_exe_o),
      .rf_wdata_i(rf_wdata_exe_o),
      .mem_addr_i(mem_addr_exe_o),
      .mem_data_i(mem_data_exe_o),
      .mem_w_i(mem_w_exe_o),
      .mem_en_i(mem_en_exe_o),
      .jump_en_i(jump_en),

      .pc_o(pc_mem_i),
      .inst_o(inst_mem_i),
      .rf_waddr_o(rf_waddr_mem_i),
      .rf_wdata_o(rf_wdata_mem_i),
      .mem_addr_o(mem_addr_mem_i),
      .mem_data_o(mem_data_mem_i),
      .mem_w_o(mem_w_mem_i),
      .mem_en_o(mem_en_mem_i),

      .stall_i(stall_exe_i),
      .bubble_i(bubble_exe_i),
      .flush_o(flush_exe_o),
      .stall_o(stall_exe_o)
  );

  // =========== MEM_Master begin =========== 
  logic [31:0] pc_mem_o, inst_mem_o;

  mem_master #(
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32)
  ) u_mem_master (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      .pc_i(pc_mem_i),
      .inst_i(inst_mem_i),
      .mem_addr_i(mem_addr_mem_i),
      .mem_data_i(mem_data_mem_i),
      .mem_w_i(mem_w_mem_i),
      .mem_en_i(mem_en_mem_i),
      .pc_o(pc_mem_o),
      .inst_o(inst_mem_o),

      .stall_i(stall_mem_i),

      // wishbone master
      .wb_cyc_o(wbm1_cyc_o),
      .wb_stb_o(wbm1_stb_o),
      .wb_ack_i(wbm1_ack_i),
      .wb_adr_o(wbm1_adr_o),
      .wb_dat_o(wbm1_dat_o),
      .wb_dat_i(wbm1_dat_i),
      .wb_sel_o(wbm1_sel_o),
      .wb_we_o (wbm1_we_o)
  );
  // =========== MEM_Master end =========== 
  
  logic [31:0] pc_wb_i;
  logic [31:0] inst_wb_i;
  //logic [4:0] rf_waddr_wb_i;
  logic [31:0] rf_wdata_wb_i;
  logic [31:0] mem_data_wb_i;

  MEM_WB u_mem_wb(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_mem_o),
      .inst_i(inst_mem_o),
      .rf_waddr_i(rf_waddr_mem_i),
      .rf_wdata_i(rf_wdata_mem_i),
      .mem_data_i(wbm1_dat_o),

      .pc_o(pc_wb_i),
      .inst_o(inst_wb_i),
      .rf_waddr_o(rf_waddr_wb_i),
      .rf_wdata_o(rf_wdata_wb_i),
      .mem_data_o(mem_data_wb_i),

      .stall_i(stall_mem_i),
      .bubble_i(bubble_mem_i),
      .flush_o(flush_mem_o),
      .stall_o(stall_mem_o)
  );

  // =========== WB begin =========== 
  WB u_wb(
      .clk(sys_clk),
      .reset(sys_rst),

      .pc_i(pc_wb_i),
      .inst_i(inst_wb_i),
      .rf_waddr_i(rf_waddr_wb_i),
      .rf_wdata_i(rf_wdata_wb_i),
      .mem_data_i(mem_data_wb_i),

      //.pc_o(pc_if_i),
      .rf_waddr_o(rf_waddr_id_i),
      .rf_wdata_o(rf_wdata_id_i),
      .rf_we_o(rf_we_id_i)
  );
  // =========== WB end =========== 

  always_comb begin
    pc_if_i = pc_id_i;
    pipeline_stall = wbm0_stb_o || wbm1_stb_o;
    bubble_if_i = stall_if_o || flush_id_o || flush_exe_o || flush_mem_o;
    stall_if_i = ((stall_id_o || stall_exe_o || stall_mem_o) && (!bubble_if_i)) || pipeline_stall;
    bubble_id_i = stall_id_o || flush_exe_o || flush_mem_o;
    stall_id_i = ((stall_exe_o || stall_mem_o) && (!bubble_id_i)) || pipeline_stall;
    bubble_exe_i = stall_exe_o || flush_mem_o;
    stall_exe_i = ((stall_mem_o) && (!bubble_exe_i)) || pipeline_stall;
    bubble_mem_i = stall_mem_o;
    stall_mem_i = pipeline_stall;
  end
  
  assign inst = inst_id_i;
  assign pc = pc_if_o;
  assign pc2 = pc_id_i;
  assign pipestall = pipeline_stall;
  assign stall_i = stall_time;
  assign jump = jump_en;
  assign rs1_data = rf_rdata_a_id_o;
  assign rs2_data = rf_rdata_b_id_o;
  assign rd_exe = rf_waddr_exe_i;
  assign rd_mem = rf_waddr_mem_i;
  assign rd_wb = rf_waddr_wb_i;
  assign rd = rf_waddr_id_i;
  assign rd_data = rf_wdata_id_i;
  assign imm = imm_id_o;
  assign pc_t = pc_target;

  /* =========== Arbiter begin =========== */
  //Arbiter => Wishbone MUX (Slave)
  logic        wbm_cyc_o;
  logic        wbm_stb_o;
  logic        wbm_ack_i;
  logic [31:0] wbm_adr_o;
  logic [31:0] wbm_dat_o;
  logic [31:0] wbm_dat_i;
  logic [ 3:0] wbm_sel_o;
  logic        wbm_we_o; 

  wb_arbiter_2 #(
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32),
      .SELECT_WIDTH(4),
      .ARB_TYPE_ROUND_ROBIN(0),
      .ARB_LSB_HIGH_PRIORITY(1)
  ) u_wb_arbiter_2 (
      .clk(sys_clk),
      .rst(sys_rst),
      .wbm0_adr_i(wbm0_adr_o),
      .wbm0_dat_i(wbm0_dat_o),
      .wbm0_dat_o(wbm0_dat_i),
      .wbm0_sel_i(wbm0_sel_o),
      .wbm0_we_i(wbm0_we_o),
      .wbm0_cyc_i(wbm0_cyc_o),
      .wbm0_stb_i(wbm0_stb_o),
      .wbm0_ack_o(wbm0_ack_i),
      
      .wbm1_adr_i(wbm1_adr_o),
      .wbm1_dat_i(wbm1_dat_o),
      .wbm1_dat_o(wbm1_dat_i),
      .wbm1_sel_i(wbm1_sel_o),
      .wbm1_we_i(wbm1_we_o),
      .wbm1_cyc_i(wbm1_cyc_o),
      .wbm1_stb_i(wbm1_stb_o),
      .wbm1_ack_o(wbm1_ack_i),
      
      .wbs_adr_o(wbm_adr_o),
      .wbs_dat_o(wbm_dat_o),
      .wbs_dat_i(wbm_dat_i),
      .wbs_sel_o(wbm_sel_o),
      .wbs_we_o(wbm_we_o),
      .wbs_cyc_o(wbm_cyc_o),
      .wbs_stb_o(wbm_stb_o),
      .wbs_ack_i(wbm_ack_i)
  );

  /* =========== Arbiter end =========== */
  
  /* =========== MUX begin =========== */
  // Wishbone MUX (Masters) => bus slaves
  logic wbs0_cyc_o;
  logic wbs0_stb_o;
  logic wbs0_ack_i;
  logic [31:0] wbs0_adr_o;
  logic [31:0] wbs0_dat_o;
  logic [31:0] wbs0_dat_i;
  logic [3:0] wbs0_sel_o;
  logic wbs0_we_o;

  logic wbs1_cyc_o;
  logic wbs1_stb_o;
  logic wbs1_ack_i;
  logic [31:0] wbs1_adr_o;
  logic [31:0] wbs1_dat_o;
  logic [31:0] wbs1_dat_i;
  logic [3:0] wbs1_sel_o;
  logic wbs1_we_o;

  logic wbs2_cyc_o;
  logic wbs2_stb_o;
  logic wbs2_ack_i;
  logic [31:0] wbs2_adr_o;
  logic [31:0] wbs2_dat_o;
  logic [31:0] wbs2_dat_i;
  logic [3:0] wbs2_sel_o;
  logic wbs2_we_o;

  wb_mux_3 wb_mux (
      .clk(sys_clk),
      .rst(sys_rst),

      // Master interface (to Lab5 master)
      .wbm_adr_i(wbm_adr_o),
      .wbm_dat_i(wbm_dat_o),
      .wbm_dat_o(wbm_dat_i),
      .wbm_we_i (wbm_we_o),
      .wbm_sel_i(wbm_sel_o),
      .wbm_stb_i(wbm_stb_o),
      .wbm_ack_o(wbm_ack_i),
      .wbm_err_o(),
      .wbm_rty_o(),
      .wbm_cyc_i(wbm_cyc_o),

      // Slave interface 0 (to BaseRAM controller)
      // Address range: 0x8000_0000 ~ 0x803F_FFFF
      .wbs0_addr    (32'h8000_0000),
      .wbs0_addr_msk(32'hFFC0_0000),

      .wbs0_adr_o(wbs0_adr_o),
      .wbs0_dat_i(wbs0_dat_i),
      .wbs0_dat_o(wbs0_dat_o),
      .wbs0_we_o (wbs0_we_o),
      .wbs0_sel_o(wbs0_sel_o),
      .wbs0_stb_o(wbs0_stb_o),
      .wbs0_ack_i(wbs0_ack_i),
      .wbs0_err_i('0),
      .wbs0_rty_i('0),
      .wbs0_cyc_o(wbs0_cyc_o),

      // Slave interface 1 (to ExtRAM controller)
      // Address range: 0x8040_0000 ~ 0x807F_FFFF
      .wbs1_addr    (32'h8040_0000),
      .wbs1_addr_msk(32'hFFC0_0000),

      .wbs1_adr_o(wbs1_adr_o),
      .wbs1_dat_i(wbs1_dat_i),
      .wbs1_dat_o(wbs1_dat_o),
      .wbs1_we_o (wbs1_we_o),
      .wbs1_sel_o(wbs1_sel_o),
      .wbs1_stb_o(wbs1_stb_o),
      .wbs1_ack_i(wbs1_ack_i),
      .wbs1_err_i('0),
      .wbs1_rty_i('0),
      .wbs1_cyc_o(wbs1_cyc_o),

      // Slave interface 2 (to UART controller)
      // Address range: 0x1000_0000 ~ 0x1000_FFFF
      .wbs2_addr    (32'h1000_0000),
      .wbs2_addr_msk(32'hFFFF_0000),

      .wbs2_adr_o(wbs2_adr_o),
      .wbs2_dat_i(wbs2_dat_i),
      .wbs2_dat_o(wbs2_dat_o),
      .wbs2_we_o (wbs2_we_o),
      .wbs2_sel_o(wbs2_sel_o),
      .wbs2_stb_o(wbs2_stb_o),
      .wbs2_ack_i(wbs2_ack_i),
      .wbs2_err_i('0),
      .wbs2_rty_i('0),
      .wbs2_cyc_o(wbs2_cyc_o)
  );

  /* =========== MUX end =========== */

  /* =========== Slaves begin =========== */
  sram_controller #(
      .SRAM_ADDR_WIDTH(20),
      .SRAM_DATA_WIDTH(32)
  ) sram_controller_base (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs0_cyc_o),
      .wb_stb_i(wbs0_stb_o),
      .wb_ack_o(wbs0_ack_i),
      .wb_adr_i(wbs0_adr_o),
      .wb_dat_i(wbs0_dat_o),
      .wb_dat_o(wbs0_dat_i),
      .wb_sel_i(wbs0_sel_o),
      .wb_we_i (wbs0_we_o),

      // To SRAM chip
      .sram_addr(base_ram_addr),
      .sram_data(base_ram_data),
      .sram_ce_n(base_ram_ce_n),
      .sram_oe_n(base_ram_oe_n),
      .sram_we_n(base_ram_we_n),
      .sram_be_n(base_ram_be_n)
  );

  sram_controller #(
      .SRAM_ADDR_WIDTH(20),
      .SRAM_DATA_WIDTH(32)
  ) sram_controller_ext (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs1_cyc_o),
      .wb_stb_i(wbs1_stb_o),
      .wb_ack_o(wbs1_ack_i),
      .wb_adr_i(wbs1_adr_o),
      .wb_dat_i(wbs1_dat_o),
      .wb_dat_o(wbs1_dat_i),
      .wb_sel_i(wbs1_sel_o),
      .wb_we_i (wbs1_we_o),

      // To SRAM chip
      .sram_addr(ext_ram_addr),
      .sram_data(ext_ram_data),
      .sram_ce_n(ext_ram_ce_n),
      .sram_oe_n(ext_ram_oe_n),
      .sram_we_n(ext_ram_we_n),
      .sram_be_n(ext_ram_be_n)
  );

  // ���ڿ�����ģ��
  // NOTE: ����޸�ϵͳʱ��Ƶ�ʣ�Ҳ��Ҫ�޸Ĵ˴���ʱ��Ƶ�ʲ���
  uart_controller #(
      .CLK_FREQ(10_000_000),
      .BAUD    (115200)
  ) uart_controller (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      .wb_cyc_i(wbs2_cyc_o),
      .wb_stb_i(wbs2_stb_o),
      .wb_ack_o(wbs2_ack_i),
      .wb_adr_i(wbs2_adr_o),
      .wb_dat_i(wbs2_dat_o),
      .wb_dat_o(wbs2_dat_i),
      .wb_sel_i(wbs2_sel_o),
      .wb_we_i (wbs2_we_o),

      // to UART pins
      .uart_txd_o(txd),
      .uart_rxd_i(rxd)
  );

  /* =========== Slaves end =========== */

endmodule