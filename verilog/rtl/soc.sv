import configure::*;
import wires::*;

module soc (
    input reset,
    input clear,
    input clock,
    output sclk,
    output mosi,
    input miso,
    output ss,
    input rx,
    output tx,
    input mem_out_type ram_out,
    output mem_in_type ram_in
);

  timeunit 1ns; timeprecision 1ps;

  mem_in_type imemory_in;
  mem_in_type dmemory_in;

  mem_out_type imemory_out;
  mem_out_type dmemory_out;

  mem_in_type rom_in;
  mem_in_type tim_in;
  mem_in_type spi_in;
  mem_in_type clint_in;
  mem_in_type error_in;
  mem_in_type uart_rx_in;
  mem_in_type uart_tx_in;

  mem_out_type rom_out;
  mem_out_type tim_out;
  mem_out_type spi_out;
  mem_out_type clint_out;
  mem_out_type error_out;
  mem_out_type uart_rx_out;
  mem_out_type uart_tx_out;

  logic [0 : 0] meip;
  logic [0 : 0] msip;
  logic [0 : 0] mtip;

  logic [0 : 0] rx_irq;
  logic [0 : 0] tx_irq;

  logic [63 : 0] mtime;

  assign meip = rx_irq | tx_irq;

  cpu cpu_comp (
      .reset(reset),
      .clear(clear),
      .clock(clock),
      .imemory_in(imemory_in),
      .imemory_out(imemory_out),
      .dmemory_in(dmemory_in),
      .dmemory_out(dmemory_out),
      .meip(meip),
      .msip(msip),
      .mtip(mtip),
      .mtime(mtime)
  );

  bus bus_comp (
      .reset(reset),
      .clear(clear),
      .clock(clock),
      .imemory_in(imemory_in),
      .imemory_out(imemory_out),
      .dmemory_in(dmemory_in),
      .dmemory_out(dmemory_out),
      .rom_in(rom_in),
      .tim_in(tim_in),
      .ram_in(ram_in),
      .spi_in(spi_in),
      .clint_in(clint_in),
      .uart_rx_in(uart_rx_in),
      .uart_tx_in(uart_tx_in),
      .rom_out(rom_out),
      .tim_out(tim_out),
      .ram_out(ram_out),
      .spi_out(spi_out),
      .clint_out(clint_out),
      .uart_rx_out(uart_rx_out),
      .uart_tx_out(uart_tx_out)
  );

  tim tim_comp (
      .reset  (reset),
      .clock  (clock),
      .tim_in (tim_in),
      .tim_out(tim_out)
  );

  rom rom_comp (
      .reset  (reset),
      .clock  (clock),
      .rom_in (rom_in),
      .rom_out(rom_out)
  );

  clint #(
      .CLOCK_RATE(CLK_DIVIDER_RTC)
  ) clint_comp (
      .reset(reset),
      .clock(clock),
      .clint_in(clint_in),
      .clint_out(clint_out),
      .clint_msip(msip),
      .clint_mtip(mtip),
      .clint_mtime(mtime)
  );

  spi #(
      .CLOCK_RATE(CLK_DIVIDER_PER)
  ) spi_comp (
      .reset(reset),
      .clock(clock),
      .spi_in(spi_in),
      .spi_out(spi_out),
      .sclk(sclk),
      .mosi(mosi),
      .miso(miso),
      .ss(ss)
  );

  uart_rx #(
      .CLOCK_RATE(CLK_DIVIDER_BIT)
  ) uart_rx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_rx_in),
      .uart_out(uart_rx_out),
      .rx_irq(rx_irq),
      .rx(rx)
  );

  uart_tx #(
      .CLOCK_RATE(CLK_DIVIDER_BIT)
  ) uart_tx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_tx_in),
      .uart_out(uart_tx_out),
      .tx_irq(tx_irq),
      .tx(tx)
  );

endmodule
