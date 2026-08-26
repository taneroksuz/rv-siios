import wires::*;
import constants::*;

module arbiter (
  input  logic        reset,
  input  logic        clock,
  input  mem_in_type  imem_in,
  output mem_out_type imem_out,
  input  mem_in_type  dmem_in,
  output mem_out_type dmem_out,
  output mem_in_type  mem_in,
  input  mem_out_type mem_out
);
  timeunit 1ns; timeprecision 1ps;

  localparam [1:0] no_access    = 0;
  localparam [1:0] instr_access = 1;
  localparam [1:0] data_access  = 2;

  typedef struct packed {
    logic [1:0] access_type;
    mem_in_type mem_in;
    mem_in_type imem_in;
    mem_in_type dmem_in;
    logic [0:0] iactive;
    logic [0:0] dactive;
  } reg_type;

  localparam reg_type init_reg = '{default: 0};

  reg_type r, rin;
  reg_type v;

  always_comb begin

    v = r;

    v.mem_in = init_mem_in;

    if (mem_out.mem_ready == 1) begin
      v.access_type = no_access;
    end

    if (dmem_in.mem_valid == 1 && v.dmem_in.mem_valid == 0 && v.dactive == 0) begin
      v.dmem_in = dmem_in;
    end
    if (imem_in.mem_valid == 1 && v.imem_in.mem_valid == 0 && v.iactive == 0) begin
      v.imem_in = imem_in;
    end

    if (v.access_type == no_access) begin
      if (v.dmem_in.mem_valid == 1) begin
        v.access_type = data_access;
        v.mem_in      = v.dmem_in;
        v.dmem_in     = init_mem_in;
      end
      else if (v.imem_in.mem_valid == 1) begin
        v.access_type = instr_access;
        v.mem_in      = v.imem_in;
        v.imem_in     = init_mem_in;
      end
    end

    mem_in = v.mem_in;

    rin = v;

    dmem_out = (r.access_type == data_access) ? mem_out : init_mem_out;
    imem_out = (r.access_type == instr_access) ? mem_out : init_mem_out;

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
