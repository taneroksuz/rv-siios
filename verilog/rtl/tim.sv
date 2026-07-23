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

  localparam tim_vec_in_type init_tim_vec_in = '{default: 0};
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

  logic [31 : 0] tim_ram[0:TIM_DEPTH-1] = '{default: '0};

  always_ff @(posedge clock) begin
    if (tim_ram_in.en == 1) begin
      if (tim_ram_in.strb[0]) tim_ram[tim_ram_in.addr][7:0] <= tim_ram_in.data[7:0];
      if (tim_ram_in.strb[1]) tim_ram[tim_ram_in.addr][15:8] <= tim_ram_in.data[15:8];
      if (tim_ram_in.strb[2]) tim_ram[tim_ram_in.addr][23:16] <= tim_ram_in.data[23:16];
      if (tim_ram_in.strb[3]) tim_ram[tim_ram_in.addr][31:24] <= tim_ram_in.data[31:24];
      tim_ram_out.data <= tim_ram[tim_ram_in.addr];
    end
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
