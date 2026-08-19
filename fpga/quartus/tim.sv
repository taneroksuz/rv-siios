package tim_wires;
  timeunit 1ns; timeprecision 1ps;

  import configure::*;

  localparam DEPTH = $clog2(TIM_DEPTH);
  localparam WIDTH = $clog2(TIM_WIDTH);

  typedef struct packed {
    logic [0 : 0]       en;
    logic [DEPTH-1 : 0] addr;
    logic [3 : 0]       strb;
    logic [31 : 0]      data;
  } tim_ram_in_type;

  typedef struct packed {logic [31 : 0] data;} tim_ram_out_type;

  typedef tim_ram_in_type tim_vec_in_type[TIM_WIDTH];
  typedef tim_ram_out_type tim_vec_out_type[TIM_WIDTH];

  localparam tim_vec_in_type  init_tim_vec_in  = '{default: 0};
  localparam tim_vec_out_type init_tim_vec_out = '{default: 0};

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

  localparam DEPTH = $clog2(TIM_DEPTH);
  localparam WIDTH = $clog2(TIM_WIDTH);

  logic             we;
  logic [      7:0] q0;
  logic [      7:0] q1;
  logic [      7:0] q2;
  logic [      7:0] q3;
  logic [      7:0] d0;
  logic [      7:0] d1;
  logic [      7:0] d2;
  logic [      7:0] d3;
  logic [      3:0] be;
  logic [DEPTH-1:0] addr;

  assign we   = tim_ram_in.en && (|tim_ram_in.strb);
  assign d0   = tim_ram_in.data[7:0];
  assign d1   = tim_ram_in.data[15:8];
  assign d2   = tim_ram_in.data[23:16];
  assign d3   = tim_ram_in.data[31:24];
  assign be   = tim_ram_in.strb;
  assign addr = tim_ram_in.addr;

  assign tim_ram_out.data = {q3, q2, q1, q0};

  logic [7:0] mem0[0:TIM_DEPTH-1]  /* synthesis ramstyle = "no_rw_check" */;
  logic [7:0] mem1[0:TIM_DEPTH-1]  /* synthesis ramstyle = "no_rw_check" */;
  logic [7:0] mem2[0:TIM_DEPTH-1]  /* synthesis ramstyle = "no_rw_check" */;
  logic [7:0] mem3[0:TIM_DEPTH-1]  /* synthesis ramstyle = "no_rw_check" */;

  always_ff @(posedge clock) begin
    if (we && be[0]) mem0[addr] <= d0;
    q0 <= mem0[addr];
  end

  always_ff @(posedge clock) begin
    if (we && be[1]) mem1[addr] <= d1;
    q1 <= mem1[addr];
  end

  always_ff @(posedge clock) begin
    if (we && be[2]) mem2[addr] <= d2;
    q2 <= mem2[addr];
  end

  always_ff @(posedge clock) begin
    if (we && be[3]) mem3[addr] <= d3;
    q3 <= mem3[addr];
  end

endmodule

module tim_ctrl (
  input  logic            reset,
  input  logic            clock,
  input  tim_vec_out_type dvec_out,
  output tim_vec_in_type  dvec_in,
  input  mem_in_type      tim_in,
  output mem_out_type     tim_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam DEPTH = $clog2(TIM_DEPTH);
  localparam WIDTH = $clog2(TIM_WIDTH);

  typedef struct packed {
    logic [WIDTH-1:0] wid;
    logic [DEPTH-1:0] did;
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
      v.did   = tim_in.mem_addr[(DEPTH+WIDTH+1):(WIDTH+2)];
      v.wid   = tim_in.mem_addr[(WIDTH+1):2];
    end

    dvec_in = init_tim_vec_in;

    // Write data
    dvec_in[v.wid].en   = v.valid;
    dvec_in[v.wid].strb = v.strb;
    dvec_in[v.wid].addr = v.did;
    dvec_in[v.wid].data = v.data;

    rin = v;

    tim_out.mem_rdata = dvec_out[r.wid].data;
    tim_out.mem_error = 0;
    tim_out.mem_ready = r.valid;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end else begin
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

  tim_vec_in_type  dvec_in;
  tim_vec_out_type dvec_out;

  generate

    genvar i;

    for (i = 0; i < TIM_WIDTH; i = i + 1) begin : tim_ram
      tim_ram tim_ram_comp (
        .clock      (clock),
        .tim_ram_in (dvec_in[i]),
        .tim_ram_out(dvec_out[i])
      );
    end

  endgenerate

  tim_ctrl tim_ctrl_comp (
    .reset   (reset),
    .clock   (clock),
    .dvec_out(dvec_out),
    .dvec_in (dvec_in),
    .tim_in  (tim_in),
    .tim_out (tim_out)
  );

endmodule
