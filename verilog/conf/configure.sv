package configure;
  timeunit 1ns; timeprecision 1ps;

  parameter HARDWARE = 0;

  parameter MUL_PERFORMANCE = 1;

  parameter BUFFER_DEPTH = 4;

  parameter TIM_WIDTH = 32;
  parameter TIM_DEPTH = 8192;

  parameter RAM_DEPTH = 262144;

  parameter RAM_TYPE = 0;

  parameter ROM_BASE = 32'h00000000;
  parameter ROM_MASK = 32'hFFFFFF80;

  parameter SPI_BASE = 32'h00100000;
  parameter SPI_MASK = 32'hFFF00000;

  parameter UART_TX_BASE = 32'h01000000;
  parameter UART_TX_MASK = 32'hFFFFFFF0;

  parameter UART_RX_BASE = 32'h01000010;
  parameter UART_RX_MASK = 32'hFFFFFFF0;

  parameter CLINT_BASE = 32'h02000000;
  parameter CLINT_MASK = 32'hFFFF0000;

  parameter TIM_BASE = 32'h10000000;
  parameter TIM_MASK = 32'hFFF00000;

  parameter RAM_BASE = 32'h80000000;
  parameter RAM_MASK = 32'hFFF00000;

  parameter CPU_FREQ = 1000000000;  // 1GHz
  parameter PER_FREQ = 200000000;  // 200MHz
  parameter RTC_FREQ = 1000000;  // 1MHz
  parameter BAUDRATE = 115200;

  parameter CLK_DIVIDER_PER = CPU_FREQ / PER_FREQ;
  parameter CLK_DIVIDER_RTC = CPU_FREQ / RTC_FREQ;
  parameter CLK_DIVIDER_BIT = CPU_FREQ / BAUDRATE;

endpackage
