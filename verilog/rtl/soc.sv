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

  mem_in_type memory_in;
  mem_in_type imemory_in;
  mem_in_type dmemory_in;

  mem_out_type memory_out;
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

  logic [31 : 0] mem_addr;
  logic [31 : 0] base_addr;

  assign meip = rx_irq | tx_irq;

  always_comb begin

    rom_in = init_mem_in;
    ram_in = init_mem_in;
    tim_in = init_mem_in;
    spi_in = init_mem_in;
    clint_in = init_mem_in;
    error_in = init_mem_in;
    uart_rx_in = init_mem_in;
    uart_tx_in = init_mem_in;

    base_addr = 0;

    error_in.mem_valid = memory_in.mem_valid;

    if (memory_in.mem_valid & ~|(ROM_BASE ^ (memory_in.mem_addr & ROM_MASK))) begin
      rom_in = memory_in;
      base_addr = ROM_BASE;
      error_in.mem_valid = 0;
    end
    if (memory_in.mem_valid & ~|(RAM_BASE ^ (memory_in.mem_addr & RAM_MASK))) begin
      ram_in = memory_in;
      base_addr = RAM_BASE;
      error_in.mem_valid = 0;
    end
    if (memory_in.mem_valid & ~|(TIM_BASE ^ (memory_in.mem_addr & TIM_MASK))) begin
      tim_in = memory_in;
      base_addr = TIM_BASE;
      error_in.mem_valid = 0;
    end
    if (memory_in.mem_valid & ~|(SPI_BASE ^ (memory_in.mem_addr & SPI_MASK))) begin
      spi_in = memory_in;
      base_addr = SPI_BASE;
      error_in.mem_valid = 0;
    end
    if (memory_in.mem_valid & ~|(CLINT_BASE ^ (memory_in.mem_addr & CLINT_MASK))) begin
      clint_in = memory_in;
      base_addr = CLINT_BASE;
      error_in.mem_valid = 0;
    end
    if (memory_in.mem_valid & ~|(UART_RX_BASE ^ (memory_in.mem_addr & UART_RX_MASK))) begin
      uart_rx_in = memory_in;
      base_addr = UART_RX_BASE;
      error_in.mem_valid = 0;
    end
    if (memory_in.mem_valid & ~|(UART_TX_BASE ^ (memory_in.mem_addr & UART_TX_MASK))) begin
      uart_tx_in = memory_in;
      base_addr = UART_TX_BASE;
      error_in.mem_valid = 0;
    end

    mem_addr = memory_in.mem_addr - base_addr;

    rom_in.mem_addr = mem_addr;
    ram_in.mem_addr = mem_addr;
    tim_in.mem_addr = mem_addr;
    spi_in.mem_addr = mem_addr;
    clint_in.mem_addr = mem_addr;
    uart_rx_in.mem_addr = mem_addr;
    uart_tx_in.mem_addr = mem_addr;

    memory_out = init_mem_out;

    if (rom_out.mem_ready == 1) begin
      memory_out = rom_out;
    end
    if (ram_out.mem_ready == 1) begin
      memory_out = ram_out;
    end
    if (tim_out.mem_ready == 1) begin
      memory_out = tim_out;
    end
    if (spi_out.mem_ready == 1) begin
      memory_out = spi_out;
    end
    if (clint_out.mem_ready == 1) begin
      memory_out = clint_out;
    end
    if (error_out.mem_ready == 1) begin
      memory_out = error_out;
    end
    if (uart_rx_out.mem_ready == 1) begin
      memory_out = uart_rx_out;
    end
    if (uart_tx_out.mem_ready == 1) begin
      memory_out = uart_tx_out;
    end

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      error_out <= init_mem_out;
    end else begin
      error_out.mem_rdata <= 0;
      error_out.mem_error <= error_in.mem_valid;
      error_out.mem_ready <= error_in.mem_valid;
    end
  end

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

  arbiter arbiter_comp (
      .reset(reset),
      .clock(clock),
      .imem_in(imemory_in),
      .imem_out(imemory_out),
      .dmem_in(dmemory_in),
      .dmem_out(dmemory_out),
      .mem_in(memory_in),
      .mem_out(memory_out)
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
      .clock_rate(CLK_DIVIDER_RTC)
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
      .clock_rate(CLK_DIVIDER_PER)
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
      .clock_rate(CLK_DIVIDER_BIT)
  ) uart_rx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_rx_in),
      .uart_out(uart_rx_out),
      .rx_irq(rx_irq),
      .rx(rx)
  );

  uart_tx #(
      .clock_rate(CLK_DIVIDER_BIT)
  ) uart_tx_comp (
      .reset(reset),
      .clock(clock),
      .uart_in(uart_tx_in),
      .uart_out(uart_tx_out),
      .tx_irq(tx_irq),
      .tx(tx)
  );

endmodule
