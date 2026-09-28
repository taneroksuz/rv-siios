package configure;
  timeunit 1ns; timeprecision 1ps;

  localparam HARDWARE = 1;

  localparam MUL_PERFORMANCE = 1;

  localparam BUFFER_DEPTH = 4;

  localparam TIM_WIDTH = 32;
  localparam TIM_DEPTH = 1024;

  localparam RAM_DEPTH = 1;

  localparam ROM_BASE = 32'h00000000;
  localparam ROM_MASK = 32'hFFFFFF00;

  localparam SPI_BASE = 32'h00100000;
  localparam SPI_MASK = 32'hFFF00000;

  localparam UART_TX_BASE = 32'h01000000;
  localparam UART_TX_MASK = 32'hFFFFFFF0;

  localparam UART_RX_BASE = 32'h01000010;
  localparam UART_RX_MASK = 32'hFFFFFFF0;

  localparam CLINT_BASE = 32'h02000000;
  localparam CLINT_MASK = 32'hFFFF0000;

  localparam TIM_BASE = 32'h10000000;
  localparam TIM_MASK = 32'hFFF00000;

  localparam RAM_BASE = 32'h80000000;
  localparam RAM_MASK = 32'hFFF00000;

  localparam SYS_FREQ = 100000000;  // 100MHz

  localparam CPU_FREQ = 25000000;  // 25MHz
  localparam PER_FREQ = 5000000;   // 5MHz
  localparam RTC_FREQ = 1000000;   // 1MHz
  localparam BAUDRATE = 115200;

  localparam CLK_DIVIDER_CPU = SYS_FREQ / CPU_FREQ;
  localparam CLK_DIVIDER_PER = SYS_FREQ / PER_FREQ;
  localparam CLK_DIVIDER_RTC = CPU_FREQ / RTC_FREQ;
  localparam CLK_DIVIDER_BIT = CPU_FREQ / BAUDRATE;

  localparam DDR2_REF_FREQ = 200000000;  // 200MHz
  localparam DDR2_MEM_FREQ = 125000000;  // 125MHz

  localparam DDR2_CLK_MULT   = 5;
  localparam DDR2_CLK_DIVIDE = 8;
  localparam DDR2_PHASE_STEP = 56;

endpackage
