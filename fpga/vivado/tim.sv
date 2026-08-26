package tim_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam TIM_WORDS = TIM_WIDTH * TIM_DEPTH;
  localparam TADDR     = $clog2(TIM_WORDS);

  typedef struct packed {
    logic [0:0]       en;
    logic [TADDR-1:0] addr;
    logic [3:0]       strb;
    logic [31:0]      data;
  } tim_ram_in_type;

  typedef struct packed {logic [31:0] data;} tim_ram_out_type;

  localparam tim_ram_in_type  init_tim_ram_in  = '{default: '0};
  localparam tim_ram_out_type init_tim_ram_out = '{default: '0};

endpackage

import configure::*;
import wires::*;
import tim_wires::*;

module tim_ram (
  input  logic            clock,
  input  tim_ram_in_type  tim_ram_in,
  output tim_ram_out_type tim_ram_out
);
  timeunit 1ns; timeprecision 1ps;

  logic             we;
  logic [      3:0] be;
  logic [TADDR-1:0] addr;
  logic [     31:0] d;
  logic [     31:0] q;

  assign we   = tim_ram_in.en && (|tim_ram_in.strb);
  assign be   = tim_ram_in.strb;
  assign addr = tim_ram_in.addr;
  assign d    = tim_ram_in.data;

  assign tim_ram_out.data = q;

  (* ram_style = "block" *) logic [31:0] mem[0:TIM_WORDS-1];

  always_ff @(posedge clock) begin
    if (we && be[0]) mem[addr][7:0] <= d[7:0];
    if (we && be[1]) mem[addr][15:8] <= d[15:8];
    if (we && be[2]) mem[addr][23:16] <= d[23:16];
    if (we && be[3]) mem[addr][31:24] <= d[31:24];
    q <= mem[addr];
  end

endmodule

module tim_ctrl (
  input  logic            reset,
  input  logic            clock,
  input  tim_ram_out_type dvec_out,
  output tim_ram_in_type  dvec_in,
  input  mem_in_type      tim_in,
  output mem_out_type     tim_out
);
  timeunit 1ns; timeprecision 1ps;

  typedef struct packed {
    logic [TADDR-1:0] did;
    logic [31:0]      data;
    logic [3:0]       strb;
    logic [0:0]       valid;
  } front_type;

  parameter front_type init_reg = 0;

  front_type r, rin;
  front_type v;

  always_comb begin

    v = r;

    v.valid = 0;
    v.strb  = 0;

    if (tim_in.mem_valid == 1) begin
      v.valid = tim_in.mem_valid;
      v.strb  = tim_in.mem_wstrb;
      v.data  = tim_in.mem_wdata;
      v.did   = tim_in.mem_addr[(TADDR+1):2];
    end

    dvec_in = init_tim_ram_in;

    dvec_in.en   = v.valid;
    dvec_in.strb = v.strb;
    dvec_in.addr = v.did;
    dvec_in.data = v.data;

    rin = v;

    tim_out.mem_rdata = dvec_out.data;
    tim_out.mem_error = 0;
    tim_out.mem_ready = r.valid;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end
    else begin
      r <= rin;
    end
  end

endmodule

module tim (
  input  logic        reset,
  input  logic        clock,
  input  mem_in_type  tim_in,
  output mem_out_type tim_out
);
  timeunit 1ns; timeprecision 1ps;

  tim_ram_in_type  dvec_in;
  tim_ram_out_type dvec_out;

  tim_ram tim_ram_comp (
    .clock      (clock),
    .tim_ram_in (dvec_in),
    .tim_ram_out(dvec_out)
  );

  tim_ctrl tim_ctrl_comp (
    .reset   (reset),
    .clock   (clock),
    .dvec_out(dvec_out),
    .dvec_in (dvec_in),
    .tim_in  (tim_in),
    .tim_out (tim_out)
  );

endmodule
